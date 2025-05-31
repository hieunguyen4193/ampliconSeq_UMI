include { trim_CutAdapt } from '../modules/trim_with_CutAdapt.nf'

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
    emit:
    trimmed_fastqs = trim_CutAdapt.out.trimmed_fastqs
     // emit to the samplesheet channel, use as input for other downstream processes
}