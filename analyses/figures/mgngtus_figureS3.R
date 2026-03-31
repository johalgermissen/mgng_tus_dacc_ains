#!/usr/bin/env Rscript
# ============================================================================ #
## mgngtus_figureS3.R
## MGNG-TUS study: Make plots for Figure S3A-C.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

rm(list = ls())

# ============================================================================ #
#### Set directories, load packages and custom functions: ####

## Set codeDir:
codeDir    <- dirname(dirname(rstudioapi::getSourceEditorContext()$path))
helperDir <- file.path(codeDir, "regression", "helpers")

## Load directories:
rootDir <- dirname(codeDir)
source(file.path(helperDir, "set_dirs.R")) # Load packages and options settings
dirs <- set_dirs(rootDir)
dirs$source <- file.path(dirs$root, "results", "cbm", "source")

## Load packages:
source(file.path(helperDir, "package_manager.R")) # Load packages and options settings

# ------------------------------------------------- #
## Load custom functions:

source(file.path(codeDir, "regression", "functions", "00_mgngtus_functions_regression.R")) # Load functions

# ============================================================================ #
#### Read in behavioral data: ####

# ----------------------------------- #
## Read in behavioral data:

## Sham:
data1 <- read_behavior(file.path(dirs$rawDataDir, "1_sham"))
table(data1$subjectID, data1$stim_ID)
data1 <- wrapper_preprocessing(data1)
data1$sonication_n <- 1
## dACC:
data2 <- read_behavior(file.path(dirs$rawDataDir, "2_dacc"))
table(data2$subjectID, data2$stim_ID)
table(data2$stim_ID)
data2 <- wrapper_preprocessing(data2)
data2$sonication_n <- 2
table(data2$cueRep_n)
table(data2$subject_n, data2$cueRep_n)
## aIns:
data3 <- read_behavior(file.path(dirs$rawDataDir, "3_ai"))
table(data3$subjectID, data3$stim_ID)
data3 <- wrapper_preprocessing(data3)
data3$sonication_n <- 3

## Concatenate:
data <- rbind(data1, data2, data3)
data$sonication_f <- factor(data$sonication_n, levels = c(1, 2, 3), labels = c("sham", "dACC", "aIns"))
data$sonication_short_f <- data$sonication_f

# ============================================================================ #
#### Exclude subjects with incomplete sessions or outlier behaviour: ####

length(unique(data$subID))
table(data$subID, data$sonication_f)
incompleteSubs <- c("JIJS1080", "KYJF0110", "MRMO0104", "NACA0882")
outlierSubs <- c("EEMR0429")
excludeSubs <- sort(unique(c(incompleteSubs, outlierSubs)))
data <- subset(data, !(subID %in% excludeSubs))
table(data$subID, data$sonication_f)
length(unique(data$subID))

# ============================================================================ #
#### Exclude excessive cue repetitions: ####

data <- subset(data, cueRep_n %in% 1:20)

# ============================================================================ #
#### Select data, standardize variables: ####

modData <- select_standardize(data)

# ============================================================================ #
#### Figure S3A: ####

## Select only sham data:
plotData <- droplevels(subset(modData, sonication_f == "sham"))

yLimRT <- c(0.3, 1.2)
isSave <- F
custom_barplot2(plotData, yVar = "RT_n", xVar = "reqAction_f", zVar = "valence_f",
                yLim = yLimRT, 
                isPoint = T, isConnect = T, savePNG = isSave, savePDF = isSave)

## Aggregate:
plotData$y <- plotData$RT_n
plotData$x <- plotData$reqAction_f
plotData$z <- plotData$valence_f
plotData$subject <- plotData$subject_f
aggrData_long <- ddply(plotData, .(subject, x, z), function(x){
  y <- mean(x$y, na.rm = T)
  return(data.frame(y))
  dev.off()})
aggrData_long$condition <- paste0(aggrData_long$x, "2", aggrData_long$z)
aggrData_long[, c("x", "z")] <- list(NULL)
aggrData_wide <- reshape(aggrData_long, direction = "wide",
                         idvar = "subject", v.names = "y", timevar = c("condition"))
## Save:
write.table(aggrData_wide[, 2:5], file.path(dirs$source, "FigS3A.csv"), sep = ",", row.names = F, col.names = F)

# ============================================================================ #
#### Figure S3B: ####

## Use all sonication conditions:
plotData <- modData

yLimRT <- c(0.45, 0.9)
isSave <- F

custom_barplot1(plotData, yVar = "RT_n", xVar = "sonication_f", 
                yLim = yLimRT,
                isPoint = T, isConnect = T, savePNG = isSave, savePDF = isSave)

## Aggregate:
plotData$y <- plotData$RT_n
plotData$x <- plotData$sonication_f
plotData$subject <- plotData$subject_f
aggrData_long <- ddply(plotData, .(subject, x), function(x){
  y <- mean(x$y, na.rm = T)
  return(data.frame(y))
  dev.off()})
aggrData_wide <- reshape(aggrData_long, direction = "wide",
                            idvar = "subject", v.names = "y", timevar = "x")
## Save:
write.table(aggrData_wide[, 2:4], file.path(dirs$source, "FigS3B.csv"), sep = ",", row.names = F, col.names = F)

# ============================================================================ #
#### Figure S3C: ####

## Use all sonication conditions:
plotData <- modData

yLimRT <- c(0.6, 0.8)
isSave <- F

custom_barplot3(plotData, yVar = "RT_n", xVar = "valence_f", zVar = "sonication_f", splitVar = "reqAction_f", 
                isPoint = F, addLegend = F, yLim = yLimRT,
                savePNG = isSave, savePDF = isSave)

## Aggregate:
plotData$y <- plotData$RT_n
plotData$x <- plotData$reqAction_f
plotData$z <- plotData$valence_f
plotData$split <- plotData$sonication_f
plotData$subject <- plotData$subject_f
aggrData_long <- ddply(plotData, .(subject, x, z, split), function(x){
  y <- mean(x$y, na.rm = T)
  return(data.frame(y))
  dev.off()})
aggrData_long$condition <- paste0(aggrData_long$x, "2", aggrData_long$z, "2", aggrData_long$split)
aggrData_long[, c("x", "z", "split")] <- list(NULL)
aggrData_wide <- reshape(aggrData_long, direction = "wide",
                         idvar = "subject", v.names = "y", timevar = c("condition"))
## Save:
write.table(aggrData_wide[, 2:9], file.path(dirs$source, "FigS3C.csv"), sep = ",", row.names = F, col.names = F)

# END OF FILE.