process  trim_CutAdapt {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    publishDir "$params.OUTDIR/trimCutAdapt"  , mode: "copy"
    label 'trimming'

    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
        val(forward_primer_fa)
        val(reverse_primer_fa)
    output:
        tuple val(sample_id), path("${sample_id}.trimmed_R1.fastq.gz"), path("${sample_id}.trimmed_R2.fastq.gz"), emit: trimmed_fastqs

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    cutadapt -a file:${forward_primer_fa} -o ${sample_id}.trimmed_R1.fastq.gz $fastq1
    cutadapt -a file:${reverse_primer_fa} -o ${sample_id}.trimmed_R2.fastq.gz $fastq2
    """
}