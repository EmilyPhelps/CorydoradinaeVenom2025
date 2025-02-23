#!/bin/bash
LIST=transcriptome.list
mkdir busco_subs

for TRANS in `cat ${LIST}`; do
  SAMPLE=$(echo ${TRANS}| awk -F"/" '{print $(NF)}')
#Sub1  
  echo \#\!/bin/bash >> busco_subs/${SAMPLE}_busco.sub
  echo -e "#SBATCH --mail-type=END,FAIL
  #SBATCH --mail-user=chh20csu@uea.ac.uk
#SBATCH -t 7-00:00:00
#SBATCH --mem=200G
#SBATCH -p compute-64-512
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --job-name=${SAMPLE}_busco #Change Job Name
#SBATCH -o ${SAMPLE}_busco.out
#SBATCH -e ${SAMPLE}_busco.err

module load busco/4.1.0

busco -m tran -i ${TRANS}/Trinity.fasta -l actinopterygii_odb10 -o ${SAMPLE}_busco -q -c 30 -f" \
>>busco_subs/${SAMPLE}_busco.sub

done
