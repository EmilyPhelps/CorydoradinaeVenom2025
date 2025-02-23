#Boxplot1- Mortality data

box <- ggplot(mortality.data, aes(x=Treatment, y=mortality, color=Treatment)) + geom_boxplot(fill="transparent", outlier.shape=NA, width=0.5) +
  geom_jitter(alpha=0.6, width= 0.1, size=3) +
  labs(y="Mortality", x="Treatment") +
  scale_color_manual(values=c(theme_cols[2], scale1[4], scale2[4],scale1[8], scale2[8]), 
                     labels=c("Saline\nControl", "Corydoras\nmuscle", "Corydoras\nvenom", "Hoplisoma\nmuscle", " Holisoma\nvenom")) +
  scale_y_continuous(limits=c(0, 1.2), breaks=c(0, 0.25, 0.50, 0.75, 1.00)) +
  theme(legend.position = "none",
        panel.background = element_blank(),
        axis.title= element_text(size= 16, color=theme_cols[4]), 
        axis.text= element_text(size= 14, color=theme_cols[4]), 
        axis.line = element_line(linewidth = 0.5, 
                                 colour = theme_cols[3]),
        axis.ticks = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())

ggsave("DC3_box_plot.pdf", box, width=8, height=8)
