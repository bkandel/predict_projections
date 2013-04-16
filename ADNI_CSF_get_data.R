#!/usr/bin/env Rscript

# This script will search the processed ADNI data for files that 
# have associated CSF data, concatenate the CSF and demographic 
# data with the filenames, and output a list of files for input
# to sccan along with an associated CSV file for regression in sccan.
# Important note: This script assumes only one image and one demog 
# entry per person--no support here for longitudinal data.  

# define constants
proportionOfDataForTraining = 2/3

fileNames = list.files(path = '/home/dwolk/data/ADNI_processed/out', 
                        pattern = '*CorticalThicknessNormalizedToTemplate.nii.gz', recursive = TRUE, full.names = TRUE)
fileBaseNames = basename(fileNames)
splitNames = strsplit(fileBaseNames, split = "_")
demog = read.csv('../demog/combinedBaselineMCIandCSF.csv')
mriImageCollectionInfo = read.csv('../demog/MCI_T1_4_10_2013.csv')
mriSubject = strsplit(as.character(mriImageCollectionInfo$Subject), split = "_")
mriRID = rep(NA, length(mriSubject))
mriSequence = rep(NA, length(mriSubject))
for ( i in 1:length(mriRID))
{
  mriRID[i] = mriSubject[[i]][3]
  mriSequence[i] = as.character(mriImageCollectionInfo$Description)[i]
}
mriRIDIndices = c(1:length(mriRID))
demogRIDIndices = c(1:dim(demog)[1])
indicesOfMRIInfo = rep(NA, length(fileBaseNames))
indicesOfDemog = rep(NA, length(fileBaseNames))
for (i in 1:length(indicesOfMRIInfo))
{
  RID = splitNames[[i]][4] # RID is fourth component in filename
  indicesOfMRIInfo[i] = mriRIDIndices[ which( mriRID == RID &  ( mriSequence == "MPRAGE" | 
                        mriSequence == "Sag IR-SPGR" | mriSequence == "MPRAGE SENS" | 
			mriSequence == "MP-RAGE" | mriSequence == "IR-SPGR" | 
			mriSequence == "ADNI       MPRAGE" ) ) ][1] 
			# Note: There are often repeat tests with the same description but 
			# different image ID's.  We take the first image for each subject. 
  indicesOfDemog[i] = demogRIDIndices[ which( as.character(sprintf('%0.4d', demog$RID) ) == RID ) ]
}
# remove duplicate images
uniqueSubjectIndices = which(!duplicated(indicesOfMRIInfo))
demogWithMRIInfo = cbind(demog[indicesOfDemog[uniqueSubjectIndices], ], 
                         mriImageCollectionInfo[indicesOfMRIInfo[uniqueSubjectIndices], ], 
			 data.frame(fileNames = fileNames[uniqueSubjectIndices] ) )
# retrieve CSF measurements from demog file: ADNI1 and ADNI2/GO named them differently
allCSF = data.frame(allAbetas = rep(NA, dim(demogWithMRIInfo)[1]), 
                    allTaus   = rep(NA, dim(demogWithMRIInfo)[1]),
		    allPTaus  = rep(NA, dim(demogWithMRIInfo)[1]) )
whADNI1 = which(demogWithMRIInfo$Phase == "ADNI1" )
whADNI2GO = which(demogWithMRIInfo$Phase == "ADNI2" | demogWithMRIInfo$Phase == "ADNIGO")
allCSF$allAbetas[whADNI1]   = demogWithMRIInfo$ABETA142[whADNI1]
allCSF$allAbetas[whADNI2GO] = demogWithMRIInfo$ABETA[whADNI2GO]
allCSF$allTaus[whADNI1]     = demogWithMRIInfo$TAU[whADNI1]
allCSF$allTaus[whADNI2GO]   = demogWithMRIInfo$TAUcsf2[whADNI2GO]
allCSF$allPTaus[whADNI1]    = demogWithMRIInfo$PTAU181P[whADNI1]
allCSF$allPTaus[whADNI2GO]  = demogWithMRIInfo$PTAU[whADNI2GO]
demogWithMRIInfo = cbind(demogWithMRIInfo, allCSF)

trainingRows = sample(1:dim(demogWithMRIInfo)[1], 
                      floor(dim(demogWithMRIInfo)[1] * proportionOfDataForTraining), 
		      replace = FALSE ) 
write(as.matrix(demogWithMRIInfo$fileNames[trainingRows]), 
      file = "../demog/ADNICSFPredictionNamesTrain.txt")
write.csv( demogWithMRIInfo$allAbetas[trainingRows], 
           file = "../demog/ADNICSFPredictionAbetaValuesTrain.csv", row.names = FALSE)
write(as.matrix(demogWithMRIInfo$fileNames[-trainingRows]), 
      file = "../demog/ADNICSFPredictionNamesTest.txt")
write.csv( demogWithMRIInfo$allAbetas[-trainingRows], 
           file = "../demog/ADNICSFPredictionAbetaValuesTest.csv", row.names = FALSE)
write.csv( demogWithMRIInfo[trainingRows], file = "../demog/ADNICSFPredictionDemogTrain.csv", row.names = FALSE )
write.csv( demogWithMRIInfo[-trainingRows], file = "../demog/ADNICSFPredictionDemogTest.csv", row.names = FALSE )
