#!/usr/bin/env Rscript
# ============================================================================ #
## set_dirs.R
## MGNG-TUS study: Set input and output directories for data processing.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

set_dirs <- function(rootDir){
  
  ## Root directory:
  
  dirs <- list()
  
  # -------------------------------------------------------------------------- #
  ## Root directories:
  
  dirs$root <- rootDir

  # -------------------------------------------------------------------------- #
  ## Code:
  dirs$codeDir    <- paste0(dirs$root, "analyses/")
  
  # -------------------------------------------------------------------------- #
  ## Data:
  
  ## Data:
  dirs$dataDir <- paste0(dirs$root, "data/")
  
  ## Raw data:
  dirs$rawDataDir <- paste0(dirs$dataDir, "raw/")

  # -------------------------------------------------------------------------- #
  ## Data sets:
  dirs$processedDataDir <- paste0(dirs$dataDir, "processed/")
  dir.create(dirs$processedDataDir, recursive = TRUE, showWarnings = FALSE) # recursive = TRUE)
  
  # -------------------------------------------------------------------------- #
  ## Results:
  
  dirs$resultDir <- paste0(dirs$root, "results/regression/")
  dir.create(dirs$resultDir, showWarnings = FALSE)
  
  ## Models:
  dirs$modelDir <- paste0(dirs$resultDir, "models/")
  dir.create(dirs$modelDir, showWarnings = FALSE)
  
  ## Plots:
  dirs$plotDir <- paste0(dirs$resultDir, "plots/")
  dir.create(dirs$plotDir, showWarnings = FALSE)
  
  return(dirs)
  
}

# END OF FILE.