# nextflow on conda in my home server
source /home/hieunguyen/miniconda3/bin/activate && conda activate nextflow_dev
# conda install -c bioconda nextflow -y

#-----
# input args

samplesheet="./SampleSheet.csv";
OUTDIR="./output";
BismarkIndex="";
min_reads=3;
consensus_rate=0.6;
umi_length=6;

nextflow run main.nf \
    --SAMPLE_SHEET "$samplesheet" \
    --OUTDIR "$OUTDIR" \
    --BismarkIndex "$BismarkIndex" \
    --min_reads "$min_reads" \
    --consensus_rate "$consensus_rate" \
    --umi_length "$umi_length" \
    -resume -c ./dev.config