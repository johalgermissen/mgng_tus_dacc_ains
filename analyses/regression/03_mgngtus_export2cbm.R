#!/usr/bin/env Rscript
# ============================================================================ #
## 03_mgngtus_export2cbm.R
## MGNG-TUS study: Export data into .csv files to be read into MATLAB for computational modelling.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

rm(list = ls())

# ============================================================================ #
#### Set directories, load packages and custom functions: ####

## Set codeDir:
codeDir    <- dirname(rstudioapi::getSourceEditorContext()$path)
helperDir <- paste0(codeDir, "/helpers/")

## Load directories:
rootDir <- paste0(dirname(codeDir), "/")
source(paste0(helperDir, "set_dirs.R")) # Load packages and options settings
dirs <- set_dirs(rootDir)

## Directory to save data for Julia:
dirs$cbmDataDir <- paste0(dirs$processedDataDir, "cbm/")
dir.create(dirs$cbmDataDir, recursive = TRUE, showWarnings = FALSE) # recursive = TRUE)

## Load packages:
source(paste0(helperDir, "package_manager.R")) # Load packages and options settings

# ------------------------------------------------- #
## Load custom functions:

source(paste0(codeDir, "/functions/00_mgngtus_functions_regression.R")) # Load functions

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 01) Read in behavioral data: ####

## Sham:
data1 <- read_behavior(paste0(dirs$rawDataDir, "1_sham"))
table(data1$subjectID, data1$stim_ID)
data1 <- wrapper_preprocessing(data1)
data1$sonication_n <- 1
## dACC:
data2 <- read_behavior(paste0(dirs$rawDataDir, "2_dacc"))
table(data2$subjectID, data2$stim_ID)
table(data2$stim_ID)
data2 <- wrapper_preprocessing(data2)
data2$sonication_n <- 2
table(data2$cueRep_n)
table(data2$subject_n, data2$cueRep_n)
## aIns:
data3 <- read_behavior(paste0(dirs$rawDataDir, "3_ai"))
table(data3$subjectID, data3$stim_ID)
data3 <- wrapper_preprocessing(data3)
data3$sonication_n <- 3

## Concatenate:
data <- rbind(data1, data2, data3)
data$sonication_f <- factor(data$sonication_n, levels = c(1, 2, 3), labels = c("sham", "dACC", "aIns"))
data$sonication_short_f <- data$sonication_f

# ============================================================================ #
#### 02) Exclude subjects/ trials: ####

### 02a) Exclude subjects with incomplete sessions:
length(unique(data$subID))
table(data$subID, data$sonication_f)
incompleteSubs <- c("JIJS1080", "KYJF0110", "MRMO0104", "NACA0882")
outlierSubs <- c("EEMR0429")
excludeSubs <- sort(unique(c(incompleteSubs, outlierSubs)))
data <- subset(data, !(subID %in% excludeSubs))
table(data$subID, data$sonication_f)
length(unique(data$subID))

### 02b) Remove excessive cue repetitions:
data <- subset(data, cueRep_n %in% 1:20)

# ============================================================================ #
#### 03) Select and create new variables: ####

# --------------------------------------------------------- #
### Recompute consecutive subject ID:
oldSubVec <- sort(unique(data$subject_n))
newSubVec <- 1:length(unique(data$subject_n))
data$subject_n <- newSubVec[match(data$subject_n, oldSubVec)]
table(data$subject_n)

# --------------------------------------------------------- #
### Compute stimulus ID based on block, required action, valence:
data$stimulus_n <- (data$block_n - 1) * 4 + (1 - data$reqAction_n) * 2 + (2 - data$valence_n) # turn condition and block into stimulus ID

## Inspect:
# table(data$stimulus_n)
# sum(is.na(data$stimulus_n))
# table(data$subID, data$stimulus_n)
# table(data$subID, data$stimulus_n, data$block_n)

# --------------------------------------------------------- #
### Compute stimulus ID based on sonication session, block, required action, valence:
data$stimulus_all_n <- (data$sonication_n - 1) * 16 + (data$block_n - 1) * 4 + (1 - data$reqAction_n) * 2 + (2 - data$valence_n) # turn condition and block into stimulus ID

## Inspect:
# table(data$stimulus_all_n)
# sum(is.na(data$stimulus_all_n))
# table(data$subID, data$stimulus_all_n)
# table(data$subID, data$stimulus_all_n, data$block_n)

### Copy over stimulus position:
data$stimRep_n <- data$cueRep_n


# ============================================================================ #
#### 04) Save data: ####

## Inspect which subjects will be included:
length(unique(data$subID))
unique(data$subID)

## Select variables:
names(data)
selVarNames <- c("subject_n", "block_n", "stimulus_n", "stimRep_n", "reqAction_n", "valence_n", "response_n", "ACC_n", "RT_n", "validity_n", "outcome_n", "sonication_n")

## Sham data:
selData <- data[data$sonication_n == 1, selVarNames]
table(selData$sonication_n)
table(selData$stimulus_n)
length(unique(selData$subject_n))
fileName <- "mgngtus_sham.csv"
fullFileName <- paste0(dirs$cbmDataDir, fileName)
cat(paste0("Save ", fullFileName, " ...\n"))
write.csv(selData, fullFileName, row.names = F)
cat("... finished :-)\n")

## dACC data:
selData <- data[data$sonication_n == 2, selVarNames]
table(selData$sonication_n)
table(selData$stimulus_n)
fileName <- "mgngtus_dACC.csv"
fullFileName <- paste0(dirs$cbmDataDir, fileName)
cat(paste0("Save ", fullFileName, " ...\n"))
write.csv(selData, fullFileName, row.names = F)
cat("... finished :-)\n")

## aIns data:
selData <- data[data$sonication_n == 3, selVarNames]
table(selData$sonication_n)
table(selData$stimulus_n)
fileName <- "mgngtus_aIns.csv"
fullFileName <- paste0(dirs$cbmDataDir, fileName)
cat(paste0("Save ", fullFileName, " ...\n"))
write.csv(selData, fullFileName, row.names = F)
cat("... finished :-)\n")

## All sessions:
selData <- data[, selVarNames]
names(selData) <- gsub("stimulus_all_n", "stimulus_n", names(selData))
table(selData$sonication_n)
table(selData$stimulus_n)
fileName <- "mgngtus_all.csv"
fullFileName <- paste0(dirs$cbmDataDir, fileName)
cat(paste0("Save ", fullFileName, " ...\n"))
write.csv(selData, fullFileName, row.names = F)
cat("... finished :-)\n")

# END OF FILE.