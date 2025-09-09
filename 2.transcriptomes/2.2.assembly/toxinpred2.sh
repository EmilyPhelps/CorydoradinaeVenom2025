#!/bin/bash
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=chh20csu@uea.ac.uk
#SBATCH -t 7-00:00:00
#SBATCH --mem=80G
#SBATCH --array=0-5
#SBATCH -p compute-24-96
#SBATCH --ntasks=1
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=10
#SBATCH --job-name=toxinprede_array #Change Job Name
#SBATCH -o toxinpred_%A_%a.out
#SBATCH -e toxinpred_%A_%a.err

#location
PATH=~/miniconda3/bin/:$PATH

idlist=(SIM REY NAR MET TUK ARC)
id=${idlist[$SLURM_ARRAY_TASK_ID]}

toxinpred2 -i ${id}_transdecoder/*transdecoder_dir/longest_orfs.pep -o toxinpred2_out/${id}_toxinpred2.tsv


