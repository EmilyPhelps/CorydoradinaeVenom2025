#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "This script is for annotating the *~New~* transcriptomes"
   echo "Make sure you have the databases downloaded first!"
   echo "   -----------------"
   echo "   | Trim Adapters |"
   echo "   -----------------"
   echo "          ✔         "
   echo "-------------------------"
   echo "| Assemble transcriptome|"
   echo "-------------------------"
   echo "           ⤵  "
   echo "------------------------"
   echo "|Annotate transcriptome|"
   echo "------------------------"
   echo 
   echo "Syntax: ./1.3.a.transcriptome_annotation.sh [-options]"
   echo 
   echo options
   echo "h     Print this Help."
   echo "f     transcriptome dir, with the file named Trinity.fasta. Full path"
   echo "d     database folder"
   echo "o     Directory containing all the assemblies, alignments etc to date"
}


###############################################  Options ################################################
# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hf:o:d:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
      f) TRANSCRIPTOME=$OPTARG;;
      o) OUTDIR=$OPTARG;;
      d) DB_DIR=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${TRANSCRIPTOME} ] || [ -z ${OUTDIR} ]|| [ -z ${DB_DIR} ] ; then 
   echo "Missing option- exiting"
   exit 1
fi
###################################### Program ###########################################
SAMPLE_NAME=$(echo $TRANSCRIPTOME | awk -F"/" '{print $(NF)}' )

LONGEST_ORF=${OUTDIR}/annotations/${SAMPLE_NAME}/${SAMPLE_NAME}_transdecoder/longest_orfs.pep

hmmscan --cpu 30 \
   --domtblout ${OUTDIR}/annotations/${SAMPLE_NAME}/TrinotatePFAM.out \
   ${DB_DIR}/Pfam.hmm ${LONGEST_ORF} > ${OUTDIR}/annotations/${SAMPLE_NAME}/pfam.log
   
echo "Complete hmmscan section" >&2 
