#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is written to assemble to transcriptomes. This is written for the HPC (UEA ADA 2024)"
   echo "Change the dependencies if need be."
   echo "Pre-processing and assembling pipeline"
   echo "   -----------------"
   echo "   | Combining reads |"
   echo "   -----------------"
    echo "          ⤵         "
   echo "   -----------------"
   echo "   | Trim Adapters |"
   echo "   -----------------"
   echo "          ⤵         "
   echo "   -----------------"
   echo "   | Map to transcritpme |"
   echo "   -----------------"
   echo "          ⤵        "
   echo "-------------------------"
   echo "| Quantify expression    |"
   echo "-------------------------"
   echo "     ✧*｡٩(ˊᗜˋ*)و✧*｡"
   echo
   echo "Syntax: "
   echo 
   echo options
   echo "h     Print this Help."
   echo "s     Sample list, with path"
   echo "o     output directory"
   echo ""
}

###############################################  Options ################################################

# Add options in by adding another letter eg. :x, and then include a letter and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hs:o:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
       s) LIST=$OPTARG;;
       o) OUTDIR=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${LIST} ] || [ -z $OUTDIR} ]; then
   echo "Missing options"
   exit 1
fi

if [[ "${INDEX}" -ne 1 ]]; then
   INDEX=0
fi
###################################### Dependencies and Version. ###########################################

PATH=flash/:$PATH

################################################## Program ####################################################

if [ ! -d ${OUTDIR} ]; then
   mkdir ${OUTDIR}
fi

if [ ! -d ${OUTDIR}/flashed ]; then
   mkdir ${OUTDIR}/flashed
fi

for SAMPLE in `cat ${LIST}`; do
   SAMPLE_NAME=$(echo $SAMPLE | awk -F"/" '{print $(NF)}')
   
   #Do a check to see if there is more than one lane being used
   
   lane_num=$(ls ${SAMPLE}/${SAMPLE_NAME}*_1.fq.gz | wc -l)
  
   if [ $lane_num -ne 1  ]; then
      mkdir $SAMPLE/concat_raw/
      cat ${SAMPLE}/${SAMPLE_NAME}*_1.fq.gz  > $SAMPLE/concat_raw/${SAMPLE_NAME}_concat_1.fq.gz 
      cat ${SAMPLE}/${SAMPLE_NAME}*_2.fq.gz  > $SAMPLE/concat_raw/${SAMPLE_NAME}_concat_2.fq.gz 
      
      F1=$(echo $SAMPLE/concat_raw/${SAMPLE_NAME}_concat_1.fq.gz)
      F2=$(echo $SAMPLE/concat_raw/${SAMPLE_NAME}_concat_2.fq.gz)
   else 
      F1=$(echo ${SAMPLE}/${SAMPLE_NAME}*_1.fq.gz)
      F2=$(echo ${SAMPLE}/${SAMPLE_NAME}*_2.fq.gz)
   fi

   echo "flashing ${SAMPLE_NAME}"

flash ${F1} ${F2} --d ${OUTDIR}/flashed
   
done
