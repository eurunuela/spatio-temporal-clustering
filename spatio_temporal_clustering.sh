#!/bin/bash

FILENAME=$1
FILENAME_NEW=$2
CLUSTERSIZE=$3

CLUST_FILE='temp+orig.'
NONZERO_FILE='NONZERO_FILE+orig.'

NSCANS=$(3dinfo -nv ${FILENAME})

for coef_idx in $(seq 0 $((NSCANS-1)))
do
    echo "Timepoint $((coef_idx+1)) of $NSCANS done..."
    if [ $coef_idx -eq 0 ]
    then
        3dcalc -a ${FILENAME}[$((coef_idx)):$((coef_idx+1))] -expr 'step(a)' -prefix ${NONZERO_FILE} -overwrite
        3dmerge -dxyz=1 -1clust 1 ${CLUSTERSIZE} -doall -prefix ${CLUST_FILE} ${NONZERO_FILE} -overwrite
        3dTcat -prefix ${FILENAME_NEW} ${CLUST_FILE}[0]
    elif [ $coef_idx -eq $((NSCANS-1)) ]
    then
        3dcalc -a ${FILENAME}[$((coef_idx-1)):$((coef_idx))] -expr 'step(a)' -prefix ${NONZERO_FILE} -overwrite
        3dmerge -dxyz=1 -1clust 1 ${CLUSTERSIZE} -doall -prefix ${CLUST_FILE} ${NONZERO_FILE} -overwrite
        3dTcat -glueto ${FILENAME_NEW} ${CLUST_FILE}[1]
    else
        3dcalc -a ${FILENAME}[$((coef_idx-1)):$((coef_idx+1))] -expr 'step(a)' -prefix ${NONZERO_FILE} -overwrite
        3dmerge -dxyz=1 -1clust 1 ${CLUSTERSIZE} -doall -prefix ${CLUST_FILE} ${NONZERO_FILE} -overwrite
        3dTcat -glueto ${FILENAME_NEW} ${CLUST_FILE}[1]
    fi
done

echo "Applying spatio-temporal clustering mask on $FILENAME..."

3dcalc -a ${FILENAME} -b ${CLUST_FILE} -expr 'a*b' -prefix ${FILENAME_NEW} -overwrite

echo "Spatio-temporal clustering finished. Results saved in $FILENAME_NEW."