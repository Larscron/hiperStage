
# string 1 start here
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

# all variables are set outside this one
#set str $strName
#set param_l $param_l
#set param_v $combo


# strig 2 starts here
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

# string 3 starts here
# cmp away the original niobium layer
etch Nb1 cmp spacing= 3e-3 time=$cmp_time;# cmp time variation
plot2d grid clear
plot2d grid

#sputter deposition of niobium
set Nb1SputTime 3.30
deposit spacing= 3e-3 Nb1 time=$Nb1SputTime 
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

# string 4 start here

# units are in angstroms
sel z= 0 name= AlOx_Thickness
profile infile= OxideThickness.txt name= AlOx_Thickness transverse=1

contact Nb1 xlo=0.399 xhi=0.4001 ylo=-100 yhi=100 name=GND add
struct outfile= $str 
