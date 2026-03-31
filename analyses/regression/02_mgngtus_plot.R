#!/usr/bin/env Rscript
# ============================================================================ #
## 02_mgngtus_plot.R
## MGNG-TUS study: plot behaviour (responses, repetitions, RTs) as bar and line plots.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

rm(list = ls())

# ============================================================================ #
#### Set directories, load packages and custom functions: ####

## Set codeDir:
currDir    <- dirname(rstudioapi::getSourceEditorContext()$path)
helperDir <- file.path(currDir, "helpers")
source(file.path(helperDir, "set_dirs.R")) # Load packages and options settings

## Load directories:
rootDir <- dirname(dirname(currDir))
dirs <- set_dirs(rootDir)

## Load packages:
source(file.path(dirs$helperDir, "package_manager.R")) # Load packages and options settings

# ------------------------------------------------- #
## Load custom functions:

source(file.path(dirs$funcDir, "00_mgngtus_functions_regression.R")) # Load functions

# ============================================================================ #
#### 01a) Read in behavioral data: ####

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
#### 01b) Exclude subjects with incomplete sessions or outlier behaviour: ####

length(unique(data$subID))
table(data$subID, data$sonication_f)
incompleteSubs <- c("JIJS1080", "KYJF0110", "MRMO0104", "NACA0882")
outlierSubs <- c("EEMR0429")
excludeSubs <- sort(unique(c(incompleteSubs, outlierSubs)))
data <- subset(data, !(subID %in% excludeSubs))
table(data$subID, data$sonication_f)
length(unique(data$subID))

# ============================================================================ #
#### 01c) Exclude excessive cue repetitions: ####

data <- subset(data, cueRep_n %in% 1:20)

# ============================================================================ #
#### 01d) Inspect cell sizes: ####

### Subjects:
length(unique(data$subject_n))
table(data$subject_n)
# --> unequal numbers because not all sessions finished

### Sonication sessions:
table(data$sonication_f)
table(data$subID, data$sonication_f)
# --> several subjects with empty sessions

### Cue counts:
table(data$cue_n)
table(data$subID, data$cue_n)
# --> most cues 60 times (3 session x 20 cue repetitions)
# --> but some cues less/more often...?!?

## Cue repetitions:
table(data$cueRep_n)
table(data$subID, data$cueRep_n)
# --> most cue position 48 times (3 session x 16 cues)
# --> but some cue repetitions less often, sometimes cue repetitions 21-23...?!?

## Outcomes:
sum(is.na(data$outcome_n)) # 300 x NA
table(data[is.na(data$outcome_n), "subID"])
# JAKA0154 SINB0180 SKKY0189 SSHW0093 
#       60       60      120       60 
table(data[is.na(data$outcome_n), "subID"], data[is.na(data$outcome_n), "sonication_f"])
# JAKA0154    0   60    0
# SINB0180    0    0   60
# SKKY0189    0   60   60
# SSHW0093    0   60    0
## --> checked in raw data: verum NaN; always at the end of session
data[is.na(data$outcome_n), c("subID", "sonication_f", "trialnr_n", "cue_n", "cueRep_n", "reqAction_n", "valence_n", "response_n", "ACC_n", "RT_n", "validity_n", "outcome_n")]

## Check validity:
round(tapply(data$validity_n, data$subID, mean, na.rm = T), 4) # 0.8125

# ============================================================================ #
#### 01e) Select data, standardize variables: ####

modData <- select_standardize(data)

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 02a) Plot individual subjects: ####

# -------------------------------------------- #
### Loop over all subjects:

## Map subjects:
subVec <- unique(data$subID)
nSub <- length(subVec)

for (iSub in 1:nSub){
  selSubID <- subVec[iSub]
  subData <- subset(data, subID == selSubID)
  custom_barplot2(subData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", savePNG = F, main = selSubID)
  readline(prompt = "Press [enter] to continue")  
}
## EEMR0429

# -------------------------------------------- #
### Plot single selected subject:

selSubID <- "EEMR0429"
selSubID <- "JAKA0154"
selSubID <- "LECA0624"
selSubID <- "SINB0180"
selSubID <- "SSTO0540"
selSubID <- "TRWL0072"

subData <- subset(data, subID == selSubID)
custom_barplot2(subData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", savePNG = F, main = selSubID)

# ============================================================================ #
#### 02b) Plot individual subjects, individual sessions: ####

# -------------------------------------------- #
### Loop over all subjects:

## Map subjects:
subVec <- unique(data$subID)
nSub <- length(subVec)

## Select session:
session <- "sham"
session <- "dACC"
session <- "aIns"

for (iSub in 1:nSub){
  selSubID <- subVec[iSub]
  subData <- subset(data, subID == selSubID & sonication_f == session)
  custom_barplot2(subData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", savePNG = F, main = paste0(selSubID, ", ", session))
  readline(prompt="Press [enter] to continue")  
}
## EEMR0429

# -------------------------------------------- #
## Plot selected subject, selected session:

selSubID <- "EEMR0429"
selSubID <- "JAKA0154"
selSubID <- "LECA0624"
selSubID <- "SINB0180"
selSubID <- "SSTO0540"
selSubID <- "TRWL0072"

session <- "sham"
subData <- subset(data, subID == selSubID & sonication_f == session)
custom_barplot2(subData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", savePNG = F, main = paste0(selSubID, ", ", session))
session <- "dACC"
subData <- subset(data, subID == selSubID & sonication_f == session)
custom_barplot2(subData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", savePNG = F, main = paste0(selSubID, ", ", session))
session <- "aIns"
subData <- subset(data, subID == selSubID & sonication_f == session)
custom_barplot2(subData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", savePNG = F, main = paste0(selSubID, ", ", session))

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 03a) Descriptive statistics responses: ####

tmp <- tapply(data$response_n, data$subID, mean, na.rm = T)
round(tmp, 2)
round(t(stat.desc(tmp)), 2)

plotData <- data.frame(subID = unique(data$subID),
                       response_n = tmp)

custom_singlebar(data = plotData, yVar = "response_n", yLim = c(0, 1), isViolin = FALSE, hLine = NULL,
                 selCol = "grey80", xLab = "", yLab = NULL, main = NULL)

# ============================================================================ #
#### 03b) Descriptive statistics repeat: ####

tmp <- tapply(data$repeat_n, data$subID, mean, na.rm = T)
round(tmp, 2)
round(t(stat.desc(tmp)), 2)

plotData <- data.frame(subID = unique(data$subID),
                       repeat_n = tmp)

custom_singlebar(data = plotData, yVar = "repeat_n", yLim = c(0, 1), isViolin = FALSE, hLine = NULL,
                 selCol = "grey80", xLab = "", yLab = NULL, main = NULL)

# ============================================================================ #
#### 03c) Density RTs: ####

## Select data:
plotData <- data

## RTs:
densityplot(plotData$RT_n)

nrow(plotData)
sum(plotData$RT_n < 0.1, na.rm = T)
sum(plotData$RT_n < 0.2, na.rm = T)
sum(plotData$RT_n < 0.3, na.rm = T)
sum(plotData$RT_n < 0.4, na.rm = T)
sum(plotData$RT_n < 0.5, na.rm = T)

round(t(stat.desc(data$RT_n)), 3)
p <- customplot_density2(plotData, xVar = "RT_n", zVar = "reqAction_f") 
p <- customplot_density2(plotData, xVar = "RT_n", zVar = "valence_f") 

p <- customplot_density2(plotData, xVar = "RT_n", zVar = "reqAction_f", addLegend = T) 
p <- customplot_density2(plotData, xVar = "RT_n", zVar = "valence_f", addLegend = T) 

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 04a) Learning curves: ####

plotData <- data # select data
table(plotData$sonication_f)
length(unique(plotData$subID))

custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "response_n", zVar = "condition_f", subVar = "subject_f", 
                   selLineType = c(1, 1, 2, 2), breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = T)

custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "ACC_n", zVar = "condition_f", subVar = "subject_f", 
                   selLineType = c(1, 1, 2, 2), breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = T)

yLimRT <- c(0.50, 0.90)
custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "RT_n", zVar = "condition_f", subVar = "subject_f", 
                   selLineType = c(1, 1, 2, 2), breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = T, yLim = yLimRT)

# ---------------------------------------------------------------------------- #
#### 04b) Learning curves separately per CONDITION, compare sonication conditions: ####

## Select condition:
selCond <- "G2W"
selCond <- "G2A"
selCond <- "NG2W"
selCond <- "NG2A"

## Select data:
selData <- droplevels(subset(plotData, condition_f == selCond))
table(selData$condition_f)
table(selData$sonication_f)

## Plot:
custom_lineplot_gg(selData, xVar = "cueRep_n", yVar = "response_n", zVar = "sonication_f", subVar = "subject_f", 
                   # selLineType = c(2, 2, 2), 
                   breakVec = c(1, 5, 10, 15, 20), main = selCond, addLegend = F, savePNG = isSave)

custom_lineplot_gg(selData, xVar = "cueRep_n", yVar = "ACC_n", zVar = "sonication_f", subVar = "subject_f", 
                   # selLineType = c(2, 2, 2), 
                   breakVec = c(1, 5, 10, 15, 20), main = selCond, addLegend = F, savePNG = isSave)

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 05a) Bias (effect of cue valence x required actions) in responses, ACC, RTs: ####

plotData <- data
length(unique(plotData$subID))
table(plotData$subID)
table(plotData$sonication_f)

## Responses:
custom_barplot2(plotData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f")
## Accuracy:
custom_barplot2(plotData, yVar = "ACC_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f")
## RTs:
custom_barplot2(plotData, yVar = "RT_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", yLim = c(0.4, 1.2))

# ============================================================================ #
#### 05b) p(repeat) ~ past outcomes x past responses: ####

plotData <- data

isSave <- F
# isSave <- T

## Outcomes: c("#007174", "#f0ae66", "#57c4ad", "#c93d21")
names(plotData)[grep("outcome_last", names(plotData), fixed = T)]

# -------------------------------------------------------- #
### Overall p(repeat) ~ outcome, irrespective of sonication:

custom_barplot1(plotData, yVar = "repeat_n", xVar = "outcome_last_short_f", subVar = "subject_f", savePNG = isSave)
custom_barplot1(plotData, yVar = "repeat_n", xVar = "outcome_last_rel_f", subVar = "subject_f", savePNG = isSave)

tapply(plotData$repeat_n, plotData$outcome_last_all_short_f, mean, na.rm = T)
custom_barplot1(plotData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", subVar = "subject_f", savePNG = isSave)

# -------------------------------------------------------- #
### Outcome x response:

tapply(plotData$repeat_n, interaction(plotData$response_last_short_f, plotData$outcome_last_all_short_f), mean, na.rm = T)
custom_barplot2(plotData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "response_last_short_f", subVar = "subject_f")

tapply(plotData$repeat_n, interaction(plotData$outcome_last_all_short_f, plotData$response_last_short_f), mean, na.rm = T)
custom_barplot2(plotData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_all_short_f", subVar = "subject_f", addLegend = F, savePNG = isSave)

# -------------------------------------------------------- #
## Salient/valenced outcomes only:
selData <- droplevels(subset(plotData, salience_last_f == "salient"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#007174", "#c93d21"), main = "Valenced outcomes", savePNG = isSave)

# -------------------------------------------------------- #
## Neutral outcomes only:
selData <- droplevels(subset(plotData, salience_last_f == "neutral"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#57c4ad", "#f0ae66"), main = "Neutral outcomes", savePNG = isSave)

# -------------------------------------------------------- #
## Win cues only:
selData <- droplevels(subset(plotData, valence_f == "Win"))
unique(selData$valence_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#007174", "#f0ae66"), main = "Win cues only", savePNG = isSave)

# -------------------------------------------------------- #
## Avoid cues only:
selData <- droplevels(subset(plotData, valence_f == "Avoid"))
unique(selData$valence_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#57c4ad", "#c93d21"), main = "Avoid cues only", savePNG = isSave)

# -------------------------------------------------------- #
## p(repeat) curves over time:
custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "repeat_n", zVar = "outcome_last_f", subVar = "subject_f", 
                   breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = isSave)
custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "repeat_n", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                   breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = isSave)
custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "repeat_n", zVar = "outcome_last_all_short_f", subVar = "subject_f", 
                   breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = isSave)

# ============================================================================ #
#### 06) SEPARATE plots per sonication condition: #####

sonCond <- "sham"
sonCond <- "dACC"
sonCond <- "aIns"

## Select data:
plotData <- droplevels(subset(data, sonication_f == sonCond)); mainText <- sonCond
length(unique(plotData$subject_f))
table(plotData$sonication_f)

# isSave <- F
isSave <- T

# ---------------------------------------------------------------------------- #
#### 06a) Learning curves: ####

custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "response_n", zVar = "condition_f", subVar = "subject_f",
                   selLineType = c(1, 1, 2, 2), breakVec = c(1, 5, 10, 15, 20), addLegend = F, 
                   main = mainText, suffix = sonCond,
                   savePNG = F, saveEPS = F, saveSVG = F, savePDF = T)

custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "ACC_n", zVar = "condition_f", subVar = "subject_f",
                   selLineType = c(1, 1, 2, 2), breakVec = c(1, 5, 10, 15, 20), addLegend = F, 
                   main = mainText, suffix = sonCond,
                   savePNG = F, saveEPS = F, saveSVG = F, savePDF = T)

# ---------------------------------------------------------------------------- #
#### 06b) RTs over trials: ####

yLimRT <- c(0.40, 0.90)
custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "RT_n", zVar = "condition_f", subVar = "subject_f", 
                   selLineType = c(1, 1, 2, 2), breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = isSave, yLim = yLimRT, main = mainText)

# ---------------------------------------------------------------------------- #
#### 06c) Bar plots: ####

custom_barplot2(plotData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", 
                main = mainText, suffix = sonCond,
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = T)
custom_barplot2(plotData, yVar = "ACC_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f",
                main = mainText, suffix = sonCond,
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = T)
custom_barplot2(plotData, yVar = "RT_n", xVar = "reqAction_f", zVar = "valence_f", subVar = "subject_f", yLim = c(0.4, 1.2),
                main = mainText, suffix = sonCond,
                savePNG = T, saveEPS = F, saveSVG = F, savePDF = T)

# ---------------------------------------------------------------------------- #
#### 06d) p(repeat): ####

# -------------------------------------------------------- #
## Cue valence:
custom_barplot1(plotData, yVar = "repeat_n", xVar = "valence_f", savePNG = isSave)

# -------------------------------------------------------- #
## Salient/valenced outcomes:
selData <- droplevels(subset(plotData, salience_last_f == "salient"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#007174", "#c93d21"),
                main = mainText, suffix = paste("valenced_", sonCond),
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = T)

# -------------------------------------------------------- #
## Neutral outcomes:
selData <- droplevels(subset(plotData, salience_last_f == "neutral"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#57c4ad", "#f0ae66"),
                main = mainText, suffix = paste("neutral_", sonCond),
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = T)

# -------------------------------------------------------- #
## Win cues:
selData <- droplevels(subset(plotData, valence_f == "Win"))
unique(selData$valence_f)
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#007174", "#f0ae66"),
                main = mainText, suffix = sonCond,
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = F)

# -------------------------------------------------------- #
## Avoid cues:
selData <- droplevels(subset(plotData, valence_f == "Avoid"))
unique(selData$valence_f)
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", subVar = "subject_f", 
                selCol = c("#57c4ad", "#c93d21"),
                main = mainText, suffix = sonCond,
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = F)

# -------------------------------------------------------- #
## p(repeat) per outcome over time:
custom_lineplot_gg(plotData, xVar = "cueRep_n", yVar = "repeat_n", zVar = "outcome_last_all_short_f", subVar = "subject_f", 
                   breakVec = c(1, 5, 10, 15, 20), addLegend = F, savePNG = isSave, main = mainText)

cat("Finished! :-)\n")

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 07) Split into PANELS per SONICATION condition: ####

# ---------------------------------------------------------------------------- #
#### 07a) Responses: ####

plotData <- data
length(unique(data$subID))
table(data$sonication_f)

# -------------------------------------------------------- #
### p(Go) per sonication (no dots):
custom_barplot1(plotData, yVar = "response_n", xVar = "sonication_f")
custom_barplot3(plotData, yVar = "response_n", xVar = "reqAction_f", zVar = "valence_f", splitVar = "sonication_f", isPoint = F, addLegend = F)
custom_barplot3(plotData, yVar = "response_n", xVar = "reqAction_f", zVar = "sonication_f", splitVar = "valence_f", isPoint = F, addLegend = F)
custom_barplot3(plotData, yVar = "response_n", xVar = "valence_f", zVar = "sonication_f", splitVar = "reqAction_f", isPoint = F, addLegend = F)

# ---------------------------------------------------------------------------- #
#### 07b) RTs: ####

plotData <- data
length(unique(data$subID))

### RTs per sonication (no dots):
yLimRT <- c(0.6, 0.8)
yLimRT <- c(0.45, 0.9)
isSave <- F
isSave <- T
custom_barplot1(plotData, yVar = "RT_n", xVar = "sonication_f", 
                # yLim = c(0.6, 0.7),
                yLim = yLimRT,
                isPoint = T, isConnect = T, savePNG = isSave, savePDF = isSave)
custom_barplot3(plotData, yVar = "RT_n", xVar = "reqAction_f", zVar = "valence_f", splitVar = "sonication_f", isPoint = F, addLegend = F, yLim = yLimRT,
                savePNG = isSave, savePDF = isSave)
custom_barplot3(plotData, yVar = "RT_n", xVar = "reqAction_f", zVar = "sonication_f", splitVar = "valence_f", isPoint = F, addLegend = F, yLim = yLimRT,
                savePNG = isSave, savePDF = isSave)
custom_barplot3(plotData, yVar = "RT_n", xVar = "valence_f", zVar = "sonication_f", splitVar = "reqAction_f", isPoint = F, addLegend = F, yLim = yLimRT,
                savePNG = isSave, savePDF = isSave)
## With dots:
custom_barplot1(plotData, yVar = "RT_n", xVar = "sonication_f", yLim = c(0.45, 0.9))

# ---------------------------------------------------------------------------- #
#### 07c) p(repeat): ####

plotData <- data

isSave <- F
# isSave <- T

### p(repeat) per sonication (no dots):
custom_barplot1(plotData, yVar = "repeat_n", xVar = "sonication_f", savePNG = isSave)
custom_barplot2(plotData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", subVar = "subject_f", savePNG = isSave)
custom_barplot2(plotData, yVar = "repeat_n", xVar = "response_last_f", zVar = "sonication_f", subVar = "subject_f", addLegend = F, savePNG = isSave)

custom_barplot2(plotData, yVar = "repeat_n", xVar = "valence_f", zVar = "sonication_f", subVar = "subject_f", addLegend = F, 
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = T)

custom_barplot3(plotData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", splitVar = "response_last_short_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20,
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = F)

# ------------------------------------------------------------- #
### Only rewarded Go vs. punished NoGo:

source(paste0(codeDir, "/functions/00_mgngtus_functions_regression.R")) # Load functions
custom_barplot2(plotData, yVar = "repeat_n", xVar = "outcome_last_response_last_f", zVar = "sonication_f", subVar = "subject_f", 
                # main = "Valenced outcomes", suffix = "valenced",
                savePNG = T, saveEPS = F, saveSVG = F, savePDF = F)

# ------------------------------------------------------------- #
### Salient/valenced outcomes:

selData <- droplevels(subset(plotData, salience_last_f == "salient"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
table(selData$sonication_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", subVar = "subject_f", 
                main = "Valenced outcomes", suffix = "valenced",
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = F)
custom_barplot3(selData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", splitVar = "response_last_short_f", 
                main = "Valenced outcomes", suffix = "valenced",
                isPoint = F, addLegend = F, LWD = 1, FTS = 20,
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = F)

# ------------------------------------------------------------- #
### Rewarded Go vs. punished NoGo:
selData <- droplevels(subset(plotData, (outcome_last_all_f == "rewarded" & response_last_f == "Go") | (outcome_last_all_f == "punished" & response_last_f == "NoGo")))
table(selData$outcome_last_all_f, selData$response_last_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", subVar = "subject_f", 
                main = "Rew. Go vs. pun. NoGo", suffix = "rewgo_punnogo",
                savePNG = T, saveEPS = F, saveSVG = F, savePDF = F)

# ------------------------------------------------------------- #
### Neutral outcomes:
selData <- droplevels(subset(plotData, salience_last_f == "neutral"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
table(selData$sonication_f)
custom_barplot2(selData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", subVar = "subject_f", 
                main = "Neutral outcomes", suffix = "neutral",
                savePNG = T, saveEPS = F, saveSVG = F, savePDF = F)
custom_barplot3(selData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", splitVar = "response_last_short_f", 
                main = "Neutral outcomes", suffix = "neutral",
                isPoint = F, addLegend = F, LWD = 1, FTS = 20,
                savePNG = F, saveEPS = F, saveSVG = F, savePDF = F)

# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #
### Sonication as panels:

## Sonication as panels:
custom_barplot3(plotData, yVar = "repeat_n", xVar = "response_last_short_f", zVar = "outcome_last_all_short_f", splitVar = "sonication_f", isPoint = F, addLegend = F, LWD = 1, FTS = 20, savePNG = isSave)
## Go/NoGo as panels, outcome as colour:
custom_barplot3(plotData, yVar = "repeat_n", xVar = "sonication_f", zVar = "outcome_last_all_short_f", splitVar = "response_last_short_f", isPoint = F, addLegend = F, LWD = 1, FTS = 18, savePNG = isSave)
## Go/NoGo as panels, sonication as colour:
custom_barplot3(plotData, yVar = "repeat_n", xVar = "outcome_last_all_short_f", zVar = "sonication_f", splitVar = "response_last_short_f", isPoint = F, addLegend = F, LWD = 1, FTS = 20, savePNG = isSave)

# ------------------------------------------------------------- #
### Salient/ valenced outcomes:
selData <- droplevels(subset(plotData, salience_last_f == "salient"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
table(selData$sonication_f)
custom_barplot3(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", splitVar = "sonication_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, selCol = c("#007174", "#c93d21"), main = "Valenced outcomes", savePNG = isSave)
custom_barplot3(selData, yVar = "repeat_n", xVar = "outcome_last_rel_f", zVar = "sonication_f", splitVar = "response_last_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, main = "Valenced outcomes", savePNG = isSave)

# ------------------------------------------------------------- #
### Neutral outcomes:
selData <- droplevels(subset(plotData, salience_last_f == "neutral"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
table(selData$sonication_f)
custom_barplot3(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", splitVar = "sonication_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, selCol = c("#57c4ad", "#f0ae66"), main = "Neutral outcomes", savePNG = isSave)
custom_barplot3(selData, yVar = "repeat_n", xVar = "outcome_last_rel_f", zVar = "sonication_f", splitVar = "response_last_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, main = "Neutral outcomes", savePNG = isSave)

# ------------------------------------------------------------- #
### Win cues:
selData <- droplevels(subset(plotData, valence_f == "Win"))
unique(selData$valence_f)
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
table(selData$sonication_f)
custom_barplot3(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", splitVar = "sonication_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, selCol = c("#007174", "#f0ae66"), main = "Win cues", savePNG = isSave)
custom_barplot3(selData, yVar = "repeat_n", xVar = "outcome_last_rel_f", zVar = "sonication_f", splitVar = "response_last_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, main = "Win cues", savePNG = isSave)

# ------------------------------------------------------------- #
### Avoid cues:
selData <- droplevels(subset(plotData, valence_f == "Avoid"))
unique(selData$outcome_last_rel_f)
table(selData$outcome_last_all_f)
table(selData$sonication_f)
custom_barplot3(selData, yVar = "repeat_n", xVar = "response_last_f", zVar = "outcome_last_rel_f", splitVar = "sonication_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, selCol = c("#57c4ad", "#c93d21"), main = "Avoid cues", savePNG = isSave)
custom_barplot3(selData, yVar = "repeat_n", xVar = "outcome_last_rel_f", zVar = "sonication_f", splitVar = "response_last_f", 
                isPoint = F, addLegend = F, LWD = 1, FTS = 20, main = "Avoid cues", savePNG = isSave)

# END OF FILE.