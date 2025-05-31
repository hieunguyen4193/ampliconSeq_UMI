include { trim_CutAdapt } from '../modules/trim_with_CutAdapt.nf'
include { fastqc as fastqc_after_trim} from '../modules/fastqc.nf'

workflow TRIM {
    take:
        input_fastq_ch 
        forward_primer_fa
        reverse_primer_fa
    main:
        trim_CutAdapt(
            input_fastq_ch,
            forward_primer_fa,
            reverse_primer_fa
        )
    fastqc_outputs = fastqc_after_trim(trim_CutAdapt.trimmed_fastqs)
    multiqc( fastqc_outputs.fastqc_zip.collect() )

    emit:
    trimmed_fastqs = trim_CutAdapt.out.trimmed_fastqs
     // emit to the samplesheet channel, use as input for other downstream processes
}