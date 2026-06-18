#!/bin/bash
set -e

PROJECT_DIR="$HOME/wgs_pipeline"
cd "${PROJECT_DIR}"

ACCESSION="SRR2584863"
REF="reference/ecoli_rel606_reference.fasta"

echo "============================================================"
echo "Step 6a: Generating genotype likelihoods (mpileup)"
echo "============================================================"

bcftools mpileup -f "${REF}" aligned/"${ACCESSION}"_sorted.bam \
    -O b -o variants/"${ACCESSION}"_raw.bcf

echo ""
echo "============================================================"
echo "Step 6b: Calling variants (haploid, since E. coli is haploid)"
echo "============================================================"

bcftools call -mv --ploidy 1 -Oz -o variants/"${ACCESSION}"_calls.vcf.gz variants/"${ACCESSION}"_raw.bcf
bcftools index -f variants/"${ACCESSION}"_calls.vcf.gz

echo ""
echo "============================================================"
echo "Step 6c: Basic filtering (quality >= 20)"
echo "============================================================"

bcftools filter -e 'QUAL<20' variants/"${ACCESSION}"_calls.vcf.gz -Oz \
    -o variants/"${ACCESSION}"_filtered.vcf.gz
bcftools index -f variants/"${ACCESSION}"_filtered.vcf.gz

echo ""
echo "============================================================"
echo "Step 6d: Variant summary"
echo "============================================================"

TOTAL_RAW=$(bcftools view -H variants/"${ACCESSION}"_calls.vcf.gz | wc -l)
TOTAL_FILTERED=$(bcftools view -H variants/"${ACCESSION}"_filtered.vcf.gz | wc -l)
SNPS=$(bcftools view -v snps -H variants/"${ACCESSION}"_filtered.vcf.gz | wc -l)
INDELS=$(bcftools view -v indels -H variants/"${ACCESSION}"_filtered.vcf.gz | wc -l)

{
echo "Total variants called (pre-filter): ${TOTAL_RAW}"
echo "Total variants (QUAL>=20):           ${TOTAL_FILTERED}"
echo "SNPs (QUAL>=20):                     ${SNPS}"
echo "INDELs (QUAL>=20):                   ${INDELS}"
} | tee results/variant_summary.txt
