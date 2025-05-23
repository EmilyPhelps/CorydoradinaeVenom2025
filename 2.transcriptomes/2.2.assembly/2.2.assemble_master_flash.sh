#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is written to assemble to transcriptomes. This is written for the HPC (UEA ADA 2024)"
   echo "Change the dependencies if need be."
   
   echo "Syntax: 1.1.assemble_master.sh -s samples "
   echo 
   echo options
   echo "h     Print this Help."
   echo "s     Species list - this will be just the prefix that is shared by all the reads from a species, e.g. "
   echo "      TUK is in the title for all tukano RNAseq"
   echo " NB: This script uses flash transcripts which have been elongated. It concatinates all combined and"
   echo " non-combined sequences into one file for assembly"
   echo "d     directory with fastq files"
   echo "o     output directory"
   echo "m     memory requirement for trinity, must match the submission details"
   echo "t     cpus/threads for trinity, must match the submission details"
   echo ""
   echo ""
}
###############################################  Options ################################################

# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hs:d:o:m:t:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
       s) LIST=$OPTARG;;
       d) DIR=$OPTARG;;
       o) OUTDIR=$OPTARG;;
       m) MEM=$OPTARG;;
       t) CPU=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${LIST} ] || [ -z $OUTDIR} ] || [ -z ${DIR} ] ; then
   echo "Missing options"
   exit 1
fi

if [ -z ${CPU} ] ; then
   echo "Missing memory requirement. Setting to default"
   CPU=1
  
fi

if [ -z ${MEM} ] ; then
   echo "Missing memory requirement. Setting to default"
   MEM=$(echo "$CPU * 3.7" | bc)
fi
###################################### Dependencies and Version. ###########################################
module load trinity/2.11.0
module load jellyfish/2.3.0


###################################### Program ##########################
if [ ! -d ${OUTDIR} ]; then
   mkdir ${OUTDIR}
fi

for sp in `cat $LIST`; do
   if [ ! -d ${OUTDIR}/${sp} ]; then
   mkdir ${OUTDIR}/${sp}
   fi

   if [ ! -d ${OUTDIR}/${sp}/concat_reads ]; then
   mkdir ${OUTDIR}/${sp}/concat_reads
   fi
   
  #cat ${DIR}/${sp}*.fastq > ${OUTDIR}/${sp}/concat_reads/${sp}_concat.fastq

   FQ=${OUTDIR}/${sp}/concat_reads/${sp}_concat.fastq
   
   if [ ! -d ${OUTDIR}/${sp}/assembly ]; then
     mkdir ${OUTDIR}/${sp}/assembly
   fi
   
   chmod 775 ${FQ}

   Trinity --seqType fq \
           --single ${FQ} \
           --CPU ${CPU} \
           --max_memory ${MEM} \
           --output ${OUTDIR}/${sp}/trinity_assembly
   
done
