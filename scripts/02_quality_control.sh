#!/bin/bash
set -e

PROJECT_DIR="$HOME/wgs_pipeline"
cd "${PROJECT_DIR}"
ACCESSION="SRR2584863"
mkdir -p results/fastqc_raw

fastqc raw_data/"${ACCESSION}"_1.fastq.gz raw_data/"${ACCESSION}"_2.fastq.gz \
    -o results/fastqc_raw --threads 2

echo "FastQC complete. Open these HTML reports:"
ls results/fastqc_raw/*.html
echo "Check: per-base quality (green zone, Q>28), adapter content, length distribution."
