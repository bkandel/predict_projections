source("PredictLibraries.R")
source("PredictFunctions.R")

fileNames = list.files( path = '../out', 
          pattern = glob2rx("AbetaSparse05Cluster250TrainView1*.nii.gz"), full.names = TRUE )
input.train <- antsImageRead('../data/AbetaTrain.mha', dim = 2, 'float')
input.test <- antsImageRead('../data/AbetaTest.mha', dim = 2, 'float' ) 
demog.train <- read.csv('../demog/ADNICSFPredictionDemogTrain.csv')
demog.test <- read.csv('../demog/ADNICSFPredictionDemogTest.csv')
mask <- antsImageRead('../template/ADNI_gm_mask_trimmed.nii.gz', dim = 3, 'float' )
outcome <- "allAbetas"
result <- regress.projections( input.train, input.test, demog.train, demog.test, 
             vector.names = fileNames, mask, outcome, method = "all" )

