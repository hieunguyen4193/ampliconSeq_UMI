
include { bismark_alignment as bismark_with_UMI} from "../modules/bismark_align.nf"
include { connor_UMI_process } from "../modules/connor_UMI_process.nf"
// Define workflow to subset and index a genome region fasta file
workflow CONNOR_UMI_PROCESSING {
    take:
        input_fastq_ch
        BismarkIndex
        min_reads
        consensus_rate
        umi_length

    main:
        bismark_bam = bismark_with_UMI(input_fastq_ch, BismarkIndex)
        connor_UMI_process(bismark_bam, min_reads, consensus_rate, umi_length)
    emit:
        connor_ch = connor_UMI_process.out.connor_fastqs
}   