#!/bin/bash
set -e

PROJECT_DIR="$HOME/wgs_pipeline"
cd "${PROJECT_DIR}"

ACCESSION="SRR2584863"
REF="reference/ecoli_rel606_reference.fasta"
INDEX_PREFIX="reference/ecoli_rel606_index"

echo "============================================================"
echo "Step 4a: Building Bowtie2 index (REL606 reference)"
echo "============================================================"

bowtie2-build "${REF}" "${INDEX_PREFIX}"

echo "Index files created:"
ls -lh reference/ecoli_rel606_index*

echo ""
echo "============================================================"
echo "Step 4b: Aligning trimmed reads to REL606 reference"
echo "============================================================"

bowtie2 -x "${INDEX_PREFIX}" \
    -1 trimmed/"${ACCESSION}"_1_paired.fastq.gz \
    -2 trimmed/"${ACCESSION}"_2_paired.fastq.gz \
    -p 2 \
    -S aligned/"${ACCESSION}".sam \
    2> results/bowtie2_alignment_summary.txt

echo ""
echo "Alignment complete:"
cat results/bowtie2_alignment_summary.txt
echo ""
echo "Record the 'overall alignment rate' line above for your report."
