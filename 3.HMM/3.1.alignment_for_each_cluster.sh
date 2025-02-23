#!/bin/bash
#Create submission scripts to align each cluster independently.
#Scripts can then be submitted in a for loop.

mkdir cluster_alignments
mkdir alignment_submissions

for FASTA in `ls cluster_fasta`; do
  name=$(echo $FASTA| awk -F"." '{print $1}')
  echo '#!/bin/bash
#SBATCH --mail-user=chh20csu@uea.ac.uk
#SBATCH -t 7-00:00:00
#SBATCH --mem=50G
#SBATCH -p compute-24-96
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --job-name='$name'%j #Change Job Name
#SBATCH -o '$name'.clustal.out
#SBATCH -e '$name'.clustal.err

#cd /gpfs/home/chh20csu/toxin_fa_files/hmm_building/cluster_alignments

#load modules and add to path

module load clustal-omega/1.2.4

#program

clustalo -i cluster_fasta/'$FASTA' --threads=24 > cluster_alignments/'$name'.fas' >> 'alignment_submissions/'$name'.sub'

done

