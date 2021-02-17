library(data.table)

args = commandArgs(trailingOnly=TRUE)

phenofile <- as.character(args[1])
covarfile <- as.character(args[2])
outfile <- as.character(args[3])

print(phenofile)

print(covarfile)

pheno <- fread(phenofile)
covars <- fread(covarfile)

print(head(pheno))

print(dim(pheno))

print(head(covars))

print(dim(covars))

m1 <- merge(pheno, covars, by=c("IID","FID"))

print(head(m1))

print(dim(m1))

write.table(m1, file=paste0(outfile), row.names=F, quote=F, col.names=T)

print("Done!")
