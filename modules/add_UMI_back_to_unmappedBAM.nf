process  add_UMI_back_to_unmappedBAM {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), path(unmapped_bam)
        file (add_UMI_to_unmappedBAM)
        
    output:
        tuple val(sample_id), path("*.addedUMIback.bam"), emit: added_UMI_unmapped_bam
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    bash ${add_UMI_to_unmappedBAM} -i ${unmapped_bam} -o .
    """
}

// EOF