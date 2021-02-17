#!/bin/bash -l 

#SBATCH --mem-per-cpu=12G 
#SBATCH --nodes=1 
#SBATCH --ntasks=10 
#SBATCH --time=120:00:00
#SBATCH --partition brc,shared 
#SBATCH --output=boltlmm_gwas.out.log

echo "Beginning job!"

cd ~/brc_scratch/scripts/

basepath=$(sed '8q;d' paths.txt)
ukbpath=$(sed '14q;d' paths.txt)
samplepath=$(sed '17q;d' paths.txt)

echo $basepath
echo $ukbpath
echo $samplepath

outputbasepath=${basepath}output/biomarkers_ukb/
softwarebasepath=${basepath}software/

echo $softwarebasepath
echo $outputbasepath

# create version of data without chrom number 24 25 26 

module load apps/plink/1.9.0b6.10

plink --bfile ${ukbpath}genotyped/ukb18177_glanville_binary_pre_qc --chr 1-22,X --make-bed --out ${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26

# run bolt

cd ${softwarebasepath}BOLT-LMM_v2.3.4

./bolt --bed=${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26.bed --bim=${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26.bim \
--fam=${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26.fam \
--geneticMapFile=${softwarebasepath}BOLT-LMM_v2.3.4/tables/genetic_map_hg19_withX.txt.gz \
--remove=${outputbasepath}bolt_remove_IIDs_with_negatives_plink_file.txt \
--exclude=${outputbasepath}bolt_remove_snps_file.txt \
--phenoFile=${outputbasepath}prevalent_trd_gpcontrols_plink_pheno.txt \
--phenoCol=trd_gpcontrols \
--lmm \
--LDscoresFile=${softwarebasepath}BOLT-LMM_v2.3.4/tables/LDSCORE.1000G_EUR.tab.gz \
--covarFile=${outputbasepath}flashpca_20pcs_ukb.tab \
--qCovarCol=PC{1:20} \
--numThreads=10 \
--bgenFile=${ukbpath}imputed/ukb18177_glanville_imp_chr{1:22}_MAF1_INFO4_v1.bgen \
--sampleFile=${samplepath}ukb1817_imp_chr1_v2_s487398.sample \
--statsFileBgenSnps=${outputbasepath}statsbgen.tab \
--statsFile=${outputbasepath}stats.tab \
--bgenMinMAF=0.01 \
--bgenMinINFO=0.6
