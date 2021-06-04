#!/bin/bash -l

#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=24:00:00
#SBATCH --partition brc,shared
#SBATCH --output=regenie_gwas_step1.out

# could use constraint="ivybridge"

echo "Beginning job!"

cd ~/brc_scratch/scripts/

basepath=$(sed '8q;d' paths.txt)
ukbpath=$(sed '14q;d' paths.txt)
samplepath=$(sed '17q;d' paths.txt)

echo $basepath
echo $ukbpath

# set output path

outputbasepath=${basepath}output/biomarkers_ukb/

scriptsbasepath=${basepath}scripts/biomarkers_ukb/

echo $outputbasepath

echo "Paths set!"

# run regenie

cd  ${outputbasepath}regenie

# regenie doesn't like bim files with chrom nums greater than 24

module load apps/plink/1.9.0b6.10

plink --bfile ${ukbpath}genotyped/ukb18177_glanville_binary_pre_qc --chr 1-22,X --make-bed --out ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26

# load regenie module

module load utilities/use.dev
module load apps/regenie/2.0.1-mkl

cd ${scriptsbasepath}

regenie \
  --step 1 \
  --bed ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26 \
  --extract ${ukbpath}2019_new_qc/ukb18177_glanville_post_qc_snp_list.txt \
  --phenoFile ${outputbasepath}prevalent_trd_mddcontrols_plink_pheno.txt \
  --remove ${outputbasepath}bolt_remove_IIDs_with_negatives_plink_file.txt \
  --covarFile ${outputbasepath}flashpca_20pcs_ukb.tab \
  --bsize 1000 \
  --bt --lowmem \
  --lowmem-prefix ${outputbasepath}tmp_rg_mddcontrols \
  --out ${outputbasepath}fit_bin_trd_mddcontrols

# submit step2 job array - comment out if step 2 to be submitted manually

cd ${scriptsbasepath}

sbatch regenie_gwas_step2.sh

echo Done

#


