#hmm_summary

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
  group_by(gene_id)


master_report <- read_tsv("master_report.txt") %>% filter(species == "SIM")
colnames(master_report) <- c("gene_id", "name", "species")

venom_families <- read_csv("venom_families.csv")
colnames(venom_families) <-c("family", "cluster", "X1") 
venom_families <- venom_families %>% dplyr::select(family, cluster)

data <- left_join(hmm, master_report) %>% 
  left_join(., venom_families) %>%
  distinct() %>% 
  group_by(family) %>% 
  tally() %>% arrange(n) %>%
  mutate(family=factor(family, levels=family))
  
  
plot <- ggplot(data) + 
  geom_col(mapping=aes(x=family, y=n, fill=n), colour="transparent") +
  coord_flip() +
  scale_fill_gradient2(low=divergent[1], mid=divergent[7], high=divergent[9]) +
  labs(x="Protein Family", y="Count") +
  theme(legend.position = "none",
    panel.background = element_blank(),
    axis.ticks.x=element_line(colour=theme_cols[4]),
    axis.ticks.y=element_blank(), 
    axis.text=element_text(size=10, colour=theme_cols[4]),
    axis.text.x=element_text(size=10, colour=theme_cols[4], hjust = 1),
    axis.title= element_text(color=theme_cols[4]), 
    axis.line = element_line(linewidth = 0.5, 
                             colour = theme_cols[3]),
    panel.grid.major=element_blank(),
    panel.grid.minor.x = element_blank())

pdf("DC3_HMM_summary.pdf")
plot
dev.off()
mod <- read_tsv("module_venom_candidates.tsv")
long <- read_tsv("cand_long_hmm.tsv") %>% 
  separate(cluster, into = c(paste0("V", seq(1:5))), sep="\\|") %>%
  pivot_longer(cols = starts_with("V"), names_to = "variable", values_to = "cluster", values_drop_na = TRUE) %>%
  mutate(cluster=str_trim(cluster)) %>%
  left_join(venom_families) %>% filter(gene_id %in% mod$gene_id) %>% 
  group_by(family) %>% 
  tally() %>% arrange(n) %>%
  mutate(family=factor(family, levels=family))

plot <- ggplot(long) + 
  geom_col(mapping=aes(x=family, y=n, fill=n), colour="transparent") +
  coord_flip() +
  scale_fill_gradient2(low=divergent[1], mid=divergent[7], high=divergent[9]) +
  labs(x="Protein Family", y="Count") +
  scale_y_continuous(breaks=seq(2,14, 2), limits=c(0,14)) +
  theme(legend.position = "none",
        panel.background = element_blank(),
        axis.ticks.x=element_line(colour=theme_cols[4]),
        axis.ticks.y=element_blank(), 
        axis.text=element_text(size=10, colour=theme_cols[4]),
        axis.text.x=element_text(size=10, colour=theme_cols[4], hjust = 1),
        axis.title= element_text(color=theme_cols[4]), 
        axis.line = element_line(linewidth = 0.5, 
                                 colour = theme_cols[3]),
        panel.grid.major=element_blank(),
        panel.grid.minor.x = element_blank())



pdf("Ms_DC3_HMM_summary_venoms.pdf", width=10, height=8)
plot
dev.off()

