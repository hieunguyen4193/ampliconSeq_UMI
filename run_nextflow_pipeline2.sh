# nextflow on conda in my home server
source /home/hieunguyen/miniconda3/bin/activate && conda activate nextflow_dev
# conda install -c bioconda nextflow -y

#-----
# input args

# samplesheet="./SampleSheet.csv";
# samplesheet="./SampleSheet.2.csv";
samplesheet="./SampleSheet.3.csv";
# samplesheet="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/SampleSheets/SampleSheet_R7288.csv";
OUTDIR="./output";
# OUTDIR="/media/hieunguyen/HNHD01/outdir/ampliconSeq/R7288"
mkdir -p ${OUTDIR};

BismarkIndex="/media/hieunguyen/GSHD_HN01/storage/resources/hg19_bismark/";
min_reads=3;
consensus_rate=0.6;
umi_length=6;
primer_version="20250526";
extract_UMI_from_R1_sh="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/src/extract_UMI_from_R1.sh"
add_UMI_to_R1_R2_FASTQs_sh="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/src/add_UMI_to_R1_R2_FASTQS.sh"
forward_primer_fa="./primers/${primer_version}/forward_primers.fa";
reverse_primer_fa="./primers/${primer_version}/reverse_primers.fa";
# workdir="/media/hieunguyen/HNSD01/tmp_nextflow_work";
workdir="./work"

nextflow run main.nf \
    --SAMPLE_SHEET "$samplesheet" \
    --OUTDIR "$OUTDIR" \
    --BismarkIndex "$BismarkIndex" \
    --min_reads "$min_reads" \
    --consensus_rate "$consensus_rate" \
    --umi_length "$umi_length" \
    --forward_primer_fa "$forward_primer_fa" \
    --reverse_primer_fa "$reverse_primer_fa" \
    --extract_UMI_from_R1 "${extract_UMI_from_R1_sh}" \
    --add_UMI_to_R1_R2_FASTQS "${add_UMI_to_R1_R2_FASTQs_sh}" \
    -resume -c ./dev.config -w ${workdir}