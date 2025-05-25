# nextflow on conda in my home server
source /home/hieunguyen/miniconda3/bin/activate && conda activate nextflow_dev
# conda install -c bioconda nextflow -y

#-----
# input args

samplesheet="./SampleSheet.csv";
OUTDIR="./output";
BismarkIndex="/media/hieunguyen/GSHD_HN01/storage/resources/hg19_bismark/";
min_reads=3;
consensus_rate=0.6;
umi_length=6;
add_UMI_to_R2_seqs_sh="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/src/add_UMI_to_R2_FASTQ.sh";

nextflow run main.nf \
    --SAMPLE_SHEET "$samplesheet" \
    --OUTDIR "$OUTDIR" \
    --BismarkIndex "$BismarkIndex" \
    --min_reads "$min_reads" \
    --consensus_rate "$consensus_rate" \
    --umi_length "$umi_length" \
    --add_UMI_to_R2_seqs_sh ${add_UMI_to_R2_seqs_sh} \
    -resume -c ./dev.config