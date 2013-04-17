#!/bin/sh
sccan=/home/bkandel/bin/ants/bin/sccan
# /home/bkandel/bin/ants/bin/sccan
# usage: NetworkRegression CurrentDirectory OutputDirectory VOI Fold NumberOfEigenvectors Sparsity ClusterThresh
OUTDIR=$1
VOI=$2
FOLD=$3
NEIGVECS=$4
SPARSITY=$5
CLUSTER=$6
TEMPLATEDIR=$7
DEMOGDIR=$8
DATADIR=$9


$sccan --svd network[${DATADIR}${VOI}Train.mha,${TEMPLATEDIR}ADNI_gm_mask_trimmed.nii.gz,\
             -0.${SPARSITY},\
	     ${DEMOGDIR}ADNICSFPrediction${VOI}ValuesTrain.csv] \
	     -i $FOLD \
	     --PClusterThresh $CLUSTER \
	     -n $NEIGVECS \
	     -o ${OUTDIR}${VOI}Sparse${SPARSITY}Cluster${CLUSTER}Train.nii.gz \
	     -r 0 \
	     -p 0 \
 	     > ${OUTDIR}${VOI}Sparse${SPARSITY}Cluster${CLUSTER}_log.txt
