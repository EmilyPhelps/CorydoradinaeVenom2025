library(forcats)
library(ggtree)
#Need to calculate P.adjust values. Minus L1_L9 or L9_L1 as it is the same.
#P.adjusting filter out one of the L1/L9 comparisons because it is duplicated
#Maybe plot this along with the phylogenetic tree... could be an easy reveiwer comment
eve <- read_table("Venom_EVE_results.tsv")
eve <- eve %>% group_by(OG) %>% 
  filter(comp != "L1_L9") %>% 
  mutate(padj=p.adjust(pval, n=9))
eve.sig <- eve %>% filter(padj <= 0.05)

heat.data <- assay(norm.data) %>%
  as.data.frame() %>% 
  rownames_to_column(var="gene") %>% 
  filter(gene %in% as.vector(eve.sig$OG)) %>%
  left_join(., venom.candidates, by=c("gene" = "Orthogroup")) %>%
  pivot_longer(cols=MET_01_A1_1:ARC5_A2_1, names_to = "sample", values_to="norm.expression") %>%
  left_join(., relationships, by="sample") %>% 
  mutate(lineage=ifelse(lineage =="L1", "Corydoras", "Hoplisoma"), rename=paste0(gene,"\n", name))


heat.plot <-ggplot() + 
  geom_tile(heat.data, mapping=aes(x=sample, 
                                   y=rename, 
                                   fill=norm.expression)) +
  scale_fill_gradient2(low=divergent[4], 
                       mid=scale2[3], 
                       high=scale2[8]) +
  labs(x= "Individual", y="Candidate Venom Genes", fill="Normalized\nExpression") +
  facet_wrap(~ lineage, scales = "free_x",) +
  theme_minimal() +
  theme(legend.position="top",
        axis.text.x = element_text(angle = 75, vjust = 0.5, hjust=0.5),
        axis.text.y=element_text(size=12),
        axis.title=element_text(size=12, color=theme_cols[3]),
        axis.ticks=element_blank(),
        strip.text.x = element_text(
          size = 12, color=theme_cols[4]),
        strip.background = element_rect(
          color=theme_cols[3], size=0.3, linetype="solid"))

ggsave("heatmap_mim_lineage_test.pdf", width=15, height=10)

phy.string <- read_lines("data/orthgroups/SpeciesTree_rooted.txt") %>% gsub("_renamed", "", .)
speciesTree <- read.tree(text = phy.string)
ggtree(speciesTree) + geom_tiplab()

heat.data %>% 
  left_join(., eve.sig_lin, by=c("gene" = "OG")) %>% 
  filter(gene %in% as.vector(eve.sig$OG))

#Caluclate log fold changes
g <- eve.sig %>% filter(comp == "L9_L1")
mean <- norm.data %>% assay() %>%
  as.data.frame() %>%
  rownames_to_column(var="gene") %>% 
  filter(gene %in% g$OG) %>% 
  pivot_longer(MET_01_A1_1:ARC5_A2_1, names_to = "sample", values_to = "norm.count") %>%
  left_join(., relationships, by="sample") %>% 
  group_by(lineage, gene) %>%
  summarize(mean=mean(norm.count))

mean %>% 
  pivot_wider(names_from = lineage, values_from = mean) %>% ungroup() %>%
  group_by(gene) %>% 
  summarize(lfc=log2(L1/L9))


