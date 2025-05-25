process  FGBIO_UBAM_TO_MAPPED_BAM {
    // FastQC quality control for sequencing reads
    tag "$sample_id"
    cache "deep";
    publishDir "$params.OUTDIR/FGBIO_UBAM_TO_MAPPED_BAM"  , mode: "copy"
    label 'fgbio'

    input:
        tuple val(sample_id), file(uBAM)
        file(bwa_ref_genome)
    output:
        tuple val(sample_id), file("${sample_id}.mapped.bam")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    samtools fastq -1 ${sample_id}_R1.tmp.fastq -2 ${sample_id}_R2.tmp.fastq ${uBAM};
    bwa mem -t 16 -p -K 150000000 -Y ${bwa_ref_genome} ${sample_id}_R1.tmp.fastq ${sample_id}_R2.tmp.fastq > tmp.sam
    samtolls view -bS -o tmp.bam tmp.sam
    rm -rf ${sample_id}_R1.tmp.fastq;
    rm -rf ${sample_id}_R2.tmp.fastq;

    fgbio -Xmx4g --compression 1 --async-io ZipperBams \
      --input tmp.bam \
      --unmapped ${uBAM} \
      --ref ${bwa_ref_genome} \
      --output ${sample_id}.mapped.bam
    """
}