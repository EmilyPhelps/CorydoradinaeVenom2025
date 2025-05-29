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
       s) species_list=$OPTARG;;
       d) DIR=$OPTARG;;
       o) OUTDIR=$OPTARG;;
       m) MEM=$OPTARG;;
       t) CPU=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${species_list} ] || [ -z $OUTDIR} ] || [ -z ${DIR} ] ; then
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

PATH=~/miniconda3/bin/:$PATH

###################################### Program ##########################
if [ ! -d ${OUTDIR} ]; then
   mkdir ${OUTDIR}
fi

for sp in `cat $species_list`; do
   if [ ! -d ${OUTDIR}/${sp} ]; then
   mkdir ${OUTDIR}/${sp}
   fi

   if [ ! -d ${OUTDIR}/${sp}/int_concat ]; then
   mkdir ${OUTDIR}/${sp}/int_concat
   fi
   
  
  sample_list=$(find ${DIR} -type f -name "${sp}*" -exec basename {} \; \
   | cut -c 1-5 | sort | uniq | sed 's/\.//g')

  if [  -f ${OUTDIR}/${sp}_trin.txt ]; then
     rm -rf ${OUTDIR}/${sp}_trin.txt
  fi
  
  for sample in `echo ${sample_list}`; do 
     
  #   cat ${DIR}/$sample*fastq > ${OUTDIR}/${sp}/int_concat/${sample}_concat.fastq
     R1=$(ls ${DIR}/${sample}*notCombined_1.fastq)
     R2=$(ls ${DIR}/${sample}*notCombined_2.fastq)
     single=$(ls ${DIR}/${sample}*extendedFrags.fastq)

      echo -e "${sp}\t${sample}\t${R1}\t${R2}" >> ${OUTDIR}/${sp}_trin.txt
      echo -e "${sp}\t${sample}_combined\t${single}\t" >> ${OUTDIR}/${sp}_trin.txt
  done 
   
  # if [ ! -d ${OUTDIR}/${sp}/assembly ]; then
  #   mkdir ${OUTDIR}/${sp}/assembly
  # fi
   
   Trinity --seqType fq \
           --samples_file ${OUTDIR}/${sp}_trin.txt \
           --CPU ${CPU} \
           --max_memory ${MEM} \
           --output ${OUTDIR}/${sp}/trinity_assembly
   
done
