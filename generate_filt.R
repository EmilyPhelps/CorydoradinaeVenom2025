#Rscript
library(tidyverse)

args = commandArgs(trailingOnly=TRUE)

rep <-  read_tsv(args[1], col_names=FALSE) 
colnames(rep) <- c("gene", "TE", "X", "Seq", "Y")

max_fields <- max(str_count(rep$Seq, ";")) + 1

rep %>%
  separate(Seq, into = paste0("S", 1:max_fields), sep = ";", fill = "right") %>%
  pivot_longer(
    cols = starts_with("S"),
    names_to = "Scol",
    values_to = "Transcripts"
  ) %>%
mutate(Transcripts=gsub("\\.", "_", trimws(gsub("_.*", "", Transcripts)))) %>% 
dplyr::select(Transcripts) %>% write_tsv(paste0(args[1], ".output.tsv")
