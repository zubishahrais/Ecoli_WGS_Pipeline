#!/bin/bash
set -e
echo "Setting up WGS pipeline environment (WSL2 Ubuntu)"
sudo apt-get update
sudo apt-get install -y fastqc trimmomatic bowtie2 samtools bcftools wget unzip default-jre python3-pip
if ! command -v fasterq-dump &> /dev/null; then
    echo "Installing SRA Toolkit..."
    cd ~/wgs_pipeline
    wget -q https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
    tar -xzf sratoolkit.current-ubuntu64.tar.gz
    SRA_DIR=$(find . -maxdepth 1 -name "sratoolkit*" -type d)
    echo "export PATH=\$PATH:$(pwd)/${SRA_DIR}/bin" >> ~/.bashrc
    export PATH=$PATH:$(pwd)/${SRA_DIR}/bin
    echo "Run 'source ~/.bashrc' or restart your terminal before script 01."
else
    echo "SRA Toolkit already installed."
fi
pip3 install --user pandas numpy matplotlib seaborn
echo "Verifying installations:"
fastqc --version || echo "FastQC MISSING"
bowtie2 --version | head -n1 || echo "Bowtie2 MISSING"
samtools --version | head -n1 || echo "SAMtools MISSING"
bcftools --version | head -n1 || echo "BCFtools MISSING"
trimmomatic -version 2>&1 || echo "Trimmomatic MISSING"
fasterq-dump --version 2>&1 | head -n1 || echo "fasterq-dump MISSING (restart shell)"

