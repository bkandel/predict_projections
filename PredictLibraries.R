.libPaths(c('/mnt/build/bkandel/code/rlib', 
            '/home/bkandel/code/R/R-2.15.1/library', 
	    '/home/bkandel/R/x86_64-unknown-linux-gnu-library/2.15',
	    '/home/srdas/lib64/R/lib', 
	    '/home/srdas/lib64/R/library'))
library(MASS)
library(ANTsR)
library(psych)
library(vegan)
library(DAAG)
library(methods) # this one is critical and should always be included in Rscripts
getPckg <- function(pckg) install.packages(pckg, repos = "http://cran.r-project.org")
pckg = try(require(getopt))
if(!pckg) {
cat("Installing 'getopt' from CRAN\n")
getPckg("getopt")
require("getopt")
}
pckg = try(require(Rniftilib))
if(!pckg) {
cat("Installing 'Rniftilib' from CRAN\n")
getPckg("Rniftilib")
require("Rniftilib")
}
pckg = try(require(misc3d))
if(!pckg) {
cat("Installing 'misc3d' from CRAN\n")
getPckg("misc3d")
require("misc3d")
}
pckg = try(require(rgl))
if(!pckg) {
cat("Installing 'rgl' from CRAN\n")
getPckg("rgl")
require("rgl")
}


