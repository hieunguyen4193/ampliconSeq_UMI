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
        tuple val(sample_id), path("${sample_id}_R1.UMIprocessed.fastq.gz"), path("${sample_id}_R2.UMIprocessed.fastq.gz"), emit: CutAdapt_fastqs_with_UMI
        tuple val(sample_id), path("${sample_id}.CutAdapt_R1.fastq.gz"), path("${sample_id}.CutAdapt_R2.fastq.gz"), emit: CutAdapt_fastqs
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

    # trim adapters and primers from reads, input a list of forward and reverse primers
    cutadapt -g file:${forward_primer_fa} -o ${sample_id}.CutAdapt_R1.fastq.gz ${fastq1}
    cutadapt -g file:${reverse_primer_fa} -o ${sample_id}.CutAdapt_R2.fastq.gz ${fastq2}

    # add the UMI back to both R1 and R2 reads
    bash ${add_UMI_to_R1_R2_FASTQS} \
        -f ${sample_id}.CutAdapt_R1.fastq.gz \
        -r ${sample_id}.CutAdapt_R2.fastq.gz \
        -u umi_list.txt \
        -q qual_list.txt \
        -o . \
        -s ${sample_id}
    """
}

// EOF