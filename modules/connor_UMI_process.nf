process  connor_UMI_process {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    publishDir "$params.OUTDIR/connor_bam"  , mode: "copy"
    label 'bismark_alignment'

    input:
        tuple val(sample_id), file(bismark_bam)
        val min_reads
        val consensus_rate
        val umi_length
    output:
        tuple val(sample_id), path("${sample_id}.connor.bam")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    connor ${bismark_bam} ${sample_id}.connor.bams -s ${min_reads} -f ${consensus_rate} --umt_length ${umi_length} 
    """
}