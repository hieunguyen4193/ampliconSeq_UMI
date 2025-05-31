// include MODULES
include { fastqc } from "../modules/fastqc.nf"
include { multiqc } from "../modules/multiqc.nf"

// include SUB-WORKFLOWS
include { FASTQ_QC } from "../subworkflows/QC.nf"
include { PIPELINE_INIT } from "../subworkflows/pipeline_init.nf"
include { TRIM } from "../subworkflows/trim.nf"
include { ALIGNMENT_AND_METHYLATION_CALLING as ALIGNMENT_AND_METHYLATION_CALLING_NO_UMI } from "../subworkflows/bismark_methylation_calling.nf"

// MAIN WORKFLOW: INPUT FASTQS --> PREPROCESS THE UMI --> ALIGN AND CALL METHYLATION
workflow PIPELINE_NO_UMI{
    take:
        input_SampleSheet // path to the input samplesheet .csv file, the sampleshet file should contain the columns SampleID, FASTQ1, and FASTQ2
        BismarkIndex
        forward_primer_fa
        reverse_primer_fa
        
    main:
        PIPELINE_INIT(
            input_SampleSheet
        )   
        FASTQ_QC(
            PIPELINE_INIT.out.samplesheet
        )
        TRIM(
            PIPELINE_INIT.out.samplesheet,
            forward_primer_fa,
            reverse_primer_fa
        )
        FASTQ_QC(
            TRIM.out.trimmed_fastqs
        )        
        ALIGNMENT_AND_METHYLATION_CALLING_NO_UMI(
            TRIM.out.trimmed_fastqs,
            BismarkIndex
        )
}