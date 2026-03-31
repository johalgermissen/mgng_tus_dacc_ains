#!/usr/bin/env Rscript
# ============================================================================ #
## set_dirs.R
## MGNG-TUS study: Set input and output directories for data processing.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

set_dirs <- function(rootDir){
  #' Initialize data directories for this project.
  #' Adjust directory structure to your own folder structure as necessary.
  #' @param rootDir scalar string, root directory (path to the GitHub folder "mgng_tus_dacc_ains" on the local machine).
  #' @return dirs  list with downstream data directories.
  
  ## Root directory:
  
  dirs <- list()
  
  # -------------------------------------------------------------------------- #
  ## Root directories:
  
  dirs$root <- rootDir

  # -------------------------------------------------------------------------- #
  ## Code:
  
  dirs$codeDir    <- file.path(dirs$root, "analyses", "regression")
  dirs$helperDir    <- file.path(dirs$codeDir, "helpers")
  dirs$funcDir    <- file.path(dirs$codeDir, "functions")
  
  # -------------------------------------------------------------------------- #
  ## Data:
  # Assume that there is a folder "data" within the root directory.
  
  ## Data:
  dirs$dataDir <- file.path(dirs$root, "data")
  
  ## Raw data:
  dirs$rawDataDir <- file.path(dirs$dataDir, "raw")

  # -------------------------------------------------------------------------- #
  ## Data sets:
  
  ## Where processed behavioural data goes:
  dirs$processedDataDir <- file.path(dirs$dataDir, "processed")
  # dir.create(dirs$processedDataDir, recursive = TRUE, showWarnings = FALSE) # recursive = TRUE)
  
  ## Other data sources:
  dirs$demographicsDir <- file.path(dirs$dataDir, "demographics")
  dirs$mappingDir <- file.path(dirs$dataDir, "session_mapping")
  dirs$simulationsDir <- file.path(dirs$dataDir, "simulations")
  
  # -------------------------------------------------------------------------- #
  ## Results:
  # Assume that there is a folder "results/regression" within the root directory.
  
  dirs$resultDir <- file.path(dirs$root, "results/regression")
  # dir.create(dirs$resultDir, showWarnings = FALSE)
  
  ## Models:
  dirs$modelDir <- file.path(dirs$resultDir, "models")
  # dir.create(dirs$modelDir, showWarnings = FALSE)
  
  ## Plots:
  dirs$plotDir <- file.path(dirs$resultDir, "plots")
  # dir.create(dirs$plotDir, showWarnings = FALSE)
  
  ## Parameters:
  dirs$paramDir <- file.path(dirs$root, "results", "cbm", "parameters")
  
  return(dirs)
  
}

# END OF FILE.