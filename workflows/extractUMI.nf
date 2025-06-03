include { PIPELINE_INIT } from "../subworkflows/pipeline_init.nf"
include { extract_UMI_from_R1_only } from "../modules/extract_UMI_from_R1_only.nf"
// MAIN WORKFLOW: INPUT FASTQS --> PREPROCESS THE UMI --> ALIGN AND CALL METHYLATION
workflow PIPELINE_EXTRACT_UMI_FROM_R1_ONLY{
    take:
        input_SampleSheet // path to the input samplesheet .csv file, the sampleshet file should contain the columns SampleID, FASTQ1, and FASTQ2
        umi_length
        extract_UMI_from_R1
        
    main:
        PIPELINE_INIT(
            input_SampleSheet
        )   
        extract_UMI_from_R1_only(
            PIPELINE_INIT.out.samplesheet,
            umi_length,
            extract_UMI_from_R1
        )
}