#Effect of Size or Lineage on Wt

length.data <- read_csv("march_brine_shrimp_length_data.csv")

length.filt <- length.data %>% filter(str_detect(extract_name, "V")) %>%
  mutate(lineage=ifelse(str_detect(extract_name, "L1"), "L1", "L9")) %>% 
  filter(!is.na(length) & !is.na(tissue_weight)) %>% 
  mutate(tissue_weight=post_tube_weight-init_tube_weight) %>%
  filter(tissue_weight > 0) %>% 
  group_by(extract_name, tissue_weight, lineage) %>%
  summarize(av.length=mean(length))

t.test(data=length.filt, av.length ~ lineage)

lm <- lmer(tissue_weight ~ lineage + (1 | av.length), data=length.filt)
summary(lm)

simulation_output <- simulateResiduals(fittedModel = lm,
                                       n = 250,
                                       refit = FALSE)

plot(simulation_output)


emmeans(lm, pairwise ~ lineage)
