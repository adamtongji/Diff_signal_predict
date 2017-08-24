#!/bin/bash

peak_file=$1
enhancer_file=$2
prefix=$3

mkdir -p prauc_tmp
awk '{if ($4==1){print $0}}' | sort -k1,1 -k2g,2g |cut -f1-3 > prauc_tmp/pos_enhancer.txt
awk '{if ($4==0){print $0}}' | sort -k1,1 -k2g,2g |cut -f1-3 > prauc_tmp/neg_enhancer.txt

output1="prauc_tmp/${prefix}prauc_positive.bed"
output2="prauc_tmp/${prefix}prauc_negative.bed"
output3="prauc_tmp/${prefix}false.positive.bed"
output4="prauc_tmp/${prefix}true.negative.bed"
output="prauc_tmp/${prefix}prauc.txt"

total_peaks=$(cat $peaks | wc -l)
total_positive=$( cat prauc_tmp/pos_enhancer.txt | wc -l )
total_negative=$( cat prauc_tmp/neg_enhancer.txt | wc -l )

cut -f1,2,3 $peak_file | awk '{printf "%s\t%d\n",$0,NR}' \
|intersectBed -wo -a prauc_tmp/pos_enhancer.txt -b stdin | cut -f 1-3,7 |sort -k 1,1 -k 2g,2g -k 4g,4g >temp1.txt
python ${DIFF_PRED}/get_best_peak.py temp1.txt $output1 1

cut -f1,2,3 $peak_file  | awk '{printf "%s\t%d\n",$0,NR}' \
|intersectBed -wo -a prauc_tmp/neg_enhancer.txt -b stdin |  cut -f 1-3,7 |sort -k 1,1 -k 2g,2g -k 4g,4g >temp2.txt
python ${DIFF_PRED}/get_best_peak.py temp2.txt $output2 0

# false negative/true negative peaks
cut -f1,2,3 $peak_file | awk '{printf "%s\t%d\n",$0,NR}' | intersectBed -v -a prauc_tmp/pos_enhancer.txt -b stdin|sort| uniq| awk -v totals=$total_peaks '{printf "%s\t%s\n",totals,1}' > $output3
cut -f1,2,3 $peak_file | awk '{printf "%s\t%d\n",$0,NR}' | intersectBed -v -a prauc_tmp/neg_enhancer.txt -b stdin |sort| uniq | awk -v totals=$total_peaks '{printf "%s\t%s\n",totals,0}' > $output4


cat $output1 $output2 $output3 $output4 |sort -k 1g,1g  > $output
rm $output1 $output2 $output3 $output4 temp1.txt temp2.txt