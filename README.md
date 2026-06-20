# E. coli Whole Genome Sequencing Pipeline

An automated, end-to-end WGS analysis pipeline built on Linux (WSL2/Ubuntu), processing raw Illumina paired-end sequencing data through quality control, trimming, alignment, and variant calling.

## Dataset

- **Sample**: SRR2584863 (NCBI SRA, downloaded via ENA)
- **Organism**: *Escherichia coli*, from a long-term evolution experiment population
- **Reference genome**: *E. coli* B str. REL606 (NCBI assembly GCA_000017985.1)

## Pipeline Overview

1. **Data acquisition** — raw FASTQ reads and reference genome downloaded directly via HTTPS (ENA/NCBI)
2. **Quality control** — FastQC on raw reads
3. **Adapter/quality trimming** — Trimmomatic (paired-end mode)
4. **Alignment** — Bowtie2 against the REL606 reference genome
5. **BAM processing** — SAMtools (sort, index, flagstat, coverage)
6. **Variant calling** — BCFtools (haploid-aware genotype calling, QUAL≥20 filtering)
7. **Visualization** — Python (matplotlib) summary figures

## Results

| Metric | Value |
|---|---|
| Raw read pairs | 1,553,259 |
| Reads surviving trimming | 90.74% |
| Overall alignment rate | 91.88% |
| Mean coverage depth | 77.4x |
| Genome breadth covered | 99.85% |
| Variants called (QUAL≥20) | 31 (18 SNPs, 13 INDELs) |

## Notable Debugging Step

Initial alignment against the standard *E. coli* K-12 MG1655 reference produced an unexpectedly low concordant-pairing rate (~85% overall alignment, ~23% concordant). Investigation revealed this sample originates from a long-term evolution study whose correct reference is *E. coli* B str. REL606, not K-12. Re-aligning against REL606 improved the result to 91.88% overall alignment. Genotype calling was also corrected from an initially incorrect diploid assumption to the biologically correct haploid model for this organism.

## Tools Used

SRA download (ENA/wget), FastQC, Trimmomatic, Bowtie2, SAMtools, BCFtools, Python (pandas, matplotlib)

## Repository Structure
