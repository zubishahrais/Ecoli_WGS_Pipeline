#!/bin/bash
set -e

PROJECT_DIR="$HOME/wgs_pipeline"
cd "${PROJECT_DIR}"

ACCESSION="SRR2584863"

echo "============================================================"
echo "Step 5a: Converting SAM to sorted BAM"
echo "============================================================"

samtools view -bS aligned/"${ACCESSION}".sam > aligned/"${ACCESSION}".bam
samtools sort aligned/"${ACCESSION}".bam -o aligned/"${ACCESSION}"_sorted.bam
samtools index aligned/"${ACCESSION}"_sorted.bam

echo "Sorted, indexed BAM created:"
ls -lh aligned/"${ACCESSION}"_sorted.bam*

rm -f aligned/"${ACCESSION}".sam aligned/"${ACCESSION}".bam

echo ""
echo "============================================================"
echo "Step 5b: Alignment statistics (flagstat)"
echo "============================================================"

samtools flagstat aligned/"${ACCESSION}"_sorted.bam | tee results/flagstat.txt

echo ""
echo "============================================================"
echo "Step 5c: Coverage statistics"
echo "============================================================"

samtools coverage aligned/"${ACCESSION}"_sorted.bam | tee results/coverage_summary.txt

samtools depth -a aligned/"${ACCESSION}"_sorted.bam > results/per_base_depth.txt

echo ""
echo "Mean coverage/breadth in results/coverage_summary.txt"
echo "============================================================"
echo "BAM processing and stats complete."
