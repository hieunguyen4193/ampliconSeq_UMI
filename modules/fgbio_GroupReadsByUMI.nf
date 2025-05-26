process  FGBIO_GROUP_READS_BY_UMI {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    
    input:
        tuple val(sample_id), file(mBAM)
    output:
        tuple val(sample_id), file("${sample_id}.grouped.bam")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    fgbio -Xmx8g --compression 1 --async-io GroupReadsByUmi \
        --input ${mBAM} \
        --strategy Adjacency \
        --edits 1 \
        --output ${sample_id}.grouped.bam \
        --family-size-histogram ${sample_id}.tag-family-sizes.txt
    """
}