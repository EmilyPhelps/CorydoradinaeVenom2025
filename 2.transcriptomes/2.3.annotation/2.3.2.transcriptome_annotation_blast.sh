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
   echo "l     longest orf file"
}


###############################################  Options ################################################
# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hf:o:d:l:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
      f) TRANSCRIPTOME=$OPTARG;;
      o) OUTDIR=$OPTARG;;
      d) DB_DIR=$OPTARG;;
      l) LONGEST_ORF=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${TRANSCRIPTOME} ] || [ -z ${OUTDIR} ]|| [ -z ${DB_DIR} ] ; then 
   echo "Missing option- exiting"
   exit 1
fi

if [ ! -d $OUTDIR/annotations ]; then
   mkdir ${OUTDIR}/annotations
fi
###################################### Program ###########################################

SAMPLE_NAME=$(echo $TRANSCRIPTOME | awk -F"/" '{print $(NF)}' )

if [ -z $LONGEST_ORF ]; then
   echo "No long orf input given, using the default path: "
   echo -e "${OUTDIR}/annotations/${SAMPLE_NAME}/${SAMPLE_NAME}_transdecoder/longest_orfs.pep"
   LONGEST_ORF=${OUTDIR}/annotations/${SAMPLE_NAME}/${SAMPLE_NAME}_transdecoder/longest_orfs.pep
else
   echo "longest orf input using:"
   echo -e $LONGEST_ORF
fi

blastx -query ${OUTDIR}/annotations/${SAMPLE_NAME}/Trinity.fasta \
   -db ${DB_DIR}/uniprot_sprot.pep \
   -num_threads 20 \
   -max_target_seqs 1 \
   -outfmt 6 > ${OUTDIR}/annotations/${SAMPLE_NAME}/blastx.outfmt6
   
blastp -query ${LONGEST_ORF} \
   -db ${DB_DIR}/uniprot_sprot.pep \
   -num_threads 20 \
   -max_target_seqs 1 \
   -outfmt 6 > ${OUTDIR}/annotations/${SAMPLE_NAME}/blastp.outfmt6
   
echo "Finished blast searches, run next stage" 
