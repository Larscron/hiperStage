
# Collects user input to and generates a nested list with parameters and the corresponding parameter values
# lol stand for list of lists
proc usr_input {} {
        puts "input simmulation variables sepperated by space"
        puts "cmp_time: "
        set cmp_time [gets stdin]
        puts "sd: "
        set sd [gets stdin]
        puts "sputter_time: "
        set sputter_time [gets stdin]
        puts "deposition_rate: "
        set deposition_rate [gets stdin]
	# these are the default values !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if {$cmp_time eq ""} { set cmp_time {1.9} }
        if {$sd eq ""} { set sd {0.015 0.020} }
        if {$sputter_time eq ""} { set sputter_time {3.0} }
        if {$deposition_rate eq ""} { set deposition_rate  {0} }

        puts "cmp_time: $cmp_time"
        puts "sd: $sd"
        puts "sputter_time: $sputter_time"
        puts "deposition_rate: $deposition_rate"
        set lol [list cmp_time $cmp_time sd $sd sputter_time $sputter_time deposition_rate $deposition_rate]
return $lol
}

# accepts a nested list of parameters names and their corresponding values and returns two lists.
# list 1: parameter names
# list 2: nested list of all possible parameter value combinations
#	the 1st parrameter name will always correspond to the 1st value of each of the parameter value combinations. The same holds true for the 2nd, 3rd, 4th item, and so on

proc print_comb lol {
  set param_list {}; set vals_lists {}
  foreach {param val_list} $lol {
    lappend param_list $param; lappend vals_lists $val_list
  }
  set first 1
  foreach vals $vals_lists {
    if {$first} {
      set comb_list $vals; set first 0
    } else {
      set new_comb_list {}
      foreach comb_val $comb_list {
        foreach val $vals {
          lappend new_comb_list "${comb_val} ${val}"
        }
      }
      set comb_list $new_comb_list
    }
  }
  return [list $param_list $comb_list]
}




# Hash function. Will use the string to generate a unique str name
proc hashStr inputStr {			;# the input string is not yet used. Will update this later
#get a random number between 0 and 999
set randNum [expr { int(1000 * rand()) }]
# if the number is less than 100 we have to add 0s infront of it
if { $randNum == 0 } {
	set randNum 000
} elseif {$randNum < 10 } {
	set randNum "00$randNum"
} elseif {$randNum <100 } {
	set randNum "0$randNum"
}
# returns a (hopefully uniwue string)
set unique [clock microseconds]$randNum.str
return $unique
}




## the SimpleMITJJStructure.tcl script
# this function generates a string that will later be exicuted by flooxs
proc structStr {strName param_l val_l} {

set gridspac 0.02

foreach param $param_l val $val_l {
	set $param $val
}

################# mater section ##########################
set str1 "
mater add name=alum grey
mater add name=metal blue

mater add name=Nb1 pink
mater add name=Nb2 black
mater add name=Nb3 salmon
mater add name=Nb4 magenta
mater add name=Nb5 cyan
mater add name=Nb6 brown
mater add name=Nb7 yellow
mater add name=Nb8 purple
"

################# init section ##########################
set str2 "
pdbSet LevelSet gmsh 1
pdbSet LevelSet gmshParams DebugMesh 1
pdbSet LevelSet scalFactor 3e5
pdbSet LevelSet cmp sd $sd
pdbSet LevelSet cmp mu 0.50	;# we are no longer playig around wiht this one

# gridspace is set outside of the string
line x loc=-0.500   spac=$gridspac    tag=T1
line x loc=0.100    spac=$gridspac    tag=T2
line x loc=0.400    spac=$gridspac    tag=T3
line y loc=-0.400 spac=$gridspac     tag=S1
line y loc=0.400 spac=$gridspac     tag=S2

#define regions
region gas        xlo=T1  xhi=T2  ylo=S1  yhi=S2
region Nb1        xlo=T2  xhi=T3  ylo=S1  yhi=S2

#initialize the mesh
init

#define mask for counter electrode etch
mask name=CEmask     left=-0.250  right=0.250

#define mask for contact
mask name=contact    left=-0.300  right=0.300 negative

window null row=1 col=1 width=600 height=600
#window row=1 col=1 width=600 height=600
plot2d grid xmax=0.4 xmin=-0.5 
"

################# simulation section ##########################
set str3 "
# cmp away the original niobium layer
etch Nb1 cmp spacing= 3e-3 time=$cmp_time;# cmp time variation
plot2d grid clear
plot2d grid

#sputter deposition of niobium
deposit spacing= 3e-3 Nb1 time=$sputter_time 
plot2d grid clear
plot2d grid

#sputter deposition of aluminum
deposit spacing= 3e-3 alum time=0.35;# deposits about 35nm of aluminum
plot2d clear
plot2d grid

#oxidation of aluminum to form the barrier
oxidize alum time=13
plot2d clear
plot2d grid gas

#deposit counter electrode
deposit Nb2 time=2.0 contact=VSS;# deposits about 200nm of niobium2

plot2d clear
plot2d grid gas
"

################# output section ##########################
set str4 "
sel z= 0 name= AlOx_Thickness
profile infile= OxideThickness.txt name= AlOx_Thickness transverse=1

contact Nb1 xlo=0.399 xhi=0.4001 ylo=-100 yhi=100 name=GND add
struct outfile= $strName 
"
set outStr "$str1 $str2 $str3 $str4"

return $outStr
}
