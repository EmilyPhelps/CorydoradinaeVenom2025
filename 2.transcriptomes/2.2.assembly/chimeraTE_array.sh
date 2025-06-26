#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is written to detect chimeric transcripts using chimeraTE. "
   echo "This is written for the HPC (UEA ADA 2025)"
   echo "Change the dependencies if need be."
   
   echo "Syntax: chimeraTE.sh [options]"
   echo 
   echo options
   echo "h     Print this Help."
   echo "f     path to fq files"
   echo "n     sample name e.g. TUK, SIM, "
   echo "r     The repeat library"
   echo "o     output directory"
   echo "t     transcriptome"
   echo "c     cpus/threads"
   echo "m     memory"
   echo ""
   echo ""
}
###############################################  Options ################################################

# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hf:t:r:o:c:m:n:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
       f) fq=${OPTARG};;
       n) id=${OPTARG};;
       t) trans=${OPTARG};;
       r) repeatlib=${OPTARG};;
       o) output=${OPTARG};;
       c) cpus=${OPTARG};;
       m) mem=${OPTARG};;
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

if [ -z ${cpus} ] ; then
   echo "Missing memory requirement. Setting to default"
   cpus=1
  
fi

###################################### Dependencies and Version. ###########################################
PATH=~/miniconda3/bin/:$PATH

if [ ! -d ${output} ]; then
   mkdir ${output}
fi

#Going to edit the transcriptomes so they are appropriate for chimeraTE. 
#If the output dir exists then skips

if [ ! -d ${output}/trans_renamed ]; then
   mkdir ${output}/trans_renamed
   if [ ! -d ${output}/trans_renamed/${id} ]; then
   mkdir ${output}/trans_renamed/${id}
   fi
fi

trans_name=$(echo ${trans} | awk -F"/" '{print $NF}')

#if [ ! -f ${ouput}/trans_renamed/${id}/${trans_name}_renamed.fasta ]; then
#   awk 'BEGIN{FS=" "} 
#   /^>/ {
#     split($1, idparts, "_");
#     gene = "TRINITY." idparts[2] "." idparts[3] "." idparts[4];
#     iso = gene "." idparts[5];
#     print ">" iso "_" gene;
#     next
#   }
#   {print}' ${trans} > ${output}/trans_renamed/${trans_name}_renamed.fasta 
#fi

cat ${trans} > ${output}/trans_renamed/${trans_name}_renamed.fasta 

if [ ! -f ${output}/${id}_${trans_name}_fq.tsv ]; then

   mapfile -t f1 < <(find "${fq}" \( -name "${id}*1.fq" -o -name "${id}*1.fq.gz" -o -name "${id}*1.fastq" -o -name "${id}*1.fastq.gz" \) | sort)
   mapfile -t f2 < <(find "${fq}" \( -name "${id}*2.fq" -o -name "${id}*2.fq.gz" -o -name "${id}*2.fastq" -o -name "${id}*2.fastq.gz" \) | sort)

   for ((i=0; i<${#f1[@]}; i++)); do
     rep_num=$((i+1))
     echo -e "${f1[i]}\t${f2[i]}\trep${rep_num}" >> ${output}/${id}_${trans_name}_fq.tsv
   done
fi

python3 chimTE_mode2.py --input ${output}/${id}_fq.tsv \
         --project ${id}_${trans_name} \
         --te ${repeatlib} \
         --transcripts ${ouput}/trans_renamed/${id}/${trans_name}_renamed.fasta \
         --strand rf-stranded \
         --threads ${cpus} \
         --ram ${mem}

