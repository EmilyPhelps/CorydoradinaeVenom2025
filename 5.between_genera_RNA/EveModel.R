#Test tree
library(evemodel)
library(ape)

twoThetaRes2table <- function(res, OGIDs){
  tibble( OG = OGIDs, 
          LRT = res$LRT) %>% 
    bind_cols(as_tibble(res$twoThetaRes$par)) %>% 
    dplyr::rename( theta = theta1, thetaShift = theta2, sigma.sq = sigma2) %>% 
    mutate( shift.direction = ifelse(thetaShift>theta, "up","down")) %>% 
    mutate( pval = pchisq(LRT,df = 1,lower.tail = F)) %>% 
    mutate( llTwoTheta = res$twoThetaRes$ll ) %>% 
    mutate( llOneTheta = res$oneThetaRes$ll ) %>% 
    mutate( isSig = pval < 0.05)
}

#write_rds(combined_matrix, "data/Lineage_comparison_combined_matrix.RDS")
combined_matrix <- read_rds("data/Lineage_comparison_combined_matrix.RDS")
phy.string <- read_lines("data/orthgroups/SpeciesTree_rooted.txt") %>% gsub("_renamed", "", .)
speciesTree <- read.tree(text = phy.string)

plot(speciesTree)

ordered <- relationships %>% arrange(factor(sample, levels = colnames(combined_matrix)))
dds <- DESeqDataSetFromMatrix(round(combined_matrix), colData = ordered, design = ~ species)


keep <- rowSums(counts(dds) > 50) >= 8

dds <- dds[keep,]

norm.data <- vst(dds)

mod.venom <- read_tsv("module_venom_candidates.tsv")
venom.candidates <- read_tsv("venom_ortholog.tsv") %>% filter(gene_id %in% mod.venom$gene_id) 


exprMat <- norm.data %>% 
            assay() %>% 
            as.data.frame() %>% rownames_to_column(var="Orthogroup") %>%
            filter(Orthogroup %in% venom.candidates$Orthogroup) %>%
            dplyr::select(!Orthogroup) %>% 
            as.matrix()

colSpecies <- str_sub(colnames(exprMat), 1, 3)
#BetasharedTest looks at shifts in the expression (phylogenetic ANOVA approach) whereas 
#Two tests shows if that branch was included in the expression shift

res <- betaSharedTest(tree = speciesTree, gene.data = exprMat, colSpecies = colSpecies)
pval = pchisq(res$LRT,df = 1,lower.tail = F)

rep.venom.genes <- norm.data %>% 
                   assay() %>% 
                   as.data.frame() %>% rownames_to_column(var="Orthogroup") %>%
                   filter(Orthogroup %in% venom.candidates$Orthogroup) %>% select(Orthogroup) 
Orthogroup <- rep.venom.genes$Orthogroup


venom.significance <- cbind(Orthogroup, pval) %>% as.tibble()

#select the branch you are testing (starting with 1 because we are looking for lineage specific changes)

thetaShiftBool <- 1:Nedge(speciesTree) %in% 
  getEdgesFromMRCA(speciesTree, tips = speciesTree$tip.label[4:length(speciesTree$tip.label)], includeEdgeToMRCA = T)

plot(speciesTree, edge.color = ifelse(thetaShiftBool, divergent[8],"black"),edge.width = 2)

plot(speciesTree)
nodelabels(1:length(speciesTree$node.label))
tiplabels(1:length(speciesTree$tip.label))
edgelabels(1:10)

#test.thetaShift <- twoThetaTest(tree = speciesTree, gene.data = exprMat, 
#                                     isTheta2edge = thetaShiftBool, colSpecies = colSpecies)

# Per species shifts
TUK <- c(rep("FALSE", 4), "TRUE", rep("FALSE", 5))
MET <- c(rep("FALSE", 3), "TRUE", rep("FALSE", 6))
ARC <- c(rep("FALSE", 2), "TRUE", rep("FALSE", 7))
SIM <- c(rep("FALSE", 6), "TRUE", rep("FALSE", 3))
NAR <- c(rep("FALSE", 8), "TRUE", rep("FALSE", 1))
REY <- c(rep("FALSE", 9), "TRUE")

#Per clade shifts
ARC_MET <- c(rep("FALSE", 1), rep("TRUE", 3), rep("FALSE", 6))
REY_NAR <-c(rep("FALSE", 7), rep("TRUE", 3))
L1_L9 <- c(rep("FALSE", 5), rep("TRUE", 5))
L9_L1 <- c(rep("TRUE", 5), rep("FALSE", 5))

boo.list <- list(TUK, MET, ARC, SIM, NAR, REY, ARC_MET, REY_NAR, L1_L9, L9_L1)
names(boo.list) <- c("TUK", "MET", "ARC", "SIM", "NAR", "REY", "ARC_MET", "REY_NAR", "L1_L9", "L9_L1")

#Check you are selecting the branches you intend
for (i in 1:length(boo.list)){
  plot(speciesTree, edge.color = ifelse(boo.list[[i]], divergent[8],"black"),edge.width = 2)
  title(paste0(names(boo.list)[[i]]))
}

venom.df <- data.frame()
for (i in 1:length(boo.list)){
  res <- twoThetaTest(tree = speciesTree, gene.data = exprMat, 
                       isTheta2edge = as.logical(boo.list[[i]]), colSpecies = colSpecies)
  tbl <- twoThetaRes2table(res, Orthogroup) %>% mutate(comp=paste0(names(boo.list)[i]))
  venom.df <- rbind(venom.df, tbl)
}


write_tsv(venom.df, "Venom_EVE_results.tsv")

hk.candidates <- read_tsv("hk_ortholog.tsv")

Orthogroup <-norm.data %>% 
  assay() %>% 
  as.data.frame() %>% rownames_to_column(var="Orthogroup") %>%
  filter(Orthogroup %in% hk.candidates$Orthogroup) %>% dplyr::select(Orthogroup)

exprMat <- norm.data %>% 
  assay() %>% 
  as.data.frame() %>% rownames_to_column(var="Orthogroup") %>%
  filter(Orthogroup %in% hk.candidates$Orthogroup) %>%
  dplyr::select(!Orthogroup) %>% 
  as.matrix()

hk.df <- data.frame()
for (i in 1:length(boo.list)){
  res <- twoThetaTest(tree = speciesTree, gene.data = exprMat, 
                      isTheta2edge = as.logical(boo.list[[i]]), colSpecies = colSpecies)
  tbl <- twoThetaRes2table(res, as.vector(Orthogroup)) %>% mutate(comp=paste0(names(boo.list)[i]))
  hk.df <- rbind(hk.df, tbl)
}

write_tsv(hk.df, "hk_EVE_results.tsv")


