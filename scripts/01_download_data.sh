#!/bin/bash
set -e

PROJECT_DIR="$HOME/wgs_pipeline"
mkdir -p "${PROJECT_DIR}"/{raw_data,reference,trimmed,aligned,variants,results,figures}
cd "${PROJECT_DIR}"

ACCESSION="SRR2584863"

echo "Downloading raw reads directly from ENA (bypassing prefetch/SDL)..."
cd raw_data

wget -nv "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR258/003/${ACCESSION}/${ACCESSION}_1.fastq.gz"
wget -nv "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR258/003/${ACCESSION}/${ACCESSION}_2.fastq.gz"

echo "Raw reads downloaded:"
ls -lh "${ACCESSION}"_*.fastq.gz

echo ""
echo "Downloading E. coli K-12 MG1655 reference genome..."
cd ../reference
wget -nv "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz"
gunzip -f GCF_000005845.2_ASM584v2_genomic.fna.gz
mv GCF_000005845.2_ASM584v2_genomic.fna ecoli_k12_reference.fasta
echo "Reference genome downloaded:"
ls -lh ecoli_k12_reference.fasta

READ_COUNT=$(zcat ../raw_data/"${ACCESSION}"_1.fastq.gz | wc -l)
READ_COUNT=$((READ_COUNT / 4))
echo "Read pairs: ${READ_COUNT}"
GENOME_LEN=$(grep -v "^>" ecoli_k12_reference.fasta | tr -d '\n' | wc -c)
echo "Reference genome length: ${GENOME_LEN} bp"
