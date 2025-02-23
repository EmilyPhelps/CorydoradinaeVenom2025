Help()
{
   # Display Help
   echo "This script is for annotating the *~New~* transcriptomes"
   echo "Make sure you have the databases downloaded first!"
   echo "   -----------------"
   echo "   | Trim Adapters |"
   echo "   -----------------"
   echo "          ✔         "
   echo "   -----------------"
   echo "   | Map to genome |"
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
   echo "Syntax: ./1.3.4.transcriptome_annotation_trinotate.sh [-options]"
   echo 
   echo options
   echo "h     Print this Help."
   echo "f     transcriptome dir, with the file named Trinity.fasta. Full path"
   echo "d     database folder"
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
      d) DB_DIR=$OPTARG;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

if [ -z ${TRANSCRIPTOME} ] || [ -z ${DB_DIR} ] ; then 
   echo "Missing option- exiting"
   exit 1
fi

###################################### Program ###########################################
SAMPLE_NAME=$(echo $TRANSCRIPTOME | awk -F"/" '{print $(NF)}' )
LONGEST_ORF=${SAMPLE_NAME}_transdecoder/longest_orfs.pep

cd ${TRANSCRIPTOME}/

cp ${DB_DIR}/TrinotateBoilerplate.sqlite ./Trinotate.sqlite

if [ -f __init.ok ]; then
  rm -f __init.ok
fi

~/Trinotate-Trinotate-v4.0.2/Trinotate --db Trinotate.sqlite \
   --init \
   --gene_trans_map Trinity.fasta.gene_trans_map \
   --transcript_fasta Trinity.fasta \
   --transdecoder_pep SIM_transdecoder/longest_orfs.pep

~/Trinotate-Trinotate-v4.0.2/Trinotate --db Trinotate.sqlite \
                                       --LOAD_swissprot_blastp blastp.outfmt6

~/Trinotate-Trinotate-v4.0.2/Trinotate --db Trinotate.sqlite \
                                       --LOAD_swissprot_blastx blastx.outfmt6

~/Trinotate-Trinotate-v4.0.2/Trinotate --db Trinotate.sqlite \
                                       --LOAD_pfam TrinotatePFAM.out

~/Trinotate-Trinotate-v4.0.2/Trinotate --db Trinotate.sqlite \
                                       --report > ${SAMPLE_NAME}_trinotate_report.xls

~/Trinotate-Trinotate-v4.0.2/util/extract_GO_assignments_from_Trinotate_xls.pl \
                                       --Trinotate_xls SIM_trinotate_report.xls   \
                                       -G --include_ancestral_terms > ${SAMPLE_NAME}_go_terms.txt

                                       

