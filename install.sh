#!/bin/bash
# Install dependencies
conda install -n diff_predict --file requirements.txt -c defaults -c bioconda -c r
##  Add your software path to your environment
# mypath=pwd
# export DIFF_PRED="/home/adam/new_dir/atac_contrast/Diff_signal_predict"
