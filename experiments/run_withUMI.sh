# nextflow on conda in my home server
source /home/hieunguyen/miniconda3/bin/activate && conda activate nextflow_dev

# conda env export > environment_nextflow_dev.yml
# conda env create -f environment_nextflow_dev.yml

#-----
# input args

samplesheet="./SampleSheet_noUMI_runs.csv";
OUTDIR="/workdir/outdir";
WORKDIR="/workdir/work"; 
UMI_in_read_or_not="withoutUMI";

BATCH_NAME=$(echo $samplesheet | xargs -n 1 basename | cut -d '.' -f 1); 

echo -e "-----"
echo -e "Working on batch: ${BATCH_NAME}\n";
echo -e "-----"

OUTDIR="${OUTDIR}/${BATCH_NAME}"
mkdir -p ${OUTDIR};

WORKDIR="${WORKDIR}/${BATCH_NAME}";
mkdir -p ${WORKDIR};

BismarkIndex="/workdir/resources/hg19";
primer_version="20250526";
forward_primer_fa="./primers/${primer_version}/Vi_Lung_panel.forward_primers.fa";
reverse_primer_fa="./primers/${primer_version}/Vi_Lung_panel.reverse_primers.fa";
min_family_size_threshold=3;
consensus_rate=0.6;
umi_length=6;
umt_distance_threshold=1;
extract_UMI_from_R1_sh="../src/extract_UMI_from_R1.sh"
add_UMI_to_R1_R2_FASTQs_sh="../src/add_UMI_to_R1_R2_FASTQS.sh"

OUTDIR="${OUTDIR}/${BATCH_NAME}/UMT_DISTANCE_${umt_distance_threshold}"
mkdir -p ${OUTDIR};

WORKDIR="${WORKDIR}/${BATCH_NAME}/UMT_DISTANCE_${umt_distance_threshold}";
mkdir -p ${WORKDIR};

nextflow run main.nf \
        --SAMPLE_SHEET "${samplesheet}" \
        --OUTDIR "${OUTDIR}" \
        --BismarkIndex "${BismarkIndex}" \
        --min_family_size_threshold "${min_family_size_threshold}" \
        --consensus_rate "${consensus_rate}" \
        --umi_length "${umi_length}" \
        --umt_distance_threshold "${umt_distance_threshold}" \
        --forward_primer_fa "${forward_primer_fa}" \
        --reverse_primer_fa "${reverse_primer_fa}" \
        --extract_UMI_from_R1 "${extract_UMI_from_R1_sh}" \
        --add_UMI_to_R1_R2_FASTQS "${add_UMI_to_R1_R2_FASTQs_sh}" \
        -resume -c ./configs/main.config \
        -w ${WORKDIR} \
        -with-report "${OUTDIR}/report.html" \
        -with-timeline "${OUTDIR}/timeline.html" \
        -with-dag "${OUTDIR}/dag.svg";

# loggings all input params
echo -e "-----------------------------------------------------------------------------" >> ${OUTDIR}/params.log
echo -e "NEXTFLOW AMPLICON BISULFITE SEQUENCING PIPELINE\n" >> ${OUTDIR}/params.log
echo -e "-----------------------------------------------------------------------------" >> ${OUTDIR}/params.log
echo "Pipeline version: 20250526" >> ${OUTDIR}/params.log
echo "Pipeline run date: $(date)" >> ${OUTDIR}/params.log
echo "-----------------------------------------------------------------------------" >> ${OUTDIR}/params.log
echo "Input parameters:" >> ${OUTDIR}/params.log
echo "SAMPLE_SHEET: $samplesheet" >> ${OUTDIR}/params.log
echo "OUTDIR: $OUTDIR" >> ${OUTDIR}/params.log
echo "BismarkIndex: $BismarkIndex" >> ${OUTDIR}/params.log
echo "min_family_size_threshold: $min_family_size_threshold" >> ${OUTDIR}/params.log
echo "consensus_rate: $consensus_rate" >> ${OUTDIR}/params.log
echo "umi_length: $umi_length" >> ${OUTDIR}/params.log
echo "umt_distance_threshold: $umt_distance_threshold" >> ${OUTDIR}/params.log
echo "forward_primer_fa: $forward_primer_fa" >> ${OUTDIR}/params.log
echo "reverse_primer_fa: $reverse_primer_fa" >> ${OUTDIR}/params.log
echo "extract_UMI_from_R1: $extract_UMI_from_R1_sh" >> ${OUTDIR}/params.log
echo "add_UMI_to_R1_R2_FASTQs: $add_UMI_to_R1_R2_FASTQs_sh" >> ${OUTDIR}/params.log
echo "workdir: $workdir" >> ${OUTDIR}/params.log
echo -e "-----------------------------------------------------------------------------" >> ${OUTDIR}/params.log

