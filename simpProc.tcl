
# sources the necessary functions
source ./procs.tcl

# gets the parameters 
set params [usr_input]

# gets all possible parameter combinations
lassign [print_comb $params] param_l combo_l

set str_name testStr

# number of cpus to use
set cpus 3

set combo [lindex $combo_l 0]


puts "param list:\t$param_l"
puts "1st combo: \t$combo"
# get the string that will generate the structures
set simpStr [structStr $str_name  $param_l $combo]


#puts $simpStr

for {set n 1} {$n<=$cpus} {incr n}  {
	puts "runing script nr $n"
	file mkdir tmp$n
	cd tmp$n
	exec echo $simpStr | flooxs > tmp_log$n.log &
	cd ..
}


