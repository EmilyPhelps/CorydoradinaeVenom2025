#Rscript
#Author: Emily Phelps
#Analyse brine shrimp potency assay

source("/Users/emilyphelps/Documents/T/Toxin_Project/Brine_Shrimp_Assay/packages.R")
source("/Users/emilyphelps/Documents/T/Toxin_Project/Brine_Shrimp_Assay/colours.R")

data <- read_csv("Brine_Shrimp_Assay_15thMarch2024.csv") %>%
  mutate(mortality=(Survival_24/ Total))

length.data <- read_csv("march_brine_shrimp_length_data.csv") %>% 
  filter(treatment != "C") %>% 
  mutate(tissue_weight=as.numeric(tissue_weight))

length.temp <- length.data %>% 
  group_by(extract_name) %>% 
  mutate(av.tissue.wt=(max(tissue_weight)+min(tissue_weight))/2, 
         av.length=(max(length)+min(length))/2) %>%     
  select(extract_name, av.tissue.wt, av.length)

mortality.data <- data %>% 
  left_join(., length.temp, by=c("Extract" = "extract_name")) %>% 
  mutate(lineage =ifelse(Treatment =="C", NA, substr(Extract, 1, 2)), 
         tissue=ifelse(Treatment =="C", NA, substr(Extract, 3,3)))


#Create the ID column
# Create an empty vector to store the modified IDs
modified_ids <- character(nrow(mortality.data))

# Iterate over each row
for (i in seq_along(mortality.data$Treatment)) {
  # Use gsub to remove Treatment from Extract in each row and assign it to the corresponding index in modified_ids
  modified_ids[i] <- gsub(mortality.data$Treatment[i], "", 
                          mortality.data$Extract[i])
}

# Assign the modified IDs to the ID column in mortality.data
mortality.data$ID <- modified_ids

mortality.data <- mortality.data %>% 
                  mutate(ID=paste0(lineage, ID), 
                         length_m=as.numeric(av.length)*0.001) %>%
                  distinct() %>% 
                  filter(!c(Plate == "1" & Well %in% remove))

model.glmm.treat <- lme4::glmer(mortality ~ tissue * lineage + 
                                  length_m + (1 | ID),
                                data = mortality.data,
                                family = binomial,
                                weights = Total)

summary(model.glmm.treat)

simulation_output <- simulateResiduals(fittedModel = model.glmm.treat,
                                       n = 250,
                                       refit = FALSE)

plot(simulation_output)

model.glmm.treat <- lme4::glmer(mortality ~ tissue * lineage + (1 | ID),
                                data = mortality.data,
                                family = binomial,
                                weights = Total)

simulation_output <- simulateResiduals(fittedModel = model.glmm.treat,
                                       n = 250,
                                       refit = FALSE)

plot(simulation_output)
summary(model.glmm.treat)

emm <- emmeans(model.glmm.treat, pairwise ~ tissue | lineage)
emm_df <- as.data.frame(emm$emmeans)
emm_df

emmeans(model.glmm.treat, pairwise ~  lineage | tissue)
emmeans(model.glmm.treat, pairwise ~   tissue | lineage)

control <- mortality.data %>% mutate(tissue=ifelse(is.na(tissue), "C", tissue))

control.glm <- lme4::glmer(mortality ~ tissue + (1 | ID),
                           data = control,
                           family = binomial,
                           weights = Total)

simulation_output <- simulateResiduals(fittedModel = model.glmm.treat,
                                       n = 250,
                                       refit = FALSE)

plot(simulation_output)
summary(control.glm)

emm <- emmeans(control.glm, pairwise ~ tissue)
emm


