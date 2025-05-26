process  trim_CutAdapt_AmpliconMethylUMI {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
        val(umi_length)
        file(forward_primer_fa)
        file(reverse_primer_fa)
        file(extract_UMI_from_R1)
        file(add_UMI_to_R1_R2_FASTQS)
    output:
        tuple val(sample_id), path("${sample_id}_R1.modified.fastq.gz"), path("${sample_id}_R2.modified.fastq.gz")
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    bash ${extract_UMI_from_R1} \
        -f ${fastq1} \
        -r ${fastq2} \
        -u ${umi_length} \
        -o .

    cutadapt -g file:${forward_primer_fa} -o ${sample_id}.trimmed_R1.fastq.gz ${fastq1}
    cutadapt -g file:${reverse_primer_fa} -o ${sample_id}.trimmed_R2.fastq.gz ${fastq2}

    bash ${add_UMI_to_R1_R2_FASTQS} \
        -f ${sample_id}.trimmed_R1.fastq.gz \
        -r ${sample_id}.trimmed_R2.fastq.gz \
        -u umi_list.txt \
        -q qual_list.txt \
        -o . \
        -s ${sample_id}
    """
}

// EOF