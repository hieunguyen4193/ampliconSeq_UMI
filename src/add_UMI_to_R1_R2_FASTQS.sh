#!/bin/bash
# Example
# input_fastq1="/media/hieunguyen/HNHD01/raw_data/amplicon_methyl_with_UMI/test_batch/1-TML1S1_S7501-S7701_R1.fastq.gz";
# input_fastq2="/media/hieunguyen/HNHD01/raw_data/amplicon_methyl_with_UMI/test_batch/1-TML1S1_S7501-S7701_R2.fastq.gz";
# umi_length=6;

while getopts "f:r:u:q:s:o:" opt; do
case ${opt} in
    f )
      input_fastq1=$OPTARG
      ;;
    r )
      input_fastq2=$OPTARG
      ;;
    u )
      umi_list=$OPTARG
      ;;
    q )
      qual_umi_list=$OPTARG
      ;;
    s )
      sample_id=$OPTARG
      ;;
    o )
      outputdir=$OPTARG
      ;;
       
    \? )
      echo "Usage: cmd [-f input_fastq1] [-r input_fastq2] [-u umi_list] [-q qual_umi_list] [-o outputdir]"
      exit 1
      ;;
  esac
done

# Reverse complement UMI list and save to a temporary file using tr and rev
revcomp_umi_list=$(mktemp)
cat "${umi_list}" | tr "ATGCatgc" "TACGtacg" | rev > "${revcomp_umi_list}"

paste <(zcat ${input_fastq1} | awk 'NR%4==1') \
    ${umi_list} \
    ${qual_umi_list} \
    <(zcat ${input_fastq1} | awk 'NR%4==2') \
    <(zcat ${input_fastq1} | awk 'NR%4==3') \
    <(zcat ${input_fastq1} | awk 'NR%4==0') | \
    awk '{print $1"\n"$2$4"\n"$5"\n"$3$6}' | \
    gzip > ${outputdir}/${sample_id}_R1.UMIprocessed.fastq.gz

paste <(zcat ${input_fastq2} | awk 'NR%4==1') \
    ${revcomp_umi_list} \
    ${qual_umi_list} \
    <(zcat ${input_fastq2} | awk 'NR%4==2') \
    <(zcat ${input_fastq2} | awk 'NR%4==3') \
    <(zcat ${input_fastq2} | awk 'NR%4==0') | \
    awk '{print $1"\n"$2$4"\n"$5"\n"$3$6}' | \
    gzip > ${outputdir}/${sample_id}_R2.UMIprocessed.fastq.gz

# EOF