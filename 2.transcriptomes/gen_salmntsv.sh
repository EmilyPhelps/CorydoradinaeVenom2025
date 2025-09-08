#Quick code to create the files for inputting to salmon in trinity
dir=~/scratch/trimmed #path with the trimmed fq files
id=NAR # the prefix, e.g. SIM NAR TUK
output=./
   
mapfile -t f1 < <(find "${dir}" -name "${id}*_1.fastq*" | sort)
mapfile -t f2 < <(find "${dir}" -name "${id}*_2.fastq*" | sort)

for ((i=0; i<${#f1[@]}; i++)); do
  echo -e "${f1[i]}\t${f2[i]}\t" >> ${output}/${id}_fq.tsv
done


