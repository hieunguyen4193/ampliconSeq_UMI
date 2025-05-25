/*
 * Alignment with Cellranger
 */

include { FGBIO_FASTQ_TO_BAM } from "../modules/fgbio_FastqToBam.nf"
include { FGBIO_UBAM_TO_MAPPED_BAM } from "../modules/fgbio_UnmappedBAM_to_mappedBAM.nf"
include { FGBIO_GROUP_READS_BY_UMI } from "../modules/fgbio_GroupReadsByUMI.nf"
include { FGBIO_GROUPED_BAM_TO_CONSENSUS_U_BAM } from "../modules/fgbio_GroupedBAM_to_ConsensusUBAM.nf"

// Define workflow to subset and index a genome region fasta file
workflow FGBIO_UMI_PROCESSING {
    take:
        input_fastq_ch
        bwa_ref_genome
        min_reads
        min_input_base_quality
        min_base_quality
        min_base_error_rate
        FGBIO_FASTQ_TO_BAM_threads

    main:
        unmapped_bam = FGBIO_FASTQ_TO_BAM(input_fastq_ch)
        mapped_bam = FGBIO_UBAM_TO_MAPPED_BAM(unmapped_bam, bwa_ref_genome)
        grouped_bam = FGBIO_GROUP_READS_BY_UMI(mapped_bam)
        consensus_unmapped_bam = FGBIO_GROUPED_BAM_TO_CONSENSUS_U_BAM(
            grouped_bam, 
            bwa_ref_genome,
            min_reads,
            min_input_base_quality,
            min_base_quality,
            min_base_error_rate,
            FGBIO_FASTQ_TO_BAM_threads
            )

    emit:
        consensus_unmapped_bam_out = consensus_unmapped_bam.out
}   