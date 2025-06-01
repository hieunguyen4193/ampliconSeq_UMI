include { trim_CutAdapt } from '../modules/trim_with_CutAdapt.nf'
include { trim_Galore} from '../modules/trim_with_trimGalore.nf'
include { fastqc as fastqc_after_trim} from '../modules/fastqc.nf'
include { multiqc as multiqc_after_trim } from '../modules/multiqc.nf'

workflow TRIM {
    take:
        input_fastq_ch 
        forward_primer_fa
        reverse_primer_fa
        trim_algorithm
    main:
        if (trim_algorithm == "CutAdapt") {
            trim_output = trim_CutAdapt(
                input_fastq_ch,
                forward_primer_fa,
                reverse_primer_fa
            )
        } else if (trim_algorithm == "trimGalore"){
            trim_output = trim_Galore(
                input_fastq_ch
            )
        } else {
            error "Unknown trimming algorithm: ${trim_algorithm}. Please use 'CutAdapt' or 'trimGalore'."
        }

        fastqc_outputs = fastqc_after_trim(trim_output.trimmed_fastqs)
        multiqc_after_trim( fastqc_outputs.fastqc_zip.collect() )

    emit:
    trimmed_fastqs = trim_output.trimmed_fastqs
     // emit to the samplesheet channel, use as input for other downstream processes
}