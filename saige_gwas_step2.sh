#!/bin/sh -l

#SBATCH --time=48:00:00
#SBATCH --job-name=saige_step2_array
#SBATCH --partition brc,shared
#SBATCh --output=array_saige.%A_%a.out
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-22%22

echo "Beginning job!"

module load apps/R/3.6.0

echo ${SLURM_ARRAY_TASK_ID}

CHR=${SLURM_ARRAY_TASK_ID}

echo ${CHR}

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

# assumes that intermediate datasets have been created in step 1 and are available

cd ${basepath}scripts/biomarkers_ukb/

# set up SAIGE - activate RSAIGE conda environment

export PATH=${basepath}software/anaconda3/bin:$PATH

source activate RSAIGE

FLAGPATH=`which python | sed 's|/bin/python$||'`
  export LDFLAGS="-L${FLAGPATH}/lib"
  export CPPFLAGS="-I${FLAGPATH}/include"

echo "Running SAIGE R script!"

### STEP 1 SHOULD HAVE BEEN RUN AND NULLGLMM FIT ###

#Rscript ${softwarebasepath}SAIGE/extdata/step1_fitNULLGLMM.R     \
#        --plinkFile=${outputbasepath}tmp_ukb18177_glanville_binary_pre_qc_no26_saige_pruned \
#        --phenoFile=${outputbasepath}prevalent_trd_gpcontrols_plink_pheno_saige.txt \
#        --phenoCol=trd_gpcontrols \
#        --covarColList=PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,PC16,PC17,PC18,PC19,PC20 \
#        --sampleIDColinphenoFile=IID \
#        --traitType=binary        \
#        --outputPrefix=${outputbasepath}out_trd_saige \
#        --nThreads=80 \
#        --LOCO=TRUE \
#        --IsOverwriteVarianceRatioFile=TRUE

Rscript ${softwarebasepath}SAIGE/extdata/step2_SPAtests.R \
        --bgenFile=${ukbpath}imputed/ukb18177_glanville_imp_chr${CHR}_MAF1_INFO4_v1.bgen \
	--sampleFile=${databasepath}ukb1817_imp_chr1_v2_s487398_tworowsremoved.sample \
	--bgenFileIndex=${ukbpath}imputed/ukb18177_glanville_imp_chr${CHR}_MAF1_INFO4_v1.bgen.bgi \
        --minMAC=10 \
	--chrom=${CHR} \
	--GMMATmodelFile=${outputbasepath}out_trd_saige.rda \
        --varianceRatioFile=${outputbasepath}out_trd_saige.varianceRatio.txt \
        --SAIGEOutputFile=${outputbasepath}binary_positive_signal_chr${CHR}_assoc.step2.txt \
        --IsOutputAFinCaseCtrl=TRUE

#
