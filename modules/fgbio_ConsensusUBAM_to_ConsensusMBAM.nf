process  FGBIO_CONSENSUS_U_BAM_TO_FASTQ {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    publishDir "$params.OUTDIR/FGBIO_CONSENSUS_U_BAM_TO_FASTQ"  , mode: "copy"
    label 'fgbio'

    input:
       tuple val(sample_id), file("${sample_id}.consensus.unmapped.bam")
       
    output:
        tuple val(sample_id), file("${sample_id}.consensus_R1.fastq.gz"), file("${sample_id}.consensus_R2.fastq.gz")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    samtools fastq -1 ${sample_id}.consensus_R1.fastq.gz -2 ${sample_id}.consensus_R2.fastq.gz ${sample_id}.consensus.unmapped.bam;
    """
}