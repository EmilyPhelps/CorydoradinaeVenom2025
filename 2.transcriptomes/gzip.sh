#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=chh20csu@uea.ac.uk
#SBATCH -t 7-00:00:00
#SBATCH --mem=200G
#SBATCH -p compute-64-512
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name=gzip%j #Change Job Name
#SBATCH -o gzip.out
#SBATCH -e gzip.err

cd ~/CorydoradinaeVenom2025/NAR_out/trimmed

gzip NAR*fastq

mv NAR*gz ~/scratch/trimmed
