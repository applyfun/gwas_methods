# Methods for mixed model GWAS in UKB

## BOLT-LMM ~ SAIGE ~ regenie

All three methods are adapted for the example of a binary trait (treatment resistant depression - TRD) with a highly skewed case-control ratio. 

Each method has different input requirements. SAIGE for example does not accept flags for exclusions of SNPs or IDs. The genotype data passed to it must therefore have exclusions applied beforehand.

The data preparation steps below must be adjusted to the current method being run.

All scripts depend on an external 'paths.txt' file to source directory paths from (no paths are listed in the individual scripts)

## For regenie
***

### Regenie input files 

The input files required and their structure are described below:

* Phenotype file 

Plain text tab-delimited format with the first two columns FID and IID, followed by the phenotype columns, as for plink. 
If mutiple phenotypes are to be used they should be listed in separate columns.
```
FID  IID  pheno1  pheno2
1001  1001  0  1
1002  1002  1  0
1003  1003  0  0
```

* Covariate file

Plain text tab-delimited format with the first two columns FID and IID, followed by the covariate columns (often PCs, sex, age etc.).
```
FID  IID  PC1  PC2  
1001  1001  0.0982  0.0343
1002  1002  0.0565  0.0746
1003  1003  0.0111  0.0928
```

* Exclusion files

Sample exclusion and variant exclusion files in regenie are specified using the --exclude/--remove options for sample IDs and variant IDs respectively (or the --keep/--extract options for lists to retain)
Note that exclusions based on relatedness are not required since regenie accounts for relatedness.

	* Sample exclusion files should be tab-delimited plain text with no header. The first column should contain FID and the second IID of each sample to exclude.

```
1002	1002
1009	1009
```

	* Variant exclusion files should be tab-delimited plain text with no header, containing only one column of variant IDs as named in genotype files.

```
rs12029
rs5859595
rs950684
````

* Genotype files

	* For step 1, genotype variants (in bed-bim-fam plink format) are used . These are stored on the cluster. Files should be processed using plink to ensure that only chromosome numbers 1-23 are included before passing to regenie.

	* For step 2, imputed variants are used. Imputed genotypes are stored on the cluster in bgen format. No processing is required for these files before passing to regenie. The sample file for the bgen files is also available on the cluster (specify just chr1 sample file as they do not vary by chromosome).


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



