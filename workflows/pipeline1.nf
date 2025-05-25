// include MODULES
include { fastqc } from "../modules/fastqc.nf"
include { multiqc } from "../modules/multiqc.nf"

// include SUB-WORKFLOWS
include { FASTQ_QC } from "../subworkflows/QC.nf"
include { PIPELINE_INIT } from "../subworkflows/pipeline_init.nf"
include { FGBIO_UMI_PROCESSING } from "../subworkflows/UMI_processing_with_fgbio.nf"

//  PIPELINE 1 - DEBUG MODE     
//  MAIN WORKFLOW FOR PIPELINE 1 - DEBUG MODE
workflow PIPELINE1{
    take:
        input_SampleSheet // path to the input samplesheet .csv file, the sampleshet file should contain the columns SampleID, FASTQ1, and FASTQ2
        bwa_ref_genome
        min_reads
        min_input_base_quality
        min_base_quality
        min_base_error_rate
        FGBIO_FASTQ_TO_BAM_threads

    main:
        PIPELINE_INIT(
            input_SampleSheet
        )

        FASTQ_QC(
            PIPELINE_INIT.out.samplesheet
        )

        FGBIO_UMI_PROCESSING(
            PIPELINE_INIT.out.samplesheet,
            bwa_ref_genome,
            min_reads,
            min_input_base_quality,
            min_base_quality,
            min_base_error_rate,
            FGBIO_FASTQ_TO_BAM_threads
        )

}