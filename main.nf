#!/usr/bin/env nextflow
/*
NEXTFLOW DSL 2 pipeline for single cell data analysis
This pipeline is designed to process single-cell RNA sequencing data using the 10X Genomics Cell Ranger pipeline.

tronghieunguyen@pm.me
*/

// enable nextflow DSL2

nextflow.enable.dsl = 2

include { PIPELINE_CONNOR } from "./workflows/pipeline_Connor.nf"
include { PIPELINE_NO_UMI_V1_1 } from "./workflows/pipeline_noUMI_v1_1.nf"
include { PIPELINE_NO_UMI_V1_2 } from "./workflows/pipeline_noUMI_v1_2.nf"
include { PIPELINE_EXTRACT_UMI_FROM_R1_ONLY } from "./workflows/extractUMI.nf"

workflow {
    main:
    if (params.UMI_in_read_or_not == "withUMI") {
        PIPELINE_CONNOR(
            file(params.SAMPLE_SHEET),
            file(params.BismarkIndex),
            params.consensus_rate,
            params.umi_length,
            file(params.forward_primer_fa),
            file(params.reverse_primer_fa),
            file(params.extract_UMI_from_R1),
            file(params.add_UMI_to_R1_R2_FASTQS),
            params.min_family_size_threshold,
            params.umt_distance_threshold
        )
    } else if (params.UMI_in_read_or_not == "withoutUMI_V1") {
        PIPELINE_NO_UMI_V1_1(
            file(params.SAMPLE_SHEET),
            file(params.BismarkIndex),
            file(params.forward_primer_fa),
            file(params.reverse_primer_fa),
            params.trim_algorithm
        )
    } else if (params.UMI_in_read_or_not == "withoutUMI_V2") {
        PIPELINE_NO_UMI_V1_2(
            file(params.SAMPLE_SHEET),
            file(params.BismarkIndex),
            file(params.forward_primer_fa),
            file(params.reverse_primer_fa),
            params.trim_algorithm
        )
    } else if (params.UMI_in_read_or_not == "extractUMIonly") {
        PIPELINE_EXTRACT_UMI_FROM_R1_ONLY(
            file(params.SAMPLE_SHEET),
            params.umi_length,
            file(params.extract_UMI_from_R1)
        )
    }else {
        error "Invalid value for UMI_in_read_or_not: ${params.UMI_in_read_or_not}. Specify only 'withUMI' OR 'withoutUMI'."
    }
}