#!/bin/bash
set -e

PROJECT_DIR="$HOME/wgs_pipeline"
cd "${PROJECT_DIR}"
ACCESSION="SRR2584863"

ADAPTER_FILE="/usr/share/trimmomatic/TruSeq3-PE.fa"
if [ ! -f "$ADAPTER_FILE" ]; then
    echo "WARNING: adapter file not found at $ADAPTER_FILE"
fi

TrimmomaticPE -threads 2 -phred33 \
    raw_data/"${ACCESSION}"_1.fastq.gz raw_data/"${ACCESSION}"_2.fastq.gz \
    trimmed/"${ACCESSION}"_1_paired.fastq.gz trimmed/"${ACCESSION}"_1_unpaired.fastq.gz \
    trimmed/"${ACCESSION}"_2_paired.fastq.gz trimmed/"${ACCESSION}"_2_unpaired.fastq.gz \
    ILLUMINACLIP:"${ADAPTER_FILE}":2:30:10 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
    2>&1 | tee results/trimmomatic_log.txt

mkdir -p results/fastqc_trimmed
fastqc trimmed/"${ACCESSION}"_1_paired.fastq.gz trimmed/"${ACCESSION}"_2_paired.fastq.gz \
    -o results/fastqc_trimmed --threads 2

echo "Trimming complete. Record '% surviving' from results/trimmomatic_log.txt"
