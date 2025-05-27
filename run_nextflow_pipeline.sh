# nextflow on conda in my home server
source /home/hieunguyen/miniconda3/bin/activate && conda activate nextflow_dev
# conda install -c bioconda nextflow -y

#-----
# input args

# samplesheet="./SampleSheet.csv";
# samplesheet="./SampleSheet.2.csv";
# samplesheet="./SampleSheet.3.csv";
# samplesheet="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/SampleSheets/SampleSheet_R7288.csv";
# samplesheet="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/SampleSheets/SampleSheet_R7297.csv";
# samplesheet="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/SampleSheets/SampleSheet_R7312.csv";
# OUTDIR="./output";

samplesheet="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/SampleSheets/SampleSheet_R7288.head5.csv";
batch_name=$(echo $samplesheet | xargs -n 1 basename | cut -d '.' -f 1); 

echo -e "-----"
echo -e "Working on batch: ${batch_name}\n";
echo -e "-----"

OUTDIR="/media/hieunguyen/HNHD01/outdir/ampliconSeq/${batch_name}"
mkdir -p ${OUTDIR};

BismarkIndex="/media/hieunguyen/GSHD_HN01/storage/resources/hg19_bismark/";
min_family_size_threshold=3;
umt_distance_threshold=0;
consensus_rate=0.6;
umi_length=6;
primer_version="20250526";
extract_UMI_from_R1_sh="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/src/extract_UMI_from_R1.sh"
add_UMI_to_R1_R2_FASTQs_sh="/media/hieunguyen/HNSD01/src/ampliconSeq_UMI/src/add_UMI_to_R1_R2_FASTQS.sh"
forward_primer_fa="./primers/${primer_version}/forward_primers.fa";
reverse_primer_fa="./primers/${primer_version}/reverse_primers.fa";
workdir="/media/hieunguyen/HNSD01/${batch_name}";
# workdir="./work"

for processing_umi_or_not in withUMI withoutUMI; do \
    nextflow run main.nf \
        --SAMPLE_SHEET "$samplesheet" \
        --OUTDIR "$OUTDIR" \
        --BismarkIndex "$BismarkIndex" \
        --min_family_size_threshold "$min_family_size_threshold" \
        --consensus_rate "$consensus_rate" \
        --umi_length "$umi_length" \
        --umt_distance_threshold "${umt_distance_threshold}" \
        --forward_primer_fa "$forward_primer_fa" \
        --reverse_primer_fa "$reverse_primer_fa" \
        --extract_UMI_from_R1 "${extract_UMI_from_R1_sh}" \
        --add_UMI_to_R1_R2_FASTQS "${add_UMI_to_R1_R2_FASTQs_sh}" \
        --processing_umi_or_not "${processing_umi_or_not}" \
        -resume -c ./configs/main.config -w ${workdir} \
        -with-report "${OUTDIR}/report.html" \
        -with-timeline "${OUTDIR}/timeline.html" \
        -with-dag "${OUTDIR}/dag.svg";
    done

# loggings all input params
echo -e "-----------------------------------------------------------------------------" >> -${OUTDIR}/params.log
echo -e "NEXTFLOW AMPLICON BISULFITE SEQUENCING PIPELINE\n" >> -${OUTDIR}/params.log
echo -e "-----------------------------------------------------------------------------" >> -${OUTDIR}/params.log
echo "Pipeline version: 20250526" >> -${OUTDIR}/params.log
echo "Pipeline run date: $(date)" >> -${OUTDIR}/params.log
echo "-----------------------------------------------------------------------------" >> -${OUTDIR}/params.log
echo "Input parameters:" >> -${OUTDIR}/params.log
echo "SAMPLE_SHEET: $samplesheet" >> -${OUTDIR}/params.log
echo "OUTDIR: $OUTDIR" >> -${OUTDIR}/params.log
echo "BismarkIndex: $BismarkIndex" >> -${OUTDIR}/params.log
echo "min_family_size_threshold: $min_family_size_threshold" >> -${OUTDIR}/params.log
echo "consensus_rate: $consensus_rate" >> -${OUTDIR}/params.log
echo "umi_length: $umi_length" >> -${OUTDIR}/params.log
echo "umt_distance_threshold: $umt_distance_threshold" >> -${OUTDIR}/params.log
echo "forward_primer_fa: $forward_primer_fa" >> -${OUTDIR}/params.log
echo "reverse_primer_fa: $reverse_primer_fa" >> -${OUTDIR}/params.log
echo "extract_UMI_from_R1: $extract_UMI_from_R1_sh" >> -${OUTDIR}/params.log
echo "add_UMI_to_R1_R2_FASTQs: $add_UMI_to_R1_R2_FASTQs_sh" >> -${OUTDIR}/params.log
echo "workdir: $workdir" >> -${OUTDIR}/params.log
echo -e "-----------------------------------------------------------------------------" >> -${OUTDIR}/params.log