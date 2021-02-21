# Methods for mixed model GWAS in UKB

## BOLT-LMM ~ SAIGE ~ regenie

All three methods are adapted for the example of a binary trait (treatment resistant depression - TRD) with a highly skewed case-control ratio. 

Each method has different input requirements. SAIGE for example does not accept flags for exclusions of SNPs or IDs. The genotype data passed to it must therefore have exclusions applied beforehand.

The data preparation steps below must be adjusted to the current method being run.

All scripts depend on an external 'paths.txt' file to source directory paths from (no paths are listed in the individual scripts)

### Step 1 - Prepare files for GWAS and generate PCs using flashPCA 

#### Prepare genotype files/exclusions lists/phenotype files/covariate files

The prepare_for_gwas.script will create needed intermediate files for each method. Note that not all steps in the script are required for all methods.

Phenotype and covariate files are unique to each analysis and need to be available in standard format required by plink; in a tab-delimited text file with the first two columns denoting FID and IID

#### Step 1.2 - Generate PCs for samples in the European ancestry cluster and retains related individuals (final steps in prepare_for_gwas.script file)

Before generating PCs using flashPCA in R, pruning of genotype data is required. Submit the prepare_genotypes.sh job file to the cluster.

FlashPCA is run from within R. Note that runtime will exceed 3hrs for ~450k samples

### Step 2 - Install the GWAS method of interest using the install scripts as guides

Some edits to the install scripts (install_saige.script, install_boltlmm.script) may be needed depending on the user setup. Regenie is available as a module on the cluster.

Installation for each method should be done interactively in an interactive session.

### Step 3 - Run GWAS

Submit each GWAS job file to the cluster, eg.

```
sbatch saige_gwas.sh
```

Regenie uses a two step process, with step 1 decoupled from step 2. Regenie GWAS can be run using the regenie_gwas.sh job submission 
file, which loops step 2 over each chromosome number. Alternatively, regenie can be run using the regenie_gwas_step1.sh job submission file, followed by the regenie_gwas_step2.sh job submission file, which creates a job array for step 2, 
with each task processing one chromosome number. Note regenie_gwas_step1.sh atumatically submits the step 2 job array at the end of the script (no need to manually submit the job array to the cluster once step 1 finishes).



