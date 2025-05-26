process  connor_UMI_process {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), file(bismark_bam)
        val min_reads
        val consensus_rate
        val umi_length
    output:
        tuple val(sample_id), path("${sample_id}.connor_R1.fastq.gz"), path("${sample_id}.connor_R2.fastq.gz"), emit: connor_fastqs
        tuple val(sample_id), path("${sample_id}.connor.bam"), emit: connor_bam
        tuple val(sample_id), path("${sample_id}.connor.fully_annotated.bam"), emit: full_connor_bam
        tuple val(sample_id), path("${sample_id}.connor.log"), emit: log_connor

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    samtools sort ${bismark_bam} -o ${sample_id}.bismark.sorted.bam;
    samtools index ${sample_id}.bismark.sorted.bam;
    connor ${sample_id}.bismark.sorted.bam \
        ${sample_id}.connor.bam \
        -s ${min_reads} \
        -f ${consensus_rate} \
        --umt_length ${umi_length} \
        --annotated_output_bam  ${sample_id}.connor.fully_annotated.bam \
        --log_file ${sample_id}.connor.log --force;
         

    samtools fastq \
        -1 ${sample_id}.connor_R1.fastq.gz \
        -2 ${sample_id}.connor_R2.fastq.gz \
        ${sample_id}.connor.bam;
    """
}