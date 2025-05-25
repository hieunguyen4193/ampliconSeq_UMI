#!/bin/bash -ue
multiqc -f -o . -n multiQC_report.html *.zip
