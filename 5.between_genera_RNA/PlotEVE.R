library(forcats)
#Create a database summary of up and down significantly expressed venom genes.
eve <- read_table("Venom_EVE_results.tsv")
venom.df <- eve %>% group_by(OG) %>% 
  filter(comp != "L1_L9") %>% 
  mutate(padj=p.adjust(pval, n=9))
count <- venom.df %>% 
  filter(padj <= 0.05) %>% 
  group_by(comp, shift.direction) %>%
  tally()

valid_comps <- c("TUK", "MET", "ARC", "SIM", "NAR", "REY", "ARC_MET", "REY_NAR", "L9_L1")

formatted <- count %>%
  # Filter valid comps
  mutate(combined = ifelse(comp %in% valid_comps, 
                      ifelse(shift.direction == "up", paste0("+", n), paste0("-", n)),
                      "0")) %>%
  group_by(comp) %>%
  summarize(# Create a single string for up and down values
    formatted = paste0(ifelse(any(shift.direction == "up"), paste0("+", n[shift.direction == "up"]), "+0"),
      "/",ifelse(any(shift.direction == "down"), paste0("-", n[shift.direction == "down"]), "-0")),
    .groups = 'drop') 
phy.string <- read_lines("data/orthgroups/SpeciesTree_rooted.txt") %>% gsub("_renamed", "", .)
speciesTree <- read.tree(text = phy.string)
p <- ggtree(speciesTree) + geom_tiplab()
edge_comp <- c("L9_L1", "ARC_MET", "MET", "ARC", "TUK", "L1_L9", "SIM", "REY_NAR", "NAR", "REY")
edge=data.frame(speciesTree$edge, edge_num=1:nrow(speciesTree$edge), comp=edge_comp)
colnames(edge)=c("parent", "node", "edge_num", "comp")
edge <- edge %>% left_join(., formatted, by="comp")

p %<+% edge + geom_label(aes(x=branch, label=formatted))
ggsave("venom_tree.pdf", width=5, height=5)

#Plot EVE

ven.heat.ortho <- venom.df %>% filter(padj <= 0.05) %>% dplyr::select(OG) %>% distinct()

heat.data <- assay(norm.data) %>%
  as.data.frame() %>% 
  rownames_to_column(var="gene") %>% 
  filter(gene %in% as.vector(ven.heat.ortho$OG)) %>%
  left_join(., venom.candidates, by=c("gene" = "Orthogroup")) %>%
  pivot_longer(cols=MET_01_A1_1:ARC5_A2_1, names_to = "sample", values_to="norm.expression") %>%
  left_join(., relationships, by="sample") %>% 
  mutate(lineage=ifelse(lineage =="L1", "Corydoras", "Hoplisoma"))


heat.plot <-ggplot() + 
  geom_tile(heat.data, mapping=aes(x=sample, 
                                   y=name, 
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

ggsave("heat.plot_manuscript.pdf", heat.plot, width=12, height=7)




