// include MODULES
include { fastqc } from "../modules/fastqc.nf"
include { multiqc } from "../modules/multiqc.nf"

// include SUB-WORKFLOWS
include { FASTQ_QC } from "../subworkflows/QC.nf"
include { PIPELINE_INIT } from "../subworkflows/pipeline_init.nf"
include { CONNOR_UMI_PROCESSING } from "../subworkflows/UMI_processing_with_connor.nf"

//  PIPELINE 1 - DEBUG MODE     
//  MAIN WORKFLOW FOR PIPELINE 1 - DEBUG MODE
workflow PIPELINE2{
    take:
        input_SampleSheet // path to the input samplesheet .csv file, the sampleshet file should contain the columns SampleID, FASTQ1, and FASTQ2
        BismarkIndex
        min_reads
        consensus_rate
        umi_length

    main:
        PIPELINE_INIT(
            input_SampleSheet
        )

        FASTQ_QC(
            PIPELINE_INIT.out.samplesheet
        )

        CONNOR_UMI_PROCESSING(
            PIPELINE_INIT.out.samplesheet,
            BismarkIndex,
            min_reads,
            consensus_rate,
            umi_length
        )

}