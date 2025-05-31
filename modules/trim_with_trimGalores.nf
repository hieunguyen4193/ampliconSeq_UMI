process  trimGalore {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
    output:
        tuple val(sample_id), path("${sample_id}.trimGalore_R1.fastq.gz"), path("${sample_id}.trimGalore_R2.fastq.gz"), emit: trimmed_fastqs

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    trim_galore \
        --fastqc \
        --gzip \
        --paired \
        ${fastq1} ${fastq2} \
        --cores ${params.TrimCores} \
        --basename ${sample_id}.trimGalore \
        --clip_r1 ${params.TrimClipR1} \
        --clip_r2 ${params.TrimClipR2}
    """
}