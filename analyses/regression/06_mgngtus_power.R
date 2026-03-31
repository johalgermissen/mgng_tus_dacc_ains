#!/usr/bin/env Rscript
# ============================================================================ #
## 06_mgngtus_power.R
## MGNGTUS Nomiki's data: compute post-hoc sensitivity/power.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

rm(list = ls())

# ============================================================================ #
#### 00) Correction for multiple comparisons: ####

## P-value after correction for multiple comparisons:
pValOrig <- 0.05
nTest <- 7

## Bonferroni-correction:
pVal <- pValOrig/nTest; pVal

## Dunn-Sidak correction:
pVal <- 1 - (1 - pValOrig)^(1/nTest); pVal

## 7 tests:
# Bonferroni: 0.007142857
# Dunn-Sidak: 0.007300832

## 5 tests:
# Bonferroni: 0.01
# Dunn-Sidak: 0.01020622

# ============================================================================ #
#### 01) Compute power for Cohen's d (without data): ####

library(pwr)

## Planned sample size:
nSub <- 29

## Significance level:
alpha <- 0.05

# -------------------------------------- #
### Range of effect size to loop over:
dRange <- seq(0.10, 1.00, 0.01)

# -------------------------------------- #
### Convert Cohen's d into Hedges' g:
J  <- 1 - 3/(4*nSub - 5)
gRange <- dRange * J

# -------------------------------------- #
### Select effect size to display:

# xRange <- dRange; xLab <- "Cohen's d"; letterName <- "d"
xRange <- gRange; xLab <- "Hedges' g"; letterName <- "g"

# -------------------------------------- #
### Compute power:

powerVec <- rep(NA, length(dRange)) # initialize
for (idx in 1:length(dRange)){
  tmp <- pwr.t.test(n = nSub, d = dRange[idx], sig.level = alpha, alternative = "two.sided")
  powerVec[idx] <- tmp$power
}

# -------------------------------------- #
### Compute critical cut-offs:

p50Idx <- which(powerVec > 0.50)[1]; xRange[p50Idx]
p80Idx <- which(powerVec > 0.80)[1]; xRange[p80Idx]
p95Idx <- which(powerVec > 0.95)[1]; xRange[p95Idx]

## Plot:
library(latex2exp)
CEX <- 1.2 # 2
LWD <- 3
xLim <- c(min(dRange), max(dRange))
yLim <- c(0, 1)
plot(NA, axes = FALSE, xaxt = "n", yaxt = "n", bty = "n", frame.plot = F,
     xlim = xLim, ylim = yLim, 
     lwd = LWD, cex.lab = CEX, cex.axis = CEX*3/4, cex.main = CEX,
     xlab = xLab, ylab = expression("Power"), 
     main = paste0("Power analysis with nSub = ", nSub, ", ", TeX("$\\alpha$"), " = ", round(alpha, 4)))
axis(side = 1, lwd = LWD, cex.axis = CEX, at = seq(xLim[1], xLim[2], 0.1), line = 0)
axis(side = 2, lwd = LWD, cex.axis = CEX, at = seq(yLim[1], yLim[2], 0.1), line = 0)
lines(xRange, powerVec, lwd = LWD)
# points(xRange, powerVec, lwd = LWD)

## Add critical points as lines:
nRound <- 2
xOffset <- 0
yOffset <- 0.02
abline(h = .50, lwd = 2, lty = 3)
abline(v = xRange[p50Idx], lwd = 2, lty = 3)
text(xRange[1] + xOffset, 0.50 + yOffset, paste0(letterName, " > ", round(xRange[p50Idx], nRound), " with 50%"), adj = c(0, 0))
abline(h = .80, lwd = 2)
abline(v = xRange[p80Idx], lwd = 2)
text(xRange[1] + xOffset, 0.80 + yOffset, paste0(letterName, " > ", round(xRange[p80Idx], nRound), " with 80%"), adj = c(0, 0))
abline(h = .95, lwd = 2, lty = 2)
abline(v = xRange[p95Idx], lwd = 2, lty = 2)
text(xRange[1] + xOffset, 0.95 + yOffset, paste0(letterName, " > ", round(xRange[p95Idx], nRound), " with 95%"), adj = c(0, 0))

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 02a) Set directories, load packages and custom functions: ####

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
#### 02b) Read in behavioral data: ####

# ----------------------------------- #
## Read in behavioral data:

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

length(unique(data$subID))

# ============================================================================ #
#### 02c) Exclude subjects with incomplete sessions or outlier behaviour: ####

length(unique(data$subID))
table(data$subID, data$sonication_f)
incompleteSubs <- c("JIJS1080", "KYJF0110", "MRMO0104", "NACA0882")
outlierSubs <- c("EEMR0429")
excludeSubs <- sort(unique(c(incompleteSubs, outlierSubs)))
data <- subset(data, !(subID %in% excludeSubs))
table(data$subID, data$sonication_f)
length(unique(data$subID))

# ============================================================================ #
#### 02d) Exclude excessive cue repetitions: ####

data <- subset(data, cueRep_n %in% 1:20)

# ============================================================================ #
#### 02e) Select data, standardize variables: ####

modData <- select_standardize(data)
length(unique(modData$subID))

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 03) Estimate ICC: ####

table(modData$sonication_f)

# modData <- droplevels(subset(modData, sonication_f == "dACC"))
# modData <- droplevels(subset(modData, sonication_f == "aIns"))
# modData <- droplevels(subset(modData, sonication_f == "sham"))

table(modData$sonication_f)

# ----------------------------------------------------- #
### responses:

formula <- "response_n ~ 1 + (1|subject_f)"
mod <- glmer(formula = formula, data = modData, family = binomial(),
             control = glmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
summary(mod)

## Extract variances and compute ICC:
varData <- as.data.frame(VarCorr(mod))
ICC <- varData$vcov[1] / (varData$vcov[1] + (pi^2)/3); ICC
# Residual variance is fixed to pi^2/3, see 
# https://stats.stackexchange.com/questions/62770/calculating-icc-for-random-effects-logistic-regression
# https://stats.stackexchange.com/questions/128750/residual-variance-for-glmer

## response: 0.009186178 (all conditions)
## response: 0.01420881 (dACC only)
## response: 0.02188468 (aIns only)
## response: 0.007776125 (sham only)

# ----------------------------------------------------- #
### RTs:

formula <- "RT_n ~ 1 + (1|subject_f)"
mod <- lmer(formula = formula, data = modData,
            control = lmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
summary(mod)

## Extract variances and compute ICC:
varData <- as.data.frame(VarCorr(mod))
ICC <- varData$vcov[1] / (varData$vcov[1] + varData$vcov[2]); ICC

# RTs: 0.1770352 (all conditions)
# RTs: 0.2576595 (dACC only)
# RTs: 0.1848063 (aIns only)
# RTs: 0.1836319 (sham only)

# ============================================================================ #
#### 04a) Compute r achieved with 80%: ####

## ICC:
# ICC <- 0.009186178 # responses
ICC <- 0.1770352 # RTs

## Compute effective sample size:
nSub <- 29
nTrial <- 960 # table(data$subID)
nData <- nSub*nTrial; nData
Neff <- nData/ (1 + (nSub - 1) * ICC); Neff

alpha <- 0.05

## Compute required b given fixed power level:
power <- 0.80
tmp <- pwr.r.test(n = Neff, sig.level = alpha, power = power)
tmp
tmp$r

# ============================================================================ #
#### 04b) Compute r achieved with variable power: ####

## ICC:
# ICC <- 0.009186178 # responses
# ICC <- 0.1770352 # RTs

## Compute effective sample size:
nSub <- 29
# nTrial <- 960 # table(data$subID)
nTrial <- nrow(modData)/nSub # 948.7241
nData <- nSub*nTrial; nData
Neff <- nData/ (1 + (nSub - 1) * ICC); Neff

## Significance level:
alpha <- 0.05

## Range of effect size to loop over:
# rRange <- seq(0, 0.10, 0.01)
rRange <- seq(0, 0.05, 0.001)
# rRange <- seq(0.02, 0.20, 0.01)

powerVec <- rep(NA, length(rRange)) # initialize
for (idx in 1:length(rRange)){
  tmp <- pwr.r.test(n = nData, r = rRange[idx], sig.level = alpha, alternative = "two.sided")
  powerVec[idx] <- tmp$power
}

## Critical cut-offs:
p50Idx <- which(powerVec > 0.50)[1]; rRange[p50Idx]
p80Idx <- which(powerVec > 0.80)[1]; rRange[p80Idx]
p95Idx <- which(powerVec > 0.95)[1]; rRange[p95Idx]

## Plot:
library(latex2exp)
CEX <- 1 # 1.2 # 2
LWD <- 3
xLim <- c(min(rRange), max(rRange))
yLim <- c(0, 1)
plot(NA, axes = FALSE, xaxt = "n", yaxt = "n", bty = "n", frame.plot = F,
     xlim = xLim, ylim = yLim, 
     lwd = LWD, cex.lab = CEX, cex.axis = CEX*3/4, cex.main = CEX,
     xlab = paste0("Standardized regression coefficient b"), ylab = expression("Power"), 
     main = paste0("Power analysis with nSub = ", nSub, ", ", TeX("$\\alpha$"), " = ", round(alpha, 4), ", ICC = ", round(ICC, 3)))
axis(side = 1, lwd = LWD, cex.axis = CEX, at = seq(xLim[1], xLim[2], 0.01), line = 0)
axis(side = 2, lwd = LWD, cex.axis = CEX, at = seq(yLim[1], yLim[2], 0.10), line = 0)
lines(rRange, powerVec, lwd = LWD)
# points(rRange, powerVec, lwd = LWD)

## Add critical points as lines:
xOffset <- 0.03
yOffset <- 0.02
abline(h = .50, lwd = 2, lty = 3)
abline(v = rRange[p50Idx], lwd = 2, lty = 3)
text(rRange[1] + xOffset, 0.50 + yOffset, paste0("b > ", rRange[p50Idx], " with 50%"), adj = c(0, 0))
abline(h = .80, lwd = 2)
abline(v = rRange[p80Idx], lwd = 2)
text(rRange[1] + xOffset, 0.80 + yOffset, paste0("b > ", rRange[p80Idx], " with 80%"), adj = c(0, 0))
abline(h = .95, lwd = 2, lty = 2)
abline(v = rRange[p95Idx], lwd = 2, lty = 2)
text(rRange[1] + xOffset, 0.95 + yOffset, paste0("b > ", rRange[p95Idx], " with 95%"), adj = c(0, 0))

# END OF SCRIPT.