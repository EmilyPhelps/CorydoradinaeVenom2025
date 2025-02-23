#Rscript
library(tidyverse)
library(ggplot2)
library(stringr)
library(WGCNA)

trans <- read_tsv("./dds_norm_sim_ax25Nov.tsv") %>% 
          column_to_rownames(var="gene") %>% 
          as.matrix()


trans <- trans %>% t()
allowWGCNAThreads(nThreads= 15) 

sft <- pickSoftThreshold(trans,
  dataIsExpr = TRUE,
  corFnc = cor,
  networkType = "signed"
)

#powers <- seq(1,20)

#pdf("soft_power.pdf", width=20, height=10)
#plot(sft$fitIndices[, 1],
#     -sign(sft$fitIndices[, 3]) * sft$fitIndices[, 2],
#     xlab = "Soft Threshold (power)",
#     ylab = "Scale Free Topology Model Fit, signed R^2",
#     main = paste("Scale independence")
#)
#text(sft$fitIndices[, 1],
#     -sign(sft$fitIndices[, 3]) * sft$fitIndices[, 2],
#     labels = powers, cex = cex1, col = "red"
#)
#abline(h = 0.90, col = "red")
#plot(sft$fitIndices[, 1],
#     sft$fitIndices[, 5],
#     xlab = "Soft Threshold (power)",
#     ylab = "Mean Connectivity",
#     type = "n",
#     main = paste("Mean connectivity")
#)
#text(sft$fitIndices[, 1],
#     sft$fitIndices[, 5],
#     labels = powers,
#    cex = cex1, col = "red")
#dev.off()

cor <- WGCNA::cor

bwnet <- blockwiseModules(trans,
  maxBlockSize = 5000,
  TOMType = "signed",
  power = 20, 
  saveTOMs=TRUE,
  numericLabels = TRUE, 
  randomSeed = 1234)

readr::write_rds(bwnet, "wgcna_results_Nov.RDS")



