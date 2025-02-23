#!/bin/bash
############################################# Help  ###################################################

Help()
{
   # Display Help
   echo "my HMM script to identify them toxin genes. Input should be the alignment file."
   echo "You should include the whole pathway to Directory"
   echo "(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"
   echo
   echo "Syntax: "
   echo 
   echo options
   echo "h     Print this Help."
   
   echo
   echo ""
}
###############################################  Options ################################################

# Add options in by adding another letter eg. :x, and then include a letter) and some commands.
# Semi colon placement mega important if you want to include your own input value.
while getopts ":hi:d:g:n:" option; do
   case ${option} in
      h) # display Help
         Help
         exit;;
      n) NAME=$OPARG
      ;;   
      d) DIR=$OPTARG
      ;;
      i) INPUT=$OPTARG
      ;;
      g) GENOME=$OPTARG
      ;;
      \?) # incorrect option
         echo "Error: Invalid option щ(ಥДಥщ)"
         exit;;
   esac
done

###########################################  Load dependencies #############################################
echo "Loading Hmmer"
module load hmmer/3.3

###########################################  Main program. #################################################
echo "Startin program"
cd $DIR

cd ../ 

#Cluster name

CLUST=$(echo $INPUT | awk -F"." '{print $1}')

echo "Builidng hmm"

#building hmm

NAME=$(echo $GENOME | awk -F"." '{print $1}')

if [ ! -d "hmm_files" ]; then
 mkdir hmm_files
fi

cd hmm_files

if [ ! -d $NAME ]; then
  mkdir $NAME 
fi

cd ../

hmmbuild -o $CLUST'_hmmbuild.out' --amino $CLUST'_hmm' $DIR'/'$INPUT

mv $CLUST'_hmmbuild.out' 'hmm_files/'$NAME'/'
mv $CLUST'_hmm' 'hmm_files/'$NAME'/'
echo "Searching with Hmm"

#Searching
if [ ! -d "hmm_search_files" ]; then
  mkdir hmm_search_files
fi

cd hmm_search_files

if [ ! -d $NAME ]; then
  mkdir $NAME 
fi

cd ../

hmmsearch -o $CLUST'_search.out' 'hmm_files/'$NAME'/'$CLUST'_hmm' $GENOME

mv $CLUST'_search.out' 'hmm_search_files/'$NAME'/'



