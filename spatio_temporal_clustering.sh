#!/bin/bash

# try as single command

Narg=$#        

# check if we have the correct number of args-- $Narg is the number
# plus one (for the command name)
if [ $# -eq 5 ]
then
    echo "++ Great, have the correct number of args: $Narg"
    echo "   Let's run"
else
    echo "** Need 4 args, not: $Narg"
    exit 1
fi

FILENAME=$1
FILENAME_NEW=$2
CLUSTERSIZE=$3
VOXELTHRESH=$4

# ---------------------------------------------------------------------

RAND_ID=`3dnewid -fun11`

imed_calc=__${RAND_ID}_calc.nii
imed_merge=__${RAND_ID}_merge.nii

# ---------------------------------------------------------------------

3dcalc \
    -a ${FILENAME} \
    -b 'a[0,0,0,1]' \
    -c 'a[0,0,0,-1]' \
    -expr "maxbelow(10000000000,abs(a)*step(abs(a)-${VOXELTHRESH}),abs(b)*step(abs(b)-${VOXELTHRESH}),abs(c)*step(abs(c)-${VOXELTHRESH}))" \
    -prefix ${imed_calc} \
    -overwrite

3dmerge                              \
    -dxyz=1                          \
    -1clust 1 ${CLUSTERSIZE}         \
    -doall                           \
    -prefix ${imed_merge}            \
    ${imed_calc}

3dcalc                               \
    -a ${FILENAME}                   \
    -b ${imed_merge}                 \
    -expr 'a*step(b)'                \
    -prefix ${FILENAME_NEW}          \
    -overwrite

# clean
\rm -f __${RAND_ID}_*

echo "========================================================================"
echo "Spatio-temporal clustering finished. Results saved in:  ${FILENAME_NEW}"
echo "========================================================================"

# done!
exit 0
