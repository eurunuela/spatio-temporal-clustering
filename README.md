# Spatio Temporal Clustering
The Spatio Temporal Clustering script has been developed for fMRI data using [AFNI](https://afni.nimh.nih.gov). It is written in BASH and it aims to remove spurious, scattered neuronal-related activity in favor of clusters. The clustering is applied in a `t-1 < t < t+1` sliding window to maintain the activity in `groups of voxels > SIZE`.

## Usage
The required arguments are the following:

1. `INPUT`: filename of the input file.
2. `OUTPUT`: filename for the output file.
3. `SIZE`: minimum size of the clusters.

All three arguments should be given to the command **in the following order**:

`spatio_temporal_clustering.sh ${INPUT} ${OUTPUT} ${SIZE}`

You can find the output file in the same folder you run the script from. Mind that the script will also generate temporary files that should be automatically removed. In case the removing of the files fail, the user can savely remove them.

## Requirements
The script is based on four AFNI commands. Make sure your AFNI version supports them (click on the names to learn about them):

- [3dinfo](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dinfo.html)
- [3dcalc](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dcalc.html)
- [3dmerge](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dmerge.html)
- [3dTcat](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTcat.html)
