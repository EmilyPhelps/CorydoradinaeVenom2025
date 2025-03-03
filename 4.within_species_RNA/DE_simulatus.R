#Rscript
#Author: Emily Phelps
#Differential expression between C.simulatus tissues
relationships <- read.table("samples.txt", header=F, sep="\t") %>% mutate(species=substr(V1, 1, 3))
colnames(relationships) <- c("sample", "species") 

sim.relationships <- relationships %>% 
  filter(species == "SIM") %>% 
  mutate(tissue=ifelse(str_detect(sample, "S2"), "S2", 
                       ifelse(str_detect(sample, "S1"), "S1", "A"))) %>% 
  filter(tissue != "S1") %>% 
  mutate(IndId=substr(sample, 1, 5)) %>%
  filter(!c(sample %in% rm))

files <- file.path("data/trinity_salmon_qual", sim.relationships$sample, "quant.sf")

all(file.exists(files))

tx2gene <-read_tsv("data/transcriptomes/SIM/Trinity.fasta.gene_trans_map", col_names=FALSE) %>% 
            select(X2, X1)

colnames(tx2gene) <- c("transcript_id", "gene_id")

names(files) <- as.vector(sim.relationships$sample)
txi <- tximport(files, type = "salmon", txOut = TRUE)
txi.sum <- summarizeToGene(txi, tx2gene)

dds <- DESeqDataSetFromTximport(txi.sum, sim.relationships, ~ tissue)

#PreFilter Step "Note that more strict filtering to increase power is automatically applied via independent 
# filtering on the mean of normalized counts within the results function."
#https://introtogenomics.readthedocs.io/en/latest/2021.11.11.DeseqTutorial.html
keep <- rowSums(counts(dds) > 50) >=5
dds <- dds[keep,]

norm.data <- vst(dds)

tissue <- plotPCA(object=norm.data, intgroup="tissue") + theme_classic()

ggplot(tissue$data) + 
  geom_point(aes(x=PC1, y=PC2, color=tissue)) + 
  geom_convexhull(aes(x=PC1, y=PC2, fill=tissue), alpha=0.4) + 
  labs(x="PC1: 47% variance", y="PC2: 15% variance", colour="Tissue", fill= "Tissue") + 
  scale_fill_manual(values=c(divergent[8], divergent[4]),
                    breaks=c("A", "S2"), 
                    labels=c("Venom\nGland", "Skin")) +
  scale_colour_manual(values=c(divergent[8], divergent[4]),
                    breaks=c("A", "S2"), 
                    labels=c("Venom\nGland", "Skin")) +
  theme(legend.position = "top",
        panel.border = element_rect(color = theme_cols[4], 
                                    fill = NA, 
                                    size = 0.8),
        panel.background = element_blank(),
        axis.title= element_text(size= 10, color=theme_cols[4]), 
        axis.line = element_line(linewidth = 0.5, 
                                 colour = theme_cols[3]),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
ggsave("MS_DC3_Sim_pca.pdf", width=6, height=5)
express <- DESeq(dds)
res <- results(express, alpha= 0.05)
resOrdered <- res[order(res$padj),]
summary(resOrdered)

resOrdered %>% 
  as.data.frame() %>% 
  rownames_to_column(var="gene") %>% 
  filter(padj < 0.05) %>% 
  write_tsv("SvsA_significant_genes.tsv")

#Identify venom candidate genes
hmm <- read_csv("data/SIM_hmm_parsed.csv", col_names=FALSE)
colnames(hmm) <- c("transcript_id", "bits", "evalue", "n.domains", "exp", "bias", "type", "length","gc", "other", "cluster")

hmm <- hmm %>% 
  mutate(transcript_id=gsub("\\..*","", transcript_id)) %>% 
  filter(evalue < 1) %>% 
  dplyr::select(transcript_id, cluster) %>%
  distinct() %>% 
  left_join(., tx2gene, by="transcript_id") %>%
  dplyr::select(!transcript_id) %>% 
  distinct() %>%
  group_by(gene_id) %>% 
  summarise(cluster = str_c(cluster, collapse = " | "))

master_report <- read_tsv("master_report.txt")
colnames(master_report) <- c("gene_id", "name","species") 
sim.report <- master_report %>% filter(species == "SIM")

venom.candidates <- resOrdered %>% 
  as.data.frame() %>% 
  rownames_to_column(var="gene_id") %>% 
  left_join(., hmm, by="gene_id") %>%
  filter(!is.na(cluster)) %>% 
  filter(padj < 0.05 & log2FoldChange < 0) %>% left_join(., sim.report) %>% filter(!is.na(name))

venom.candidates %>% dplyr::select(gene_id) %>% write_tsv("venom_candidates_sim_ax.tsv")

venom.candidates %>% write_tsv("cand_long_hmm.tsv")



