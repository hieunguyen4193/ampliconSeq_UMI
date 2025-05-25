process  FGBIO_FASTQ_TO_BAM {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    publishDir "$params.OUTDIR/FGBIO_FASTQ_TO_BAM"  , mode: "copy"
    label 'fgbio'

    input:
        tuple val(sample_id), path(fastq1), path(fastq2)
    output:
        tuple val(sample_id), file("${sample_id}.unmapped.bam")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    fgbio -Xmx1g --compression 1 --async-io FastqToBam \
    --input ${fastq1} ${fastq2} \
    --read-structures ${params.read_structure} \
    --sample ${sample_id} \
    --library library1 \
    --platform-unit ABCDEAAXX.1 \
    --output ${sample_id}.unmapped.bam
    """
}