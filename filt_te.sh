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

