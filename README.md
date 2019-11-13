# Spatio Temporal Clustering
The Spatio Temporal Clustering script has been developed for fMRI data using [AFNI](https://afni.nimh.nih.gov). It is written in Python (and uses BASH) and it aims to remove spurious, scattered neuronal-related activity in favor of clusters. The clustering is applied in a `t-1 < t < t+1` sliding window to maintain the activity in `groups of voxels >= SIZE`.

## Usage
The required arguments are the following:

1. `--input`: filename of the input file.
2. `--prefix`: filename for the output file.

Other arguments can also be used:

- `--w_pos`: length of the sliding window going forward (default = 1).
- `--w_neg`: length of the sliding window going backwards (default = 1).
- `--method`: method to select the voxels to retain (default = 'absmax').
- `--clustsize`: minimum size of the clusters (default = 5).
- `--thr`: value to threshold the data (default = 0.5). `input < thr` will be set to zero.

You can call the script as follows:

`python stc.py --input INPUT --output OUTPUT --w_pos W_POS --w_neg W_NEG --method 'METHOD' --clustsize CLUSTSIZE --thr THR`

You can find the output file in the same folder you run the script from. In some cases, the script will automatically generate a BASH script called *spatio_temporal_clustering_edited.sh*. This is done to account for sliding windows that are not 1 volume long.

## Requirements
The script is based on three AFNI commands. Make sure your AFNI version supports them (click on the names to learn about them):

- [3dcalc](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dcalc.html)
- [3dmerge](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dmerge.html)
- [3dnewid](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dnewid.html)
