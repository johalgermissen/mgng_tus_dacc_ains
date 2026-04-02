#!/usr/bin/env Rscript
# ============================================================================ #
## 04_mgngtus_params.R
## MGNG-TUS study: Load in fitted parameter values, perform RM-ANOVAs and t-tests, compute correlation with simulated pressure.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

rm(list = ls())

# ============================================================================ #
#### Set directories, load packages and custom functions: ####

## Set codeDir:
codeDir    <- dirname(dirname(rstudioapi::getSourceEditorContext()$path))
helperDir <- file.path(codeDir, "regression", "helpers")
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
# ============================================================================ #
# ============================================================================ #
#### 00) Read in model parameters: ####

# ----------------------------------- #
## Read in behavioral data:

## Select model ID:
modID <- 7 # Winning model is M7

## Select type of parameters to load:
fitType <- "hbi"

## Parameter names:
modString <- str_pad(modID, width = 2, side = "left", pad = "0")

## Sham:
region <- "sham"; fileName <- paste0("cbm_", fitType, "_M", modString, "_", region, "_subject_parameters.csv"); cat(paste0("Load model ", fileName, " ...\n"))
data1 <- read.csv(file.path(dirs$paramDir, fileName))
data1$subject_n <- 1:nrow(data1)
data1$sonication_n <- 1
## dACC:
region <- "dACC"; fileName <- paste0("cbm_", fitType, "_M", modString, "_", region, "_subject_parameters.csv")
data2 <- read.csv(file.path(dirs$paramDir, fileName))
data2$subject_n <- 1:nrow(data1)
data2$sonication_n <- 2
## aIns:
region <- "aIns"; fileName <- paste0("cbm_", fitType, "_M", modString, "_", region, "_subject_parameters.csv")
data3 <- read.csv(file.path(dirs$paramDir, fileName))
data3$subject_n <- 1:nrow(data1)
data3$sonication_n <-3

## Concatenate:
data <- rbind(data1, data2, data3)
data$sonication_f <- factor(data$sonication_n, levels = c(1, 2, 3), labels = c("sham", "dACC", "aIns"))
data$subject_f <- factor(data$subject_n)

# --------------------------------------------- #
## Add subject ID:
mappingData <- data.frame(
  subject_n = 1:29,
  subID = c("SHIA0010", "FNMA0105", "JAKA0154", "AAAA0432", "LECA0624", "MLGA1440", "SINB0180", "SNRB0400", "TABE0063", "JYDF0098", 
            "SSCF0384", "MRMH0014", "MRWI0030", "TRWL0072", "GAEL0180", "DIVL0216", "LIML0315", "BNVN0020", "RBDN0216", "SSTO0540", 
            "KTGO2025", "GNPR0120", "DNHR0900", "ZHHS0560", "KLWT0036", "QMDU0210", "SMLV0104", "SSHW0093", "SKKY0189")
)
data <- merge(data, mappingData, by = "subject_n")

## Add demographics:
data <- add_demographics(data)

## Add session order:
data <- add_session_order(data)

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

# --------------------------------------------------------- #
## Formula: only effect of sonication condition:

formula <- "rho ~ sonication_f + (1|subject_f)"
formula <- "epsilon ~ sonication_f + (1|subject_f)"
formula <- "b ~ sonication_f + (1|subject_f)"
formula <- "pi ~ sonication_f + (1|subject_f)"
formula <- "kappa ~ sonication_f + (1|subject_f)"
formula <- "phi_Int ~ sonication_f + (1|subject_f)"
formula <- "phi_Dif ~ sonication_f + (1|subject_f)"

# --------------------------------------------------------- #
## Formula: Control for other parameters b and phi_Int:

formula <- "kappa ~ sonication_f + b_z + (1|subject_f)"
formula <- "kappa ~ sonication_f + phi_Int_z + (1|subject_f)"
formula <- "kappa ~ sonication_f + b_z + phi_Int_z + (1|subject_f)"
formula <- "kappa_z ~ sonication_f + b_z + phi_Int_z + (1|subject_f)" # for standardised coefficients

formula <- "phi_Dif ~ sonication_f + b_z + (1|subject_f)"
formula <- "phi_Dif ~ sonication_f + phi_Int_z + (1|subject_f)"
formula <- "phi_Dif ~ sonication_f + b_z + phi_Int_z + (1|subject_f)"
formula <- "phi_Dif_z ~ sonication_f + b_z + phi_Int_z + (1|subject_f)" # for standardised coefficients

# --------------------------------------------------------- #
## Formula: Age and gender main effects:

formula <- "rho ~ age_z + gender_f + (1|subject_f)"
formula <- "epsilon ~ age_z + gender_f + (1|subject_f)"
formula <- "b ~ age_z + gender_f + (1|subject_f)"
formula <- "pi ~ age_z + gender_f + (1|subject_f)"
formula <- "kappa ~ age_z + gender_f + (1|subject_f)"
formula <- "phi_Int ~ age_z + gender_f + (1|subject_f)"
formula <- "phi_Dif ~ age_z + gender_f + (1|subject_f)"

# --------------------------------------------------------- #
## Formula: Age and gender interaction with sonication_f:

formula <- "rho ~ sonication_f * age_z + sonication_f * gender_f + (1|subject_f)"
formula <- "epsilon ~ sonication_f * age_z + sonication_f * gender_f + (1|subject_f)"
formula <- "b ~ sonication_f * age_z + sonication_f * gender_f + (1|subject_f)"
formula <- "pi ~ sonication_f * age_z + sonication_f * gender_f + (1|subject_f)"
formula <- "kappa ~ sonication_f * age_z + sonication_f * gender_f + (1|subject_f)"
formula <- "phi_Int ~ sonication_f * age_z + sonication_f * gender_f + (1|subject_f)"
formula <- "phi_Dif ~ sonication_f * age_z + sonication_f * gender_f + (1|subject_f)"

# --------------------------------------------------------- #
## Session ID main effect:

formula <- "rho ~ session_f + (1|subject_f)"
formula <- "epsilon ~ session_f + (1|subject_f)"
formula <- "b ~ session_f + (1|subject_f)"
formula <- "pi ~ session_f + (1|subject_f)"
formula <- "kappa ~ session_f + (1|subject_f)"
formula <- "phi_Int ~ session_f + (1|subject_f)"
formula <- "phi_Dif ~ session_f + (1|subject_f)"

# --------------------------------------------------------- #
## Formula: Session order main effect:

formula <- "rho ~ sonOrder_f + (1|subject_f)"
formula <- "epsilon ~ sonOrder_f + (1|subject_f)"
formula <- "b ~ sonOrder_f + (1|subject_f)"
formula <- "pi ~ sonOrder_f + (1|subject_f)"
formula <- "kappa ~ sonOrder_f + (1|subject_f)"
formula <- "phi_Int ~ sonOrder_f + (1|subject_f)"
formula <- "phi_Dif ~ sonOrder_f + (1|subject_f)"

# --------------------------------------------------------- #
## Formula: Session order interaction with sonication:

formula <- "rho ~ sonication_f * sonOrder_f + (1|subject_f)"
formula <- "epsilon ~ sonication_f * sonOrder_f + (1|subject_f)"
formula <- "b ~ sonication_f * sonOrder_f + (1|subject_f)"
formula <- "pi ~ sonication_f * sonOrder_f + (1|subject_f)"
formula <- "kappa ~ sonication_f * sonOrder_f + (1|subject_f)"
formula <- "phi_Int ~ sonication_f * sonOrder_f + (1|subject_f)"
formula <- "phi_Dif ~ sonication_f * sonOrder_f + (1|subject_f)"

# --------------------------------------------------------- #
## Fit:

mod <- lmer(formula = formula, data = modData,
             control = lmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
summary(mod)
quickCI(mod)
Anova(mod, type = "3")

plot(effect("sonication_f", mod), multiline = T, lwd = 4)

plot(effect("age_z", mod), multiline = T, lwd = 4)
plot(effect("gender_f", mod), multiline = T, lwd = 4)
plot(effect("session_f", mod), multiline = T, lwd = 4)
plot(effect("sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("sonication_f:sonOrder_f", mod), multiline = T, lwd = 4)

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
diffVec <- data_wide$rho.sham - data_wide$rho.dACC; mean(diffVec)/sd(diffVec)
diffVec <- data_wide$rho.sham - data_wide$rho.aIns; mean(diffVec)/sd(diffVec)

diffVec <- data_wide$epsilon.sham - data_wide$epsilon.dACC; mean(diffVec)/sd(diffVec)
diffVec <- data_wide$epsilon.sham - data_wide$epsilon.aIns; mean(diffVec)/sd(diffVec)

diffVec <- data_wide$b.sham - data_wide$b.dACC; mean(diffVec)/sd(diffVec)
diffVec <- data_wide$b.sham - data_wide$b.aIns; mean(diffVec)/sd(diffVec)

diffVec <- data_wide$pi.sham - data_wide$pi.dACC; mean(diffVec)/sd(diffVec)
diffVec <- data_wide$pi.sham - data_wide$pi.aIns; mean(diffVec)/sd(diffVec)

diffVec <- data_wide$kappa.sham - data_wide$kappa.dACC; mean(diffVec)/sd(diffVec)
diffVec <- data_wide$kappa.sham - data_wide$kappa.aIns; mean(diffVec)/sd(diffVec)

diffVec <- data_wide$phi_Int.sham - data_wide$phi_Int.dACC; mean(diffVec)/sd(diffVec)
diffVec <- data_wide$phi_Int.sham - data_wide$phi_Int.aIns; mean(diffVec)/sd(diffVec)

diffVec <- data_wide$phi_Dif.sham - data_wide$phi_Dif.dACC; mean(diffVec)/sd(diffVec)
diffVec <- data_wide$phi_Dif.sham - data_wide$phi_Dif.aIns; mean(diffVec)/sd(diffVec)

## Compute Cohen's d and Hedges' g with robust 95%-CIs:
compute_cohensD_bootCIs(diffVec)

# ============================================================================ #
#### 06) Correlation with pressure/ISPPA: ####

## Select data:
paramNames <- c("rho", "epsilon", "b", "pi", "kappa", "phi_Int", "phi_Dif")
nParam <- length(paramNames)
data_long <- data[, c("subID", "sonication_f", paramNames)]

## Plot intercorrelations between parameters:
M <- cor(data_long[, paramNames])
corrplot::corrplot(M, addCoef.col = 'black', col = rev(COL2('RdBu')), tl.col = "black", tl.pos = "lt")

## Bring sonication condition in wide format:
data_wide <- reshape(data_long, direction = "wide", 
                     idvar = "subID", v.names = paramNames, timevar = "sonication_f")

## Compute condition differences:
for (iParam in 1:nParam){
  selParamName <- paramNames[iParam]
  data_wide[, paste0(selParamName, "_dACC-sham")] <- data_wide[, paste0(selParamName, ".dACC")] - data_wide[, paste0(selParamName, ".sham")]
  data_wide[, paste0(selParamName, "_aIns-sham")] <- data_wide[, paste0(selParamName, ".aIns")] - data_wide[, paste0(selParamName, ".sham")]
}
data_wide <- data_wide[, c(1, grep("-sham", names(data_wide), fixed = TRUE))] # select difference variables only

# --------------------------------------------------------- #
### Load and add simulations:

simFile <- "post_hoc_simulations.xlsx"
simData_long <- as.data.frame(read_excel(file.path(dirs$simulationsDir, simFile)))
simData_long <- simData_long[, c("ID", "Target", "Peak.value.in.Sphere_isppa", "Peak.value.in.Sphere_pressure")] # select data
names(simData_long) <- c("subID", "target_f", "intensity_n", "pressure_n")
simData_long$subID <- gsub("sub-", "", simData_long$subID) # remove subject indices
simData_long$subID <- toupper(simData_long$subID) # capitalize all letters
simData_long$target_f <- factor(simData_long$target_f) # to factor
simData_long$pressure_n <- simData_long$pressure / 1000 # convert from Pa to kPa

## Reshape into wide format:
simData_wide <- reshape(simData_long, direction = "wide", 
                        idvar = "subID", v.names = c("intensity_n", "pressure_n"), timevar = "target_f")

## Add mean of aIns dose:
simData_wide$pressure_n.aIns <- (simData_wide$`pressure_n.l-aIns` + simData_wide$`pressure_n.r-aIns`)/2
simData_wide$intensity_n.aIns <- (simData_wide$`intensity_n.l-aIns` + simData_wide$`intensity_n.r-aIns`)/2

# --------------------------------------------------------- #
### Merge parameter and simulation data:

stopifnot(all(unique(simData_long$subID) == unique(data_wide$subID)))
data_wide <- merge(data_wide, simData_wide, by = "subID")

# --------------------------------------------------------- #
### Select region (for parameter difference) and dose:

## Select region:
region <- "dACC"; iDose <- 1
region <- "aIns"; iDose <- 3

## Select parameter differences in variables for selected region:
paramVars <- names(data_wide)[grepl(paste0("_", region, "-sham"), names(data_wide), fixed = TRUE)]; paramVars

## Select all pressure/intensity variables:
# doseVars <- names(data_wide)[grepl("pressure_n", names(data_wide), fixed = TRUE)]; doseVars; doseName <- "Pressure (kPa)" # all pressure
# doseVars <- names(data_wide)[grepl("intensity_n", names(data_wide), fixed = TRUE)]; doseVars; doseName <- "ISPPA (W/cm^2)" # all intensities

## Select pressure/intensity variables for selected region:
doseVars <- names(data_wide)[grepl("pressure_n", names(data_wide), fixed = TRUE) & grepl(region, names(data_wide), fixed = TRUE)]; doseVars; doseName <- "Pressure (kPa)"
# doseVars <- names(data_wide)[grepl("intensity_n", names(data_wide), fixed = TRUE) & grepl(region, names(data_wide), fixed = TRUE)]; doseVars; doseName <- "ISPPA (W/cm^2)"

# --------------------------------------------------------- #
### Heat map of correlations of parameter differences:

# M <- cor(data_wide[, paramVars], data_wide[, paramVars]) # Pearson parameters with themselves
M <- cor(data_wide[, doseVars], data_wide[, paramVars], method = "pearson") # Pearson correlation parameters with dose
# M <- cor(data_wide[, doseVars], data_wide[, paramVars], method = "spearman") # Spearman's rho correlation parameters with dose
# M <- cor(data_wide[, doseVars], data_wide[, paramVars], method = "kendall") # Kendall's tau correlation parameters with dose

if (nrow(M) == 1){rownames(M) <- doseVars} # add dose label
corrplot::corrplot(M, addCoef.col = 'black', col = rev(COL2('RdBu')), tl.col = "black", tl.pos = "lt")

# --------------------------------------------------------- #
### Scatterplot with regression line:

## Select parameter:
paramNames
iParam <- 3 # b
iParam <- 5 # kappa
iParam <- 6 # phi_Int
iParam <- 7 # phi_Dif

## Select dose, compose axis labels:
xVar <- doseVars[iDose]; xLab <- paste0(doseName, " in ", region); yVar <- paste0(paramNames[iParam], "_", region, "-sham"); yLab <- paste0(paramNames[iParam], ", ", region, " - sham"); xVar; yVar

## Plot:
p <- plot_correlation(data = data_wide, xVar = xVar, yVar = yVar, xLab = xLab, yLab = yLab,
                      isSubLabel = F, subVar = "SubID",
                      savePNG = F, saveSVG = T)

# END OF FILE.