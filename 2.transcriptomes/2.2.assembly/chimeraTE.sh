#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is written to detect chimeric transcripts using chimeraTE. "
   echo "This is written for the HPC (UEA ADA 2025)"
   echo "Change the dependencies if need be."
   
   echo "Syntax: 1.1.assemble_master.sh -s samples "
   echo 
   echo options
   echo "h     Print this Help."
   echo "f     The raw/cleaned fastq files used to create the transcriptome"
   echo "t     The transcriptome"
   echo "r     The repeat library"
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
