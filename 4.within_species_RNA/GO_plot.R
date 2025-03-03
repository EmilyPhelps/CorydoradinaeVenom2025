#Plot of the significantly enriched house keeping genes
go <- read_csv("/Users/emilyphelps/Documents/T/Toxin_Project/Venom_Evolution_2024/all_gProfiler_drerio_20-12-2024_17-24-02__intersections.csv") 
domain_size <- 14485

go <- go %>% 
  mutate(expected_size=(query_size*term_size)/domain_size) %>%
  mutate(enrichment_factor=intersection_size/expected_size) %>%
  arrange(enrichment_factor) %>%
  mutate(term_name=factor(term_name, levels=term_name))

enrichment_plot <- function(data, leg){
  ggplot(data) + 
    geom_point(mapping=aes(y=log(enrichment_factor), 
                           x=term_name,
                           colour=negative_log10_of_adjusted_p_value, 
                           size=intersection_size), alpha=0.8) +
    scale_colour_gradient2(low=divergent[1], mid=divergent[7], high=divergent[9], limits=c(1, 7)) +
    scale_size_continuous(range=c(3,10), limits =c(1,350), breaks=c(10, 100, 300)) +
    coord_flip() +
    facet_grid(rows=vars(source), scale="free", space="free", drop=TRUE) +
    labs(x="GO Term Names", y="Log(enrichment)") +
    theme(
      legend.position = paste0(leg),
      strip.background = element_rect(fill = "white", 
                                      colour = theme_cols[4], 
                                      size = 1),
      panel.border = element_rect(color = theme_cols[4], 
                                  fill = NA, 
                                  size = 0.8),
      panel.background = element_blank(),
      axis.ticks.x=element_line(colour=theme_cols[4]),
      axis.ticks.y=element_blank(), 
      axis.text=element_text(size=10, 
                             colour=theme_cols[4]),
      axis.text.x=element_text(size=10, 
                               colour=theme_cols[4], 
                               hjust = 1),
      axis.title= element_text(color=theme_cols[4]), 
      axis.line = element_line(linewidth = 0.5, 
                               colour = theme_cols[3]),
      panel.grid.major=element_line(colour = theme_cols[3], 
                                    size=0.05),
      panel.grid.minor.x = element_blank())
}

pdf("MS_all_module_goterm_2.pdf", width=10, height=10)
go %>% filter(source !="TF") %>% enrichment_plot(., leg="right")
dev.off()

