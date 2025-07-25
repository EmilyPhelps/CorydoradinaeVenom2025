#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=chh20csu@uea.ac.uk
#SBATCH -t 7-00:00:00
#SBATCH --mem=80G
#SBATCH -p compute
#SBATCH --array=0-2
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name=TEfilt_array #Change Job Name
#SBATCH -o TEfilt_%A_%a.out
#SBATCH -e TEfilt_%A_%a.err

PATH=~/miniconda3/bin/:$PATH

idlist=(SIM REY NAR)
id=${idlist[$SLURM_ARRAY_TASK_ID]}

rep_ln=/gpfs/home/chh20csu/CorydoradinaeVenom2025/rep_ln
trans_ln=/gpfs/home/chh20csu/CorydoradinaeVenom2025/transcriptome_ln

#Run R script to generate the filter file
reptsv=$(find "${rep_ln}" -name "${id}*" )
trans=$(find "${trans_ln}" -name "${id}*" )

Rscript generate_filt.R $reptsv $trans
#Filter using seqkit
seqkit 
