#!/usr/bin/env nextflow
/*
NEXTFLOW DSL 2 pipeline for single cell data analysis
This pipeline is designed to process single-cell RNA sequencing data using the 10X Genomics Cell Ranger pipeline.

tronghieunguyen@pm.me
*/

// enable nextflow DSL2

nextflow.enable.dsl = 2

include { PIPELINE1 } from "./workflows/pipeline1.nf"

workflow {

    main:
    PIPELINE1(
        file(params.SAMPLE_SHEET)
    )       
}

