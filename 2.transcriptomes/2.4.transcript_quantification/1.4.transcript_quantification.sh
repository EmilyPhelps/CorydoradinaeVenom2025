#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is to estimate read abundance based on our master transcriptomes"
   echo "This is done using salmon within the Trinity suite" 
   
   echo "Syntax: 1.4.transcript_quantification.sh -s samples -t transcriptome path "
   echo 
   echo options
   echo "h     Print this Help."
   echo "s     Samples file. x."
   echo "                      cond_A    cond_A_rep1    A_rep1_left.fq    A_rep1_right.fq"
   echo "                      cond_A    cond_A_rep2    A_rep2_left.fq    A_rep2_right.fq"
   echo "                      cond_B    cond_B_rep1    B_rep1_left.fq    B_rep1_right.fq"
   echo "                      cond_B    cond_B_rep2    B_rep2_left.fq    B_rep2_right.fq"
   echo "t     path to directory containing the transcriptome (called Trinity.fasta)"
   echo "c     cpus/threads, must match the submission details"
   echo ""
   echo ""
}
###############################################  Options ################################################

# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hs:o:t:c:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
       s) SAMPLE=$OPTARG;;
       t) TRANSCRIPTOME=$OPTARG;;
       c) CPU=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${SAMPLE} ] || [ -z $TRANSCRIPTOME} ] ; then
   echo "Missing options"
   exit 1
fi

if [ -z ${CPU} ] ; then
   echo "Using default CPU"
   CPU=1
fi
###################################### Dependencies and Version. ###########################################
module load trinity/2.11.0
PATH=/gpfs/software/ada/trinity/2.11.0/util/:$PATH 

################################################ Program. #################################################
TRANS_NAME=$(echo $TRANSCRIPTOME | awk -F"/" '{print $NF}')
  if [ ! -d abundance ]; then
    mkdir abundance
  fi

  if [ ! -d abundance/${TRANS_NAME} ]; then 
    mkdir abundance/${TRANS_NAME} 
  fi

align_and_estimate_abundance.pl --transcripts ${TRANSCRIPTOME}/Trinity.fasta \
          --seqType fq \
          --samples_file ${SAMPLE} \
          --est_method salmon \
          --output_dir abundance/${TRANS_NAME} \
          --gene_trans_map ${TRANSCRIPTOME}/Trinity.fasta.gene_trans_map \
          --prep_reference \
          --thread_count ${CPU}
