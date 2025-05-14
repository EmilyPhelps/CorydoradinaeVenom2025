#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is written to assemble to transcriptomes. This is written for the HPC (UEA ADA 2024)"
   echo "Change the dependencies if need be."
   echo "Pre-processing and assembling pipeline"
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

# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
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

module load trinity/2.11.0
module load trimgalore
#module load python/anaconda/2020.11/3.8
#conda activate agat

PATH=/gpfs/home/chh20csu/TrimGalore-0.6.10:$PATH

DATE=$(date "+DATE: %D" | awk '{print $2}')

echo ">1.1.a.transcriptome_pre_process.sh $DATE" >> ./transcriptomes_assembly_version_information.out
echo -e "Software\tProgram\tVersion\tRole" >> ./transcriptomes_assembly_version_information.out

#Trimgalore version- Not sure we used trimgalore in the end. Need it for cutadapt in the cluster#
#VER=$(0.6.6)
#echo -e "Trimgalore\t\t${VER}\tCutadapt wrapper" >> ./transcriptomes_assembly_version_information.out

#Cutadapt
VER=$(cutadapt --version)
echo -e "Cutadapt\t\t${VER}\tTrim adapters" >> ./transcriptomes_assembly_version_information.out

#TRINITY version
#VER=$(Trinity --version | awk -F"-v" '{print $2}' | head -n 1| awk -F" " '{print $1}')
#echo -e "Trinity\t-\t${VER}\tGenome Guided de-novoAssemble transcriptome" >> ./transcriptomes_assembly_version_information.out

###########################################  Main program. #################################################

if [ ! -d ${OUTDIR} ]; then
   mkdir ${OUTDIR}
fi

if [ ! -d ${OUTDIR}/trimmed ]; then
   mkdir ${OUTDIR}/trimmed 
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
   
   echo "trimming adapters for ${SAMPLE_NAME}" >> trim.out 
   FIVE_PRIME=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT
   THREE_PRIME=GATCGGAAGAGCACACGTCTGAACTCCAGTCACGGATGACTATCTCGTATGCCGTCTTCTGCTTG
   PHRED_SCORE=20
    
   cutadapt -q ${PHRED_SCORE} -a ${FIVE_PRIME} -A ${THREE_PRIME} --pair-adapters \
   -o ${SAMPLE_NAME}_trimmed_1.fastq -p ${SAMPLE_NAME}_trimmed_2.fastq ${F1} ${F2}

done


mv *trimmed*.fastq ${OUTDIR}/trimmed
 
echo "~✧ 𓆝 𓆟 𓆞 𓆝 𓆟 𓆞 ~✧ Alignment complete ~✧ 𓆝 𓆟 𓆞 𓆝 𓆟 𓆞 ~✧ " >> trim.out 
