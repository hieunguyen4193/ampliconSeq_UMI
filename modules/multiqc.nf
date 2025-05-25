process  multiqc {
    // FastQC quality control for sequencing reads
    cache "deep";
    publishDir "$params.OUTDIR/01_multiQC"  , mode: "copy"
    label 'fastqc'

    input:
        file(fastqcs)
    output:
        path("multiQC_report*")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
     multiqc -f -o . -n multiQC_report.html *.zip
    """
}