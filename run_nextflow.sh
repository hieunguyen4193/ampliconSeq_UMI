# nextflow on conda in my home server
source /home/hieunguyen/miniconda3/bin/activate && conda activate nextflow_dev
# conda install -c bioconda nextflow -y

#-----
# input args

samplesheet="./SampleSheet.csv"
OUTDIR="./output"
nextflow run main.nf \
    --SAMPLE_SHEET "$samplesheet" \
    --OUTDIR "$OUTDIR" \
    -resume -c ./dev.config