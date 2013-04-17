#!/bin/sh
BASEDIR=/home/bkandel/data/ADNI_CSF/
DEMOGDIR=${BASEDIR}demog/
TEMPLATEDIR=${BASEDIR}template/
OUTDIR=${BASEDIR}/out/
DATADIR=${BASEDIR}/data/
fold=5
NEIGVECS=6

for dir in $OUTDIR $DATADIR
do
  if [ ! -d $dir ] ; then 
    mkdir $dir
  fi
done

for VOI in Abeta 
do
#  To generate .mha files--only needs to be done once. 
  sccan --imageset-to-matrix [${DEMOGDIR}ADNICSFPredictionNamesTrain.txt,\
                             ${TEMPLATEDIR}ADNI_gm_mask_trimmed.nii.gz ] \
			     -o ${DATADIR}${VOI}Train.mha  

  sccan --imageset-to-matrix [${DEMOGDIR}ADNICSFPredictionNamesTest.txt,\
                              ${TEMPLATEDIR}ADNI_gm_mask_trimmed.nii.gz ] \
			     -o ${DATADIR}${VOI}Test.mha  
  for CLUSTER in 0 100 200 300 400 500 700 1000
  do
    for SPARSITY in 01 02 03 04 05 # 06 07 08 09 10 
    do
      exe=" ./NetworkRegression.sh $OUTDIR $VOI $fold $NEIGVECS $SPARSITY $CLUSTER $TEMPLATEDIR $DEMOGDIR $DATADIR "
      qsub -pe serial 1 -S /bin/sh -wd $OUTDIR $exe
      sleep $(($RANDOM%3))
    done
  done
done

