process  FGBIO_GROUPED_BAM_TO_CONSENSUS_U_BAM {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
       tuple val(sample_id), file("${sample_id}.grouped.bam")   
       file(bwa_ref_genome)
       val min_reads
       val min_input_base_quality
       val min_base_quality
       val min_base_error_rate
       val FGBIO_FASTQ_TO_BAM_threads
    output:
        tuple val(sample_id), file("${sample_id}.consensus.unmapped.bam")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    fgbio -Xmx4g --compression 0 CallMolecularConsensusReads \
    --input "${sample_id}.grouped.bam" \
    --output tmp.bam \
    --min-reads $min_reads \
    --min-input-base-quality ${min_input_base_quality}\
    --threads ${FGBIO_FASTQ_TO_BAM_threads} \
    |  fgbio -Xmx8g --compression 1 FilterConsensusReads \
        --input tmp.bam \
        --output "${sample_id}.consensus.unmapped.bam" \
        --ref ${bwa_ref_genome} \
        --min-reads ${min_reads} \
        --min-base-quality ${min_base_quality} \
        --max-base-error-rate ${min_base_error_rate}
    """
}