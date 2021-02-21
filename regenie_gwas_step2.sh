#!/bin/sh -l

#SBATCH --time=24:00:00  
#SBATCH --job-name=regenie_step2_array 
#SBATCH --partition brc,shared
#SBATCh --output=array_regenie.%A_%a.out
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G 
#SBATCH --array=1-22%22
#SBATCH --mail-user=ryan.arathimos@kcl.ac.uk
#SBATCH --mail-type=FAIL,ARRAY_TASKS

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

cd ${outputbasepath}

# load regenie module and assign array task ID as Chromosome number
CHR=${SLURM_ARRAY_TASK_ID}

echo ${CHR} 

module load utilities/use.dev
module load apps/regenie/2.0.1-mkl

regenie \
  --step 2 \
  --bgen ${ukbpath}imputed/ukb18177_glanville_imp_chr${CHR}_MAF1_INFO4_v1.bgen \
  --sample ${samplepath}ukb1817_imp_chr1_v2_s487398.sample \
  --covarFile ${outputbasepath}flashpca_20pcs_ukb.tab \
  --phenoFile ${outputbasepath}prevalent_trd_gpcontrols_plink_pheno.txt \
  --remove ${outputbasepath}bolt_remove_IIDs_with_negatives_plink_file.txt \
  --bsize 500 \
  --bt \
  --firth --approx \
  --pThresh 0.05 \
  --pred ${outputbasepath}fit_bin_test_pred.list \
  --split \
  --out bin_${CHR}_out_firth

#

echo Done

