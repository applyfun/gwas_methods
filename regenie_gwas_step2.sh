#!/bin/sh -l

#SBATCH --time=12:00:00  
#SBATCH --job-name=regenie_step2_array 
#SBATCH --partition brc,shared
#SBATCh --output=array_regenie.%A_%a.out
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G 
#SBATCH --array=1-22%22

echo "Beginning job!"

cd ~/brc_scratch/scripts/

basepath=$(sed '8q;d' paths.txt)
ukbpath=$(sed '14q;d' paths.txt)
samplepath=$(sed '17q;d' paths.txt)
outputbasepath=${basepath}output/biomarkers_ukb/

echo Basepath $basepath
echo UKBpath $ukbpath
echo Outputbasepath $outputbasepath
echo Samplepath$samplepath

echo "Paths set!"

# load regenie module and assign array task ID as Chromosome number

echo ${SLURM_ARRAY_TASK_ID}

CHR=${SLURM_ARRAY_TASK_ID}

echo ${CHR} 

module load utilities/use.dev
module load apps/regenie/2.0.1-mkl

cd ${outputbasepath}

regenie \
  --step 2 \
  --bgen ${ukbpath}imputed/ukb18177_glanville_imp_chr${CHR}_MAF1_INFO4_v1.bgen \
  --sample ${samplepath}ukb1817_imp_chr1_v2_s487398.sample \
  --covarFile ${outputbasepath}flashpca_20pcs_ukb.tab \
  --phenoFile ${outputbasepath}prevalent_trd_mddcontrols_plink_pheno.txt \
  --remove ${outputbasepath}bolt_remove_IIDs_with_negatives_plink_file.txt \
  --bsize 400 \
  --bt \
  --spa --approx \
  --pThresh 0.05 \
  --minINFO 0.6 \
  --minMAC 10 \
  --pred ${outputbasepath}fit_bin_trd_mddcontrols_pred.list \
  --out ${outputbasepath}bin_${CHR}_out_spa_trd_mdd_controls

#

echo Done

