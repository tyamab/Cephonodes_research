# Load the "tximport" package
library("tximport")
# Read sample information from a text file
s2c <- read.table("Sample2condition_midgut.txt", header=T, sep="\t",stringsAsFactors = FALSE)

# Read output files from RSEM
files <- s2c$path
names(files) <- s2c$sample

# Perform gene-level analysis using "tximport"
txi <- tximport(files,type="rsem", txIn=F ,txOut=F)

# Replace length 0 with 1
txi$length[txi$length==0] <- 1

# Create a sample table with conditions
sampleTable <- data.frame(condition=s2c$group)
rownames(sampleTable) <- colnames(txi$counts) # Using counts data from RSEM to DESeq2

# Run DESeq2
library("DESeq2")
dds <- DESeqDataSetFromTximport(txi, sampleTable, ~condition)
dds_lrt <- DESeq(dds, test="LRT", reduced=~1)
res_lrt <- results(dds_lrt)
res_lrt_naomit <- na.omit(res_lrt) # Remove NAs

# Sort genes by adjusted p-value
res_lrt_sort <- res_lrt_naomit[order(res_lrt_naomit$padj),]
# Write results to a text file
write.table(res_lrt_sort, file = "result_deseq2_lrt.txt", row.names = T, col.names = T, sep = "\t")

# Generate an MA plot
png("MAplot2.png")
pdf("MAplot.pdf")
plotMA(res_lrt, alpha = 0.001 ,ylim=c(-15,15))
dev.off()

