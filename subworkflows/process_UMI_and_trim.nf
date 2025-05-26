include { trim_CutAdapt_AmpliconMethylUMI } from '../modules/trim_with_CutAdapt_for_AmpliconMethylUMI.nf'

workflow PROCESS_UMI_AND_TRIM {
    take:
        input_fastq_ch 
        umi_length
        forward_primer_fa
        reverse_primer_fa
        extract_UMI_from_R1
        add_UMI_to_R1_R2_FASTQS
    main:
        trim_CutAdapt_AmpliconMethylUMI(
            input_fastq_ch,
            umi_length,
            forward_primer_fa,
            reverse_primer_fa,
            extract_UMI_from_R1,
            add_UMI_to_R1_R2_FASTQS
        )
    
    emit:
    trim_out_ch = trim_CutAdapt_AmpliconMethylUMI.out // emit to the samplesheet channel, use as input for other downstream processes
}