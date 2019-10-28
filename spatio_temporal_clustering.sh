#!/bin/bash

FILENAME=$1
FILENAME_NEW=$2
CLUSTERSIZE=$3
DIR=$4

cd $DIR

CLUST_FILE='temp+orig.'
NONZERO_FILE='nonzero+orig.'
CLUST_MASK_FILE='clust_mask+orig.'

NSCANS=$(3dinfo -nv ${FILENAME})

rm "$CLUST_MASK_FILE*"
rm "$CLUST_FILE*"
rm "$NONZERO_FILE*"

for coef_idx in $(seq 0 $((NSCANS-1)))
do
    echo "========================================================"
    echo "Timepoint $((coef_idx+1)) of $NSCANS done..."
    echo "========================================================"
    if [ $coef_idx -eq 0 ]
    then
        3dTstat -absmax -prefix ${NONZERO_FILE} ${FILENAME}[$((coef_idx)):$((coef_idx+1))] -overwrite
        3dcalc -a ${NONZERO_FILE} -expr 'bool(a)' -prefix ${NONZERO_FILE} -overwrite
        3dmerge -dxyz=1 -1clust 1 ${CLUSTERSIZE} -prefix ${CLUST_FILE} ${NONZERO_FILE} -overwrite
        # 3dClusterize -nosum -1Dformat -inset ${NONZERO_FILE} -idat 0 -clust_nvox 5 -binary -1sided 'RIGHT' 0.05 -pref_dat ${CLUST_FILE}
        3dTcat -prefix ${CLUST_MASK_FILE} ${CLUST_FILE} -overwrite
    elif [ $coef_idx -eq $((NSCANS-1)) ]
    then
        3dTstat -absmax -prefix ${NONZERO_FILE} ${FILENAME}[$((coef_idx-1)):$((coef_idx))] -overwrite
        3dcalc -a ${NONZERO_FILE} -expr 'bool(a)' -prefix ${NONZERO_FILE} -overwrite
        3dmerge -dxyz=1 -1clust 1 ${CLUSTERSIZE} -prefix ${CLUST_FILE} ${NONZERO_FILE} -overwrite
        # 3dClusterize -nosum -1Dformat -inset ${NONZERO_FILE} -idat 0 -clust_nvox 5 -binary -1sided 'RIGHT' 0.05 -pref_dat ${CLUST_FILE}
        3dTcat -glueto ${CLUST_MASK_FILE} ${CLUST_FILE}
    else
        3dTstat -absmax -prefix ${NONZERO_FILE} ${FILENAME}[$((coef_idx-1)):$((coef_idx+1))] -overwrite
        3dcalc -a ${NONZERO_FILE} -expr 'bool(a)' -prefix ${NONZERO_FILE} -overwrite
        3dmerge -dxyz=1 -1clust 1 ${CLUSTERSIZE} -prefix ${CLUST_FILE} ${NONZERO_FILE} -overwrite
        # 3dClusterize -nosum -1Dformat -inset ${NONZERO_FILE} -idat 0 -clust_nvox 5 -binary -1sided 'RIGHT' 0.05 -pref_dat ${CLUST_FILE}
        3dTcat -glueto ${CLUST_MASK_FILE} ${CLUST_FILE}
    fi
done

echo "========================================================"
echo "Applying spatio-temporal clustering mask on $FILENAME..."
echo "========================================================"

3dcalc -a ${FILENAME} -b ${CLUST_MASK_FILE} -expr 'a*b' -prefix ${FILENAME_NEW} -overwrite

echo "========================================================"
echo "Spatio-temporal clustering finished. Results saved in $FILENAME_NEW."
echo "========================================================"
