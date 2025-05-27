process  add_UMI_to_R2_seqs {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";

    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
        val umi_length
        file add_UMI_to_R2_seqs_sh
    output:
        tuple val(sample_id), path(fastq1), path("${sample_id}_R2.modified.fastq.gz"), emit: input_modified_fastqs_ch

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    bash ${add_UMI_to_R2_seqs_sh} -f ${fastq1} -r ${fastq2} -u ${umi_length} -o .
    """
}