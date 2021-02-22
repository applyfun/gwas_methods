### Join regenie output - merge results from across chromosome files
### 22/02/21

### Requires session with >8GB memory to load all output files

### Execute the script: Rscript /path/to/output/files/ bin_CHROM_out_firth_trd
### the first argument should be the path to the output files (all ending .regenie, split by chromosome)
### the second argument is the file names with chromosome number replaced with "CHROM", eg. for chrom 1 "bin_1_out_firth_trd" -> "bin_CHROM_out_firth_trd"

print("Warning: this script must be run in a session with at least 8GB of RAM available")

library(data.table)

args <- commandArgs(trailingOnly = TRUE)

out_dir <- as.character(args[1])
filestring <- as.character(args[2])

# filestring should contain CHROM string as placeholder for chromosome number across files
# eg. bin_CHROM_out_firth_trd_gpcontrols

setwd(out_dir)

print("Attempting join across 23 chromosome files!")
print("------------------")

exc_ls <- list()

for (i in 1:23) {
  filestringchrom <- gsub("CHROM", i, filestring)

  print(filestringchrom)

  if (file.exists(paste0(out_dir, filestringchrom, ".regenie"))) {
    exc_ls[[i]] <- fread(paste0(out_dir, filestringchrom, ".regenie"))
  } else {
    print(paste0("------No chromosome ", i, " detected!"))
  }

  print(paste0("Processing chromosome ", i, " complete!"))
}

print("Joining...")

all_chroms <- do.call(rbind, exc_ls) # bind all in list

print(head(all_chroms))

print("Number of variants by chromosome: ")

print(table(all_chroms$CHROM))

print(paste0("There are ", NROW(all_chroms), " rows in the joined output"))

print("Joining all chromosomes complete!")

print("Converting -log10P-value column to P-value and sorting by descending values...")

all_chroms$P <- 10^-all_chroms$LOG10P

all_chroms <- all_chroms[order(P), ]

# save to file

print(paste0("Saving to file in ", out_dir))

savestring <- gsub("CHROM", "all_chromosomes", filestring)

fwrite(all_chroms, paste0(out_dir, savestring, ".tab"), sep = "\t")

print("Done!")
