
include { bismark_alignment as bismark_for_processing_UMI} from "../modules/bismark_align.nf"
include { connor_UMI_process } from "../modules/connor_UMI_process.nf"
include { add_UMI_back_to_unmappedBAM } from "../modules/add_UMI_back_to_unmappedBAM.nf"
// Define workflow to subset and index a genome region fasta file
workflow CONNOR_UMI_PROCESSING {
    take:
        input_fastq_ch
        BismarkIndex
        consensus_rate
        umi_length
        min_family_size_threshold
        umt_distance_threshold
        add_UMI_to_unmappedBAM

    main:
        bismark_bam = bismark_for_processing_UMI(input_fastq_ch, BismarkIndex)
        added_UMI_bismark_bam = add_UMI_back_to_unmappedBAM(bismark_bam, add_UMI_to_unmappedBAM)
        connor_UMI_process(added_UMI_bismark_bam, consensus_rate, umi_length, min_family_size_threshold, umt_distance_threshold)
    emit:
        connor_ch = connor_UMI_process.out.connor_fastqs
}   