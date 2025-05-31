process  trim_CutAdapt {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
        file(forward_primer_fa)
        file(reverse_primer_fa)
    output:
        tuple val(sample_id), path("${sample_id}.CutAdapt_R1.fastq.gz"), path("${sample_id}.CutAdapt_R2.fastq.gz"), emit: CutAdapt_fastqs
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    # trim adapters and primers from reads, input a list of forward and reverse primers
    cutadapt -g file:${forward_primer_fa} -o ${sample_id}.CutAdapt_R1.fastq.gz ${fastq1}
    cutadapt -g file:${reverse_primer_fa} -o ${sample_id}.CutAdapt_R2.fastq.gz ${fastq2}
    """
}
