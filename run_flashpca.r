### Run FlashPCA
### Calculate PCs for UKB subset without relateds removed and generate 20 PCs

### 01/02/21

set.seed(123456)

library(data.table)
library(parallel)
library(foreach)
library(dplyr)
library(flashpcaR)

dirs <- read.table("~/brc_scratch/scripts/paths.txt")

#project_dir <- as.character(dirs[9, ])

data_dir <- as.character(paste0(dirs[8, ], "data/biomarkers_ukb/"))
output_dir <- as.character(paste0(dirs[8, ], "output/biomarkers_ukb/"))
scripts_dir <- as.character(paste0(dirs[8, ], "scripts/biomarkers_ukb/"))

ukb_dir <- as.character(paste0(dirs[14, ]))
core_path <- as.character(paste0(dirs[8, ]))

### install flashPCA if not already installed

#devtools::install_github("gabraham/flashpca/flashpcaR")

fn <- paste0(output_dir, "data_pruned2")

print(fn)

### run flashpca generating 20 PCs - runtime can exceed 3hrs for ~450k samples

f <- flashpca(fn, ndim = 20)

### save

saveRDS(f, paste0(output_dir, "flashpca_crude_res.rds"))

### check PCs with basic plots

plot(f$projection[, 3:4])

plot(f$projection[, 7:8])

### read in fam to add IID back in

fam <- fread(paste0(output_dir, "data_pruned2.fam"))

pcs20 <- as.data.frame(f$projection)

names(pcs20) <- paste0("PC", seq(1:20))

pcs20$IID <- fam$V1

pcs20$FID <- fam$V2

pcs20 <- pcs20[,c("FID","IID",paste0("PC",seq(1:20)))]

### exclude negative IDs (withdrawn participants) if any are still in the dataset

pcs20 <- pcs20[pcs20$IID>0,]

write.table(pcs20, paste0(output_dir, "flashpca_20pcs_ukb.tab"), row.names = F, col.names = T, quote = F)

#
