#!/usr/bin/env Rscript
# ============================================================================ #
## 04_mgngtus_params.R
## MGNG-TUS study: Load in fitted parameter values, perform RM-ANOVAs and t-tests.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

rm(list = ls())

# ============================================================================ #
#### Set directories, load packages and custom functions: ####

## Set codeDir:
codeDir    <- dirname(rstudioapi::getSourceEditorContext()$path)
helperDir <- paste0(codeDir, "/helpers/")

## Load directories:
source(paste0(helperDir, "set_dirs.R")) # Load packages and options settings
rootDir <- paste0(dirname(codeDir), "/")
dirs <- set_dirs(rootDir)

## Load packages:
source(paste0(helperDir, "package_manager.R")) # Load packages and options settings

# ------------------------------------------------- #
## Load custom functions:

source(paste0(codeDir, "/functions/00_mgngtus_functions_regression.R")) # Load functions

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 00) Read in model parameters: ####

dirs$params <- paste0(dirs$root, "results/cbm/parameters/")

# ----------------------------------- #
## Read in behavioral data:

## Flexible settings:

modID <- 20

# fitType <- "lap"
fitType <- "hbi"

## Parameter names:
modString <- str_pad(modID, width = 2, side = "left", pad = "0")

## Sham:
region <- "sham"; fileName <- paste0("cbm_", fitType, "_M", modString, "_", region, "_subject_parameters.csv"); cat(paste0("Load model ", fileName, " ...\n"))
data1 <- read.csv(paste0(dirs$params, fileName))
data1$subject_n <- 1:nrow(data1)
data1$sonication_n <- 1
## dACC:
region <- "dACC"; fileName <- paste0("cbm_", fitType, "_M", modString, "_", region, "_subject_parameters.csv")
data2 <- read.csv(paste0(dirs$params, fileName))
data2$subject_n <- 1:nrow(data1)
data2$sonication_n <- 2
## aIns:
region <- "aIns"; fileName <- paste0("cbm_", fitType, "_M", modString, "_", region, "_subject_parameters.csv")
data3 <- read.csv(paste0(dirs$params, fileName))
data3$subject_n <- 1:nrow(data1)
data3$sonication_n <-3

## Concatenate:
data <- rbind(data1, data2, data3)
data$sonication_f <- factor(data$sonication_n, levels = c(1, 2, 3), labels = c("sham", "dACC", "aIns"))
# data$sonication_short_f <- data$sonication_f
data$subject_f <- factor(data$subject_n)

# ============================================================================ #
#### 01) Plot bar plots: ####

isSave <- F

plotData <- data

custom_barplot1(plotData, yVar = "rho", xVar = "sonication_f", yLim = c(0, 50), savePNG = isSave)
custom_barplot1(plotData, yVar = "epsilon", xVar = "sonication_f", yLim = c(0, 0.6), savePNG = isSave)
custom_barplot1(plotData, yVar = "b", xVar = "sonication_f", yLim = c(-0.5, 1.2), savePNG = isSave)
custom_barplot1(plotData, yVar = "pi", xVar = "sonication_f", yLim = c(-1.5, 5), savePNG = isSave)
custom_barplot1(plotData, yVar = "kappa", xVar = "sonication_f", savePNG = isSave)
custom_barplot1(plotData, yVar = "phi_Int", xVar = "sonication_f", savePNG = isSave)
custom_barplot1(plotData, yVar = "phi_Dif", xVar = "sonication_f", yLim = c(-0.5, 3), savePNG = isSave)

# ============================================================================ #
#### 02) RM-ANOVA: ####

modData <- data

names(modData)

# tmp <- custom_RMANOVA(modData, "kappa", "subject_f", "sonication_f")
# tmp <- custom_RMANOVA(modData, "phi_Dif", "subject_f", "sonication_f")

ezANOVA(data = data, dv = rho, within = .(sonication_f), wid = subject_f, 
        type = 3, detailed = TRUE)$ANOVA
ezANOVA(data = data, dv = epsilon, within = .(sonication_f), wid = subject_f, 
        type = 3, detailed = TRUE)$ANOVA
ezANOVA(data = data, dv = b, within = .(sonication_f), wid = subject_f, 
        type = 3, detailed = TRUE)$ANOVA
ezANOVA(data = data, dv = kappa, within = .(sonication_f), wid = subject_f, 
        type = 3, detailed = TRUE)$ANOVA
ezANOVA(data = data, dv = phi_Int, within = .(sonication_f), wid = subject_f, 
        type = 3, detailed = TRUE)$ANOVA
ezANOVA(data = data, dv = phi_Dif, within = .(sonication_f), wid = subject_f, 
        type = 3, detailed = TRUE)$ANOVA

# ============================================================================ #
#### 03) Mixed-effects linear regression: ####

modData <- data

names(modData)

## Formula:
formula <- "rho ~ sonication_f + (1|subject_f)"
formula <- "epsilon ~ sonication_f + (1|subject_f)"
formula <- "b ~ sonication_f + (1|subject_f)"
formula <- "pi ~ sonication_f + (1|subject_f)"
formula <- "kappa ~ sonication_f + (1|subject_f)"
formula <- "phi_Int ~ sonication_f + (1|subject_f)"
formula <- "phi_Dif ~ sonication_f + (1|subject_f)"

## Fit:
mod <- lmer(formula = formula, data = modData,
             control = lmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
summary(mod); beep()
Anova(mod, type = "3")
quickCI(mod)

plot(effect("sonication_f", mod), multiline = T, lwd = 4)

## P-values with LRTs:
mod_LRT <- mixed(mod, modData, method = "LRT", type = "III", # all_fit = T, # all_fit needed for 8 subjects
                 control = lmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
anova(mod_LRT); beep()

# ============================================================================ #
#### 04) Long format, paired t-tests: ####

selData <- droplevels(subset(data, sonication_f %in% c("sham", "dACC")))
selData <- droplevels(subset(data, sonication_f %in% c("sham", "aIns")))
table(selData$sonication_f)

## Paired t-tests:
t.test(rho ~ sonication_f, data = selData, paired = T)
t.test(epsilon ~ sonication_f, data = selData, paired = T)
t.test(b ~ sonication_f, data = selData, paired = T)
t.test(pi ~ sonication_f, data = selData, paired = T)
t.test(kappa ~ sonication_f, data = selData, paired = T)
t.test(phi_Int ~ sonication_f, data = selData, paired = T)
t.test(phi_Dif ~ sonication_f, data = selData, paired = T)

## Paired t-tests:
library(effsize)
cohen.d(selData$rho, selData$sonication_f, paired = T, within = T, subject = selData$subject_f)
cohen.d(selData$epsilon, selData$sonication_f, paired = T, within = T, subject = selData$subject_f)
cohen.d(selData$b, selData$sonication_f, paired = T, within = T, subject = selData$subject_f)
cohen.d(selData$kappa, selData$sonication_f, paired = T, within = T, subject = selData$subject_f)
cohen.d(selData$phi_Int, selData$sonication_f, paired = T, within = T, subject = selData$subject_f)
cohen.d(selData$phi_Dif, selData$sonication_f, paired = T, within = T, subject = selData$subject_f)

# ============================================================================ #
#### 05) Cast into wide format, paired t-tests: ####

## Identify parameter names:
paramNames <- names(data)[!(names(data) %in% c("subject_n", "subject_f", "sonication_n", "sonication_f"))]; paramNames

## Cast into wide-format:
data_long <- data[, c("subject_n", "sonication_f", paramNames)]
data_wide <- reshape(data_long, direction = "wide", idvar = "subject_n", v.names = paramNames, timevar = "sonication_f") # into wide format
head(data_wide)

## Paired t-tests:
t.test(data_wide$rho.sham - data_wide$rho.dACC, data = data_wide)
t.test(data_wide$rho.sham - data_wide$rho.aIns, data = data_wide)

t.test(data_wide$epsilon.sham - data_wide$epsilon.dACC, data = data_wide)
t.test(data_wide$epsilon.sham - data_wide$epsilon.aIns, data = data_wide)

t.test(data_wide$b.sham - data_wide$b.dACC, data = data_wide)
t.test(data_wide$b.sham - data_wide$b.aIns, data = data_wide)

t.test(data_wide$pi.sham - data_wide$pi.dACC, data = data_wide)
t.test(data_wide$pi.sham - data_wide$pi.aIns, data = data_wide)

t.test(data_wide$kappa.sham - data_wide$kappa.dACC, data = data_wide)
t.test(data_wide$kappa.sham - data_wide$kappa.aIns, data = data_wide)

t.test(data_wide$phi_Int.sham - data_wide$phi_Int.dACC, data = data_wide)
t.test(data_wide$phi_Int.sham - data_wide$phi_Int.aIns, data = data_wide)

t.test(data_wide$phi_Dif.sham - data_wide$phi_Dif.dACC, data = data_wide)
t.test(data_wide$phi_Dif.sham - data_wide$phi_Dif.aIns, data = data_wide)

## Cohen's d:
difVec <- data_wide$rho.sham - data_wide$rho.dACC; mean(difVec)/sd(difVec)
difVec <- data_wide$rho.sham - data_wide$rho.aIns; mean(difVec)/sd(difVec)

difVec <- data_wide$epsilon.sham - data_wide$epsilon.dACC; mean(difVec)/sd(difVec)
difVec <- data_wide$epsilon.sham - data_wide$epsilon.aIns; mean(difVec)/sd(difVec)

difVec <- data_wide$b.sham - data_wide$b.dACC; mean(difVec)/sd(difVec)
difVec <- data_wide$b.sham - data_wide$b.aIns; mean(difVec)/sd(difVec)

difVec <- data_wide$pi.sham - data_wide$pi.dACC; mean(difVec)/sd(difVec)
difVec <- data_wide$pi.sham - data_wide$pi.aIns; mean(difVec)/sd(difVec)

difVec <- data_wide$kappa.sham - data_wide$kappa.dACC; mean(difVec)/sd(difVec)
difVec <- data_wide$kappa.sham - data_wide$kappa.aIns; mean(difVec)/sd(difVec)

difVec <- data_wide$phi_Int.sham - data_wide$phi_Int.dACC; mean(difVec)/sd(difVec)
difVec <- data_wide$phi_Int.sham - data_wide$phi_Int.aIns; mean(difVec)/sd(difVec)

difVec <- data_wide$phi_Dif.sham - data_wide$phi_Dif.dACC; mean(difVec)/sd(difVec)
difVec <- data_wide$phi_Dif.sham - data_wide$phi_Dif.aIns; mean(difVec)/sd(difVec)

# END OF FILE.