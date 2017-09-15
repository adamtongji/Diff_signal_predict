#!/bin/bash

export DIFF_PRED="/home/adam/new_dir/atac_contrast/Diff_signal_predict"
for tis in "cranioface" "limb" "liver" "neural_tube" "forebrain" "midbrain" "hindbrain" "heart";do
	python main.py -p /home/adam/new_dir/atac_contrast/ATAC-seq_peak/${tis}_11.5_day.dfilter.final.bed\
	 --bigwig /home/adam/new_dir/atac_contrast/3_type_bigWig/ATAC-seq/${tis}_11.5_day_rep0.10bp.bigWig\
	  -r -o ./${tis}_atac_result -m 1 -d /home/adam/new_dir/atac_contrast/3_type_bigWig/
done
