while getopts "i:o:" opt; do
case ${opt} in
    i )
      input_bam=$OPTARG
      ;;
    o )
      outputdir=$OPTARG
      ;;
       
    \? )
      echo "Usage: cmd -i input.bam -o ."
      exit 1
      ;;
  esac
done
# input_bam="/workdir/outdir/20250604/SampleSheet_UMI_runs/UMT_DISTANCE_0/BISMARK_ALIGNMENT_UNMAPPED_BAM/11-TML3S1_S7511-S7711_R1.UMIprocessed_bismark_bt2_pe.bam"
filename=$(echo $input_bam | xargs -n 1 basename | cut -d. -f1);
samtools view -H ${input_bam} > ${outputdir}/output.sam
samtools view ${input_bam} | \
    awk 'BEGIN{OFS="\t"} {split($1, arr, "_"); 
        umi = arr[2]; 
        qual = arr[3];
        seq = $10;
        seq_qual = $11;
        if ($9 > 0){
            seq = umi""seq
            seq_qual = qual""seq_qual
        } else {
            seq = seq""umi
            seq_qual = seq_qual""qual
        };
        if ($6 ~ /^[0-9]+M$/){
            match_len = substr($6, 1, length($6) - 1) + 6;
            new_cigar = match_len "M"
            $6 = new_cigar;
            $10 = seq;
            $11 = seq_qual;
            print $0
        }
    }' >> ${outputdir}/output.sam;
    samtools view -bS ${outputdir}/output.sam -o ${outputdir}/${filename}.addedUMIback.bam
