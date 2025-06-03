process  extract_UMI_from_R1_only {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
        val(umi_length)
        file(extract_UMI_from_R1)
    output:
        tuple val(sample_id), path("${sample_id}.UMI.txt"), emit: UMI_list
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    # Extract UMI from R1 and create list of UMIs and qualities (phred score letters)
    bash ${extract_UMI_from_R1} \
        -f ${fastq1} \
        -r ${fastq2} \
        -u ${umi_length} \
        -o .

    mv umi_list.txt ${sample_id}.UMI.txt
    """
}

// EOF