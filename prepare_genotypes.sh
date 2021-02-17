#!/bin/bash -l 

#SBATCH --mem=16G 
#SBATCH --nodes=1 
#SBATCH --time=24:00:00
#SBATCH --partition brc,shared

echo "Beginning job!"

cd ~/brc_scratch/scripts/

basepath=$(sed '8q;d' paths.txt)
ukbpath=$(sed '14q;d' paths.txt)

echo $basepath
echo $ukbpath

module load apps/plink/1.9.0b6.10

plink --bfile ${ukbpath}genotyped/ukb18177_glanville_binary_pre_qc --indep-pairwise 1000 50 0.05 --exclude range ${basepath}software/flashpca/exclusion_regions_hg19.txt --out ${basepath}output/biomarkers_ukb/ukb

plink --bfile ${ukbpath}genotyped/ukb18177_glanville_binary_pre_qc  --extract ${basepath}output/biomarkers_ukb/ukb.prune.in --remove ${basepath}output/biomarkers_ukb/bolt_remove_IIDs_plink_file.txt --make-bed --out ${basepath}output/biomarkers_ukb/data_pruned

plink --bfile ${basepath}output/biomarkers_ukb/data_pruned  --extract ${ukbpath}2019_new_qc/ukb18177_glanville_post_qc_snp_list.txt --make-bed --out ${basepath}output/biomarkers_ukb/data_pruned2

cd ${basepath}output/biomarkers_ukb

rm data_pruned.bim
rm data_pruned.bed
rm data_pruned.fam


#
