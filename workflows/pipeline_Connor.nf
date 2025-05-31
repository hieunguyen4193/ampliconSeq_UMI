// include MODULES
include { fastqc } from "../modules/fastqc.nf"
include { multiqc } from "../modules/multiqc.nf"

// include SUB-WORKFLOWS
include { FASTQ_QC } from "../subworkflows/QC.nf"
include { PIPELINE_INIT } from "../subworkflows/pipeline_init.nf"
include { PROCESS_UMI_AND_TRIM } from "../subworkflows/process_UMI_and_trim.nf"
include { CONNOR_UMI_PROCESSING } from "../subworkflows/UMI_processing_with_connor.nf"
include { ALIGNMENT_AND_METHYLATION_CALLING as ALIGNMENT_AND_METHYLATION_CALLING_WITH_UMI } from "../subworkflows/bismark_methylation_calling.nf"

// MAIN WORKFLOW: INPUT FASTQS --> PREPROCESS THE UMI --> ALIGN AND CALL METHYLATION
workflow PIPELINE_CONNOR{
    take:
        input_SampleSheet // path to the input samplesheet .csv file, the sampleshet file should contain the columns SampleID, FASTQ1, and FASTQ2
        BismarkIndex
        consensus_rate
        umi_length
        forward_primer_fa
        reverse_primer_fa
        extract_UMI_from_R1
        add_UMI_to_R1_R2_FASTQS
        min_family_size_threshold
        umt_distance_threshold

    main:
        PIPELINE_INIT(
            input_SampleSheet
        )   
        FASTQ_QC(
            PIPELINE_INIT.out.samplesheet
        )
        PROCESS_UMI_AND_TRIM(
            PIPELINE_INIT.out.samplesheet,
            umi_length,
            forward_primer_fa,
            reverse_primer_fa,
            extract_UMI_from_R1,
            add_UMI_to_R1_R2_FASTQS
            )
        CONNOR_UMI_PROCESSING(
            PROCESS_UMI_AND_TRIM.out.trimmed_fastqs_with_UMI,
            BismarkIndex,
            consensus_rate,
            umi_length,
            min_family_size_threshold,
            umt_distance_threshold
            )
        FASTQ_QC(
            CONNOR_UMI_PROCESSING.out.connor_ch
        )
        // align and call methylation using the UMI processed reads
        ALIGNMENT_AND_METHYLATION_CALLING_WITH_UMI(
            CONNOR_UMI_PROCESSING.out.connor_ch,
            BismarkIndex
            )
        // align and call methylation using the trimmed reads without UMI
        ALIGNMENT_AND_METHYLATION_CALLING_WITHOUT_UMI(
            PROCESS_UMI_AND_TRIM.out.trimmed_fastqs,
            BismarkIndex
            )
}