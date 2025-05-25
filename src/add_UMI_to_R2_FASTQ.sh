input_fastq1="/media/hieunguyen/HNHD01/raw_data/amplicon_methyl_with_UMI/test_batch/1-TML1S1_S7501-S7701_R1.fastq.gz";
input_fastq2="/media/hieunguyen/HNHD01/raw_data/amplicon_methyl_with_UMI/test_batch/1-TML1S1_S7501-S7701_R2.fastq.gz";
umi_length=6;

zcat ${input_fastq1} | \
awk -v umi_length=${umi_length} '{
    if(NR%4==1) {
        header = $0;
    } else if(NR%4==2) {
        seq = $0;
    } else if(NR%4==0) {
        qual = $0;
        # Extract UMI from the sequence
        umi = substr(seq, 1, umi_length);
        # Print the header, UMI, and quality
        print header "\n" umi "\n" "+" "\n" substr(qual, 1, umi_length);
    }
}' | gzip > extracted_UMI.fastq.gz



zcat extracted_UMI.fastq.gz | awk 'NR%4==2' > umi_list.txt
zcat extracted_UMI.fastq.gz | awk 'NR%4==0' > qual_list.txt

paste <(zcat ${input_fastq2} | awk 'NR%4==1') \
    umi_list.txt \
    qual_list.txt \
    <(zcat ${input_fastq2} | awk 'NR%4==2') \
    <(zcat ${input_fastq2} | awk 'NR%4==3') \
    <(zcat ${input_fastq2} | awk 'NR%4==0') | \
    
awk '{print $1"\n"$2$4"\n"$5"\n"$3$6}' | gzip > ${fast2_name}.modified.fastq.gz

rm -rf umi_list.txt
rm -rf qual_list.txt
rm -rf extracted_UMI.fastq.gz