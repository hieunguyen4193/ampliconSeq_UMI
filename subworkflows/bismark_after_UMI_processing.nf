
include { bismark_alignment as bismark_after_UMI_processing } from "../modules/bismark_align.nf"
include { bismark_methylation_extractor } from "../modules/bismark_methylation_extractor.nf"

// Define workflow to subset and index a genome region fasta file
workflow ALIGNMENT_AND_METHYLATION_CALLING {
    take:
        input_fastq_ch
        BismarkIndex
    main:
        bismark_bam = bismark_after_UMI_processing(input_fastq_ch, BismarkIndex)
        methyl_density = bismark_methylation_extractor(bismark_bam)

    emit:
        methyl_density_ch = methyl_density       
}   