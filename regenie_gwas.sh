#!/bin/bash -l

#SBATCH --mem=12G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=72:0:00
#SBATCH --partition brc,shared
#SBATCH --constraint="ivybridge"

echo "Beginning job!"

echo "Ivybridge!"

cd ~/brc_scratch/scripts/

basepath=$(sed '8q;d' paths.txt)
ukbpath=$(sed '14q;d' paths.txt)
samplepath=$(sed '17q;d' paths.txt)

echo $basepath
echo $ukbpath

outputbasepath=${basepath}output/biomarkers_ukb/
softwarebasepath=${basepath}software/

echo $outputbasepath
echo $softwarebasepath

echo "Paths set!"

#run regenie
cd ${softwarebasepath}

echo "Beginning job!"

cd  ${softwarebasepath}regenie

# regenie doesn't like bim files with chrom nums greater than 24

#module load apps/plink/1.9.0b6.10

#plink --bfile ${ukbpath}genotyped/ukb18177_glanville_binary_pre_qc --chr 1-22,X --make-bed --out ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26

# load regenie module

module load utilities/use.dev
module load apps/regenie/2.0.1-mkl

regenie \
  --step 1 \
  --bed ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26 \
  --extract ${ukbpath}2019_new_qc/ukb18177_glanville_post_qc_snp_list.txt \
  --phenoFile ${outputbasepath}prevalent_trd_gpcontrols_plink_pheno.txt \
  --remove ${outputbasepath}bolt_remove_IIDs_with_negatives_plink_file.txt \
  --bsize 1000 \
  --bt --lowmem \
  --lowmem-prefix ${outputbasepath}tmp_rg \
  --out ${outputbasepath}fit_bin_test

for CHR in {1..23}; do 

	module load utilities/use.dev
	module load apps/regenie/2.0.1-mkl

	echo ${CHR}

	regenie \
	  --step 2 \
	  --bgen ${ukbpath}imputed/ukb18177_glanville_imp_chr${CHR}_MAF1_INFO4_v1.bgen \
	  --sample ${samplepath}ukb1817_imp_chr1_v2_s487398.sample \
	  --covarFile ${outputbasepath}flashpca_20pcs_ukb.tab \
	  --phenoFile ${outputbasepath}prevalent_trd_gpcontrols_plink_pheno.txt \
	  --remove ${outputbasepath}bolt_remove_IIDs_with_negatives_plink_file.txt \
	  --bsize 400 \
	  --bt \
	  --firth --approx \
	  --pThresh 0.01 \
	  --pred ${outputbasepath}fit_bin_test_pred.list \
	  --split \
	  --out bin_${CHR}_out_firth

done

#

