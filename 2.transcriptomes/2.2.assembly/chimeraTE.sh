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
   echo "f     The raw/cleaned fastq files used to create the transcriptome- prefix only"
   echo "t     The transcriptome"
   echo "r     The repeat library"
   echo "o     output directory"
   echo ""
   echo ""
}
###############################################  Options ################################################

# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hf:t:r:o:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
       f) fq=${OPTARG};;
       t) trans=${OPTARG};;
       r) repeatlib=${OPTARG};;
       o) output=${OPTARG};;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${fq} ] || [ -z ${trans} ] || [ -z ${repeatlib} ] ; then
   echo "Missing options"
   exit 1
fi

if [ -z ${output} ] ; then
   echo "default output"
   timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
   output=output_${timestamp}
fi

###############################################  Options ################################################

if [ -z ${MEM} ] ; then
   echo "Missing memory requirement. Setting to default"
   MEM=$(echo "$CPU * 3.7" | bc)
fi
###################################### Dependencies and Version. ###########################################
