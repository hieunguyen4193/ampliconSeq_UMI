process  fastqc {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
    output:
        tuple path("*R1*.html"), path("*R2*.html"), emit: fastqc_html
        tuple path("*R1*.zip"), path("*R2*.zip"), emit: fastqc_zip

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    fastqc -t $params.FASTQC_CPU --quiet --outdir . ${fastq1} ${fastq2}
    """
}