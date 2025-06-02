#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is written to cluster genes in transcripts. This is written for the HPC (UEA ADA 2024)"
   echo "Change the dependencies if need be."
   
   echo "Syntax: 2.2.2.cluster.sh -f transcriptome "
   echo 
   echo options
   echo "h     Print this Help."
   echo "f     transcriptome"
   echo "o     output directory"
}
###############################################  Options ################################################

# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hs:d:o:m:t:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
       f) transcriptome=$OPTARG;;
       o) outdir=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${transcriptome} ] || [ -z ${outdir} ]; then
   echo "Missing options"
   exit 1
fi

###############################################  Options ################################################

