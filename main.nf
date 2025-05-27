#!/usr/bin/env nextflow
/*
NEXTFLOW DSL 2 pipeline for single cell data analysis
This pipeline is designed to process single-cell RNA sequencing data using the 10X Genomics Cell Ranger pipeline.

tronghieunguyen@pm.me
*/

// enable nextflow DSL2

nextflow.enable.dsl = 2

// include { PIPELINE1 } from "./workflows/pipeline1.nf"
include { PIPELINE2 } from "./workflows/pipeline2.nf"

workflow {

    main:
    // PIPELINE1(
    //     file(params.SAMPLE_SHEET),
    //     params.bwa_ref_genome,
    //     params.fgbio_min_reads,
    //     params.fgbio_min_input_base_quality,
    //     params.fgbio_min_base_quality,
    //     params.fgbio_min_base_error_rate,
    //     params.FGBIO_FASTQ_TO_BAM_threads
    // )       

    PIPELINE2(
        file(params.SAMPLE_SHEET),
        file(params.BismarkIndex),
        params.min_reads,
        params.consensus_rate,
        params.umi_length,
        file(params.forward_primer_fa),
        file(params.reverse_primer_fa),
        file(params.extract_UMI_from_R1),
        file(params.add_UMI_to_R1_R2_FASTQS)
    )
}