#!/bin/bash -l 

#SBATCH --mem-per-cpu=6G 
#SBATCH --nodes=1 
#SBATCH --ntasks=12 
#SBATCH --time=120:00:00
#SBATCH --partition brc,shared
#SBATCH --output=saige_gwas_step1.out.log

echo "Beginning job!"

module load apps/R/3.6.0

cd ~/brc_scratch/scripts/

basepath=$(sed '8q;d' paths.txt)
ukbpath=$(sed '14q;d' paths.txt)
samplepath=$(sed '17q;d' paths.txt)

echo $basepath
echo $ukbpath
echo $samplepath

databasepath=${basepath}data/biomarkers_ukb/
outputbasepath=${basepath}output/biomarkers_ukb/
softwarebasepath=${basepath}software/

echo $softwarebasepath
echo $outputbasepath

# create intermediate dataset with QC applied since SAIGE doesn't accept exclusions/removals lists

module load apps/plink/1.9.0b6.10

plink --bfile ${ukbpath}genotyped/ukb18177_glanville_binary_pre_qc \
--chr 1-22,X \
--make-bed \
--remove ${outputbasepath}bolt_remove_IIDs_with_negatives_plink_file.txt \
--exclude ${outputbasepath}bolt_remove_snps_file.txt \
--out ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige

# prune
plink --bfile ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige --indep-pairwise 1000 50 0.8 --out  ${outputbasepath}saige_prune_08_exclusions_ukb_tmp

# extract
plink --bfile ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige  --extract ${outputbasepath}saige_prune_08_exclusions_ukb_tmp.prune.in --make-bed --out ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige_pruned

# remove intermediate files

rm ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige.bed
rm ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige.bim
rm ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige.fam

# Rscript to merge phenotype file with PCs since SAIGE requires covars in the same file as pheno

cd ${basepath}scripts/biomarkers_ukb/

Rscript --vanilla merge_pheno_covars_saige.r ${outputbasepath}prevalent_trd_gpcontrols_plink_pheno.txt ${outputbasepath}flashpca_20pcs_ukb.tab ${outputbasepath}prevalent_trd_gpcontrols_plink_pheno_saige.txt

# set up SAIGE - activate RSAIGE conda environment

export PATH=${basepath}software/anaconda3/bin:$PATH

source activate RSAIGE

FLAGPATH=`which python | sed 's|/bin/python$||'`
  export LDFLAGS="-L${FLAGPATH}/lib"
  export CPPFLAGS="-I${FLAGPATH}/include"

echo "Running SAIGE R script!"

Rscript ${softwarebasepath}SAIGE/extdata/step1_fitNULLGLMM.R     \
        --plinkFile=${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige_pruned \
        --phenoFile=${outputbasepath}prevalent_trd_gpcontrols_plink_pheno_saige.txt \
        --phenoCol=trd_gpcontrols \
        --covarColList=PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,PC16,PC17,PC18,PC19,PC20 \
        --sampleIDColinphenoFile=IID \
        --traitType=binary        \
        --outputPrefix=${outputbasepath}out_trd_saige \
        --nThreads=80 \
        --LOCO=TRUE \
        --IsOverwriteVarianceRatioFile=TRUE

### STEP 2 NOW IN SEPARATE JOB SCRIPT ###

#Rscript ${softwarebasepath}SAIGE/extdata/step2_SPAtests.R \
#        --bgenFile=${ukbpath}imputed/ukb18177_glanville_imp_chr11_MAF1_INFO4_v1.bgen \
#	--sampleFile=${databasepath}ukb1817_imp_chr1_v2_s487398_tworowsremoved.sample \
#	--bgenFileIndex=${ukbpath}imputed/ukb18177_glanville_imp_chr11_MAF1_INFO4_v1.bgen.bgi \
#        --minMAC=10 \
#	--chrom=11 \
#	--GMMATmodelFile=${outputbasepath}out_trd_saige.rda \
#        --varianceRatioFile=${outputbasepath}out_trd_saige.varianceRatio.txt \
#        --SAIGEOutputFile=${outputbasepath}binary_positive_signal_chr11.assoc.step2.txt \
#        --IsOutputAFinCaseCtrl=TRUE

#
