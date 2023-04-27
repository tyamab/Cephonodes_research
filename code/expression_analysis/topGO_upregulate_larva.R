library(topGO)
# number <- 500
#4.3 custom anntations
geneID2GO <- readMappings(file = "Chylas_interproscan_final.txt")
geneNames <- names(geneID2GO)

#input DEG information
DEGgene <- read.table("allGene_pval.txt")
##larva < 0 larva >0 and adj p value
DEGgeneNames <- DEGgene$V1[DEGgene$V2 > 0 & DEGgene$V3 < 0.001]

#4.4 predefined list of interesting genes
#myInterestingGenes <- sample(geneNames, length(geneNames) / 10)
myInterestingGenes <- DEGgeneNames
geneList <- factor(as.integer(geneNames %in% myInterestingGenes))
names(geneList) <- geneNames

# make topGOdata object
GOdata <- new("topGOdata", ontology = "BP", allGenes = geneList, annot = annFUN.gene2GO, gene2GO = geneID2GO)
#runnig topGO (fisher Kolmogorov-Smirnov )
resultFis <- runTest(GOdata, algorithm = "classic", statistic = "fisher")
resultKS <- runTest(GOdata, algorithm = "classic", statistic = "ks")
#look at the results



#CC
GOdata_CC <- new("topGOdata", ontology = "CC", allGenes = geneList ,annot = annFUN.gene2GO, gene2GO = geneID2GO)
resultFis_CC <- runTest(GOdata_CC, algorithm = "classic", statistic = "fisher")
resultKS_CC <- runTest(GOdata_CC, algorithm = "classic", statistic = "ks")


#MF
GOdata_MF <- new("topGOdata", ontology = "MF", allGenes = geneList, annot = annFUN.gene2GO, gene2GO = geneID2GO)
resultFis_MF <- runTest(GOdata_MF, algorithm = "classic", statistic = "fisher")
resultKS_MF <- runTest(GOdata_MF, algorithm = "classic", statistic = "ks")


allGO = usedGO(object = GOdata)
allRes <- GenTable(GOdata, Fisher = resultFis, KS = resultKS, orderBy = "Fisher", ranksOf = "Fisher", topNodes = length(allGO), numChar=1000)
##########
allRes$num_genes <- c(rep(length(myInterestingGenes),nrow(allRes)))
allRes$Fisher[allRes$Fisher == "< 1e-30"] <- 1e-30
FDR <- p.adjust(allRes$Fisher,method="BH")
pre_all_res_final1=cbind(allRes,FDR)
all_res_final1 <- pre_all_res_final1[order(pre_all_res_final1$FDR),]
##########
write.table(all_res_final1,"BP_larva.topGO",sep="\t",col.names=T, row.names=T, quote=F)

allGO = usedGO(object = GOdata_CC)
allRes_CC <- GenTable(GOdata_CC, Fisher = resultFis_CC, KS = resultKS_CC, orderBy = "Fisher", ranksOf = "Fisher", topNodes = length(allGO), numChar=1000)
##########
allRes_CC$num_genes <- c(rep(length(myInterestingGenes),nrow(allRes_CC)))
allRes_CC$Fisher[allRes_CC$Fisher == "< 1e-30"] <- 1e-30
FDR <- p.adjust(allRes_CC$Fisher,method="BH")
pre_all_res_final2=cbind(allRes_CC,FDR)
all_res_final2 <- pre_all_res_final2[order(pre_all_res_final2$FDR),]
##########
write.table(all_res_final2,"CC_larva.topGO",sep="\t",col.names=T, row.names=T, quote=F)

allGO = usedGO(object = GOdata_MF)
allRes_MF <- GenTable(GOdata_MF, Fisher = resultFis_MF, KS = resultKS_MF, orderBy = "Fisher", ranksOf = "Fisher", topNodes = length(allGO), numChar=1000)
allRes_MF$num_genes <- c(rep(length(myInterestingGenes),nrow(allRes_MF)))
allRes_MF$Fisher[allRes_MF$Fisher == "< 1e-30"] <- 1e-30
FDR <- p.adjust(allRes_MF$Fisher,method="BH")
pre_all_res_final3=cbind(allRes_MF,FDR)
all_res_final3 <- pre_all_res_final3[order(pre_all_res_final3$FDR),]
##########
write.table(all_res_final3,"MF_larva.topGO",sep="\t",col.names=T, row.names=T, quote=F)

#histogram
#p.values <- score(resultFis)
#p.values
#hist(p.values)

#distribution
goID <- allRes[10, "GO.ID"]
showGroupDensity(GOdata,goID,ranks = FALSE,rm.one = FALSE)

