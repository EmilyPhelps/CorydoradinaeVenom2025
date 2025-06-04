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
   echo "f     Path to raw/ cleaned fq files with prefix"
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


###################################### Dependencies and Version. ###########################################
PATH=~/miniconda3/bin/:$PATH
PATH=~/ChimeraTE/:$PATH

if [ !-d ${output} ]; then
   mkdir ${output}
fi

#Going to edit the transcriptomes so they are appropriate for chimeraTE. 
#If the output dir exists then skips
if [ ! -d ${output}/renamed ]; then
   mkdir ${output}/trans_renamed

   awk 'BEGIN{FS=" "} 
   /^>/ {
     split($1, idparts, "_");
     gene = "TRINITY." idparts[2] "." idparts[3] "." idparts[4];
     iso = gene "." idparts[5];
     print ">" gene "_" iso;
     next
   }
   {print}' ${trans} > ${output}/trans_renamed/${trans}_renamed.fasta
fi

id=$(echo $fq | awk -F"/" '{print $NF}')

if [ ! -f ${output}/${id}_fq.tsv ]; then
   dir=$(echo ${fq} | sed "s/${id}//g")

   mapfile -t f1 < <(find "${dir}" -name "${id}*_1.fastq.gz" | sort)
   mapfile -t f2 < <(find "${dir}" -name "${id}*_2.fastq.gz" | sort)
   
   for ((i=0; i<${#f1[@]}; i++)); do
     rep_num=$((i+1))
     echo -e "${f1[i]}\t${f2[i]}\trep${rep_num}" >> ${output}/${id}_fq.tsv
   done
fi

python3 chimTE_mode2.py --input ${output}/${id}_fq.tsv \
         --project ${id}_chimeraTE \
         --te ${repeatlib} \
         --transcripts ${output}/trans_renamed/${trans}_renamed.fasta \
         --strand rf-stranded


