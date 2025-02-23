#!/bin/bash
mkdir hmm_submissions
for i in ARC NARC MET TUK REY SIM; do
GENOME=./annotations/${i}/${i}_transdecoder/longest_orfs.pep
GENOME_NAME=${i}
if [ ! -d 'hmm_submissions/'$GENOME_NAME ]; then
  mkdir 'hmm_submissions/'$GENOME_NAME
fi
  
for ALIGN in `ls cluster_alignments`; do
  name=$(echo $ALIGN| awk -F"." '{print $1}')
  echo '#!/bin/bash
#SBATCH --mail-user=chh20csu@uea.ac.uk
#SBATCH -t 7-00:00:00
#SBATCH --mem=20G
#SBATCH -p compute-24-96
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name='$name'%j #Change Job Name
#SBATCH -o '$name'.clustal.out
#SBATCH -e '$name'.clustal.err

#cd /gpfs/home/chh20csu/Venom_Evolution_2024/hmm_models
./hmm_model.sh -i '$ALIGN' -d cluster_alignments -g '$GENOME' -n '$GENOME_NAME >> 'hmm_submissions/'$GENOME_NAME'/'$name'_hmm.sub'

done
done
