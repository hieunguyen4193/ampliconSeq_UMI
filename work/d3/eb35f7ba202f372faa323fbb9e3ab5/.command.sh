#!/bin/bash -ue
fastqc -t null --quiet --outdir . 1-TML1S1_S7501-S7701_R1.fastq.gz 1-TML1S1_S7501-S7701_R2.fastq.gz
