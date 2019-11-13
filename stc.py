#!/usr/bin/python
import sys
import argparse
from subprocess import run
import string
import numpy as np


def _create_file_str():
    file_str = '''
    #!/bin/bash
    Narg=$#

    # check if we have the correct number of args-- $Narg is the number
    # plus one (for the command name)
    if [ $# -eq 4 ]
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

    3dcalc -a ${FILENAME} REPLACE_ME_3DCALC -prefix ${imed_calc} -overwrite

    3dmerge -dxyz=1 \
            -1clust 1 ${CLUSTERSIZE} \
            -doall \
            -prefix ${imed_merge} \
            ${imed_calc}

    3dcalc -a ${FILENAME} \
           -b ${imed_merge} \
           -expr 'a*step(b)' \
           -prefix ${FILENAME_NEW} \
           -overwrite

    # clean
    \\rm -f __${RAND_ID}_*

    echo "================================================================"
    echo "Spatio-temporal clustering finished. Results in: ${FILENAME_NEW}"
    echo "================================================================"

    # done!
    exit 0

    '''

    return file_str


def main(argv):
    parser = argparse.ArgumentParser(description='Spatio-temporal clustering.')
    parser.add_argument('--input', type=str, nargs=1,
                        help='Filename of the input file.')
    parser.add_argument('--output', type=str, nargs=1,
                        help='Filename for the output file.')
    parser.add_argument('--w_pos', type=int, default=1, nargs=1,
                        help=('length of the sliding window going forward '
                              '(default=1).'))
    parser.add_argument('--w_neg', type=int, default=1, nargs=1,
                        help=('length of the sliding window going backwards '
                              '(default=1).'))
    parser.add_argument('--method', type=str, default='absmax', nargs=1,
                        help=('Method to select the voxels to retain '
                              '(default = \'absmax\')'))
    parser.add_argument('--clustsize', type=int, default=5, nargs=1,
                        help='Minimum size of the clusters (default=5)')
    parser.add_argument('--thr', type=float, default=0.5, nargs=1,
                        help='value to threshold the data (default = 0.5).')
    args = parser.parse_args()

    input_filename = args.input[0]
    output_filename = args.output[0]
    w_pos = args.w_pos[0]
    w_neg = -args.w_neg[0]
    method = args.method
    clustsize = args.clustsize
    thr = args.thr

    # Call to the main spatio_temporal_clustering.sh script
    if w_pos == 1 and w_neg == 1 and 'absmax' in method:
        command_str = 'sh spatio_temporal_clustering.sh {} {} {} {}'\
                      .format(input_filename, output_filename, clustsize, thr)
        run(command_str, shell=True)
    # Call to the edited spatio_temporal_clustering.sh script
    else:
        # Number of time points in sliding window
        n_tp = w_pos + abs(w_neg) + 1

        alpha_list = list(string.ascii_lowercase)[1:n_tp]
        w_range = np.arange(w_neg, w_pos + 1)
        w_range = w_range[np.nonzero(w_range)]
        var_str = []
        edit_str = []

        for ii in range(len(alpha_list)):
            var_str.append("-{} 'a[0,0,0,{}]'".format(alpha_list[ii],
                                                      w_range[ii]))
            if 'absmax' in method:
                to_append = 'abs({})*step(abs({})'.format(
                    alpha_list[ii], alpha_list[ii]) + '-${VOXELTHRESH})'
                edit_str.append(to_append)
            elif 'median' or 'mean' in method:
                to_append = '{}*step({}'.format(
                    alpha_list[ii], alpha_list[ii]) + '-${VOXELTHRESH})'
                edit_str.append(to_append)

        var_str_merged = ' '.join(var_str)
        edit_str_merged = ', '.join(edit_str)

        if 'absmax' in method:
            expr_str = ("-expr \"maxbelow(10000000000, abs(a)*step(abs(a)-"
                        "${VOXELTHRESH}), ") + "{}".format(edit_str_merged)
            expr_str = expr_str + ")\""
        elif 'median' in method:
            expr_str = ("-expr \"median(a*step(a-"
                        "${VOXELTHRESH}), ") + "{}".format(edit_str_merged)
        elif 'mean' in method:
            expr_str = ("-expr \"mean(a*step(a-"
                        "${VOXELTHRESH}), ") + "{}".format(edit_str_merged)
        edits = ' '.join([var_str_merged, expr_str])

        file_str = _create_file_str().replace('REPLACE_ME_3DCALC', edits)

        with open('spatio_temporal_clustering_edited.sh', 'w') as rsh:
            rsh.write(file_str)

        command_str = 'sh spatio_temporal_clustering_edited.sh {} {} {} {}'\
                      .format(input_filename, output_filename, clustsize, thr)
        run(command_str, shell=True)


if __name__ == "__main__":
    main(sys.argv[1:])
