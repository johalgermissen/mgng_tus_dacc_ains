#!/usr/bin/env Rscript
# ============================================================================ #
## 05_mgngtus_params_visualisations.R
## MGNGTUS Nomiki's data: visualize exemplary data for high/low parameter values.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

rm(list = ls())

# ============================================================================ #
#### 00a) Load directories and functions: ####

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
#### 00b) Create extra functions: ####

### Bar plot with 1 IV:
custom_barplot1_flat <- function(data, xVar, yVar, main = NULL){
  
  LWD <- 1.5
  FTS <- 32
  dodgeVal <- 0.6
  colAlpha <- 1
  yLim <- c(0, 1)
  
  data$x <- data[, xVar]
  data$y <- data[, yVar]
  selCol <- retrieve_colour(xVar)
  xLab <- substitute_label(xVar)
  yLab <- substitute_label(yVar)
  
  p <- ggplot(data, aes(x = x, fill = x, y = y)) + 
    stat_summary(fun = mean, geom = "bar", position = "dodge", width = 0.6,
                 lwd = LWD, fill = selCol, color = "black") +
    scale_fill_manual(values = selCol) + 
    labs(x = xLab, y = yLab, fill = xLab) +
    coord_cartesian(ylim = yLim) + 
    theme_classic() + 
    theme(axis.text = element_text(size = FTS),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.title = element_text(size = FTS), 
          plot.title = element_text(size = FTS, hjust = 0.5), 
          legend.title = element_blank(), legend.position = "none",
          axis.line = element_line(colour = 'black')) # , linewidth = LWD)) # fixed font sizes
  if (!(is.null(main))){
    p <- p + ggtitle(main)
  }
  
  print(p)  
  return(p)
}

### Bar plot with 2 IVs:
custom_barplot2_flat <- function(data, xVar, zVar, yVar, main = NULL){
  
  LWD <- 1.5
  FTS <- 32
  dodgeVal <- 0.6
  colAlpha <- 1
  yLim <- c(0, 1)
  
  data$x <- data[, xVar]
  data$z <- data[, zVar]
  data$y <- data[, yVar]
  selCol <- retrieve_colour(zVar)
  xLab <- substitute_label(xVar)
  zLab <- substitute_label(zVar)
  yLab <- substitute_label(yVar)
  
  p <- ggplot(data, aes(x = x, fill = z, y = y)) + 
    stat_summary(fun = mean, geom = "bar", position = "dodge", width = dodgeVal,
                 lwd = LWD, color = "black") + 
    scale_fill_manual(values = selCol) + 
    labs(x = xLab, y = yLab, fill = zLab) +
    coord_cartesian(ylim = yLim) + 
    theme_classic() + 
    theme(axis.text = element_text(size = FTS),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.title = element_text(size = FTS), 
          plot.title = element_text(size = FTS, hjust = 0.5), 
          legend.title = element_blank(), legend.position = "none",
          axis.line = element_line(colour = 'black')) # , linewidth = LWD)) # fixed font sizes
  if (!(is.null(main))){
    p <- p + ggtitle(main)
  }
  
  print(p)  
  return(p)
}

# ============================================================================ #
#### 01) Rho: ####

hypData <- data.frame(
  reqAction_n = c(1, 1, 2, 2),
  valence_n = c(1, 2, 1, 2))
hypData$reqAction_f <- factor(hypData$reqAction_n, levels = c(1, 2), labels = c("Go", "NoGo"))
hypData$valence_f <- factor(hypData$valence_n, levels = c(1, 2), labels = c("Win", "Avoid"))

## Weak:
hypData$response_n <- c(0.65, 0.55, 0.45, 0.35)
p <- custom_barplot2_flat(data = hypData, xVar = "reqAction_f", zVar = "valence_f", yVar = "response_n", main = "Weak rho")

## Strong:
hypData$response_n <- c(0.85, 0.75, 0.25, 0.15)
p <- custom_barplot2_flat(data = hypData, xVar = "reqAction_f", zVar = "valence_f", yVar = "response_n", main = "Strong rho")

plotName <- paste0("Figure", yName)
png(paste0(dirs$plot, "final/", plotName, ".png"), width = 240, height = 480)
print(p)
dev.off()

# ============================================================================ #
#### 02) Epsilon: ####

hypData <- data.frame(
  outcome_last_rel_n = c(1, 2))
hypData$outcome_last_rel_f <- factor(hypData$outcome_last_rel_n, levels = c(1, 2), labels = c("Positive", "Negative"))

## Weak:
hypData$repeat_n <- c(0.75, 0.65)
p <- custom_barplot1_flat(data = hypData, xVar = "outcome_last_rel_f", yVar = "repeat_n", main = "Weak epsilon")

## Strong:
hypData$repeat_n <- c(0.90, 0.50)
p <- custom_barplot1_flat(data = hypData, xVar = "outcome_last_rel_f", yVar = "repeat_n", main = "Strong epsilon")

# ============================================================================ #
#### 03) b: ####

hypData <- data.frame(
  reqAction_n = c(1, 1, 2, 2),
  valence_n = c(1, 2, 1, 2))
hypData$reqAction_f <- factor(hypData$reqAction_n, levels = c(1, 2), labels = c("Go", "NoGo"))
hypData$valence_f <- factor(hypData$valence_n, levels = c(1, 2), labels = c("Win", "Avoid"))

## Weak:
hypData$response_n <- c(0.75, 0.65, 0.35, 0.25)
p <- custom_barplot2_flat(data = hypData, xVar = "reqAction_f", zVar = "valence_f", yVar = "response_n", main = "Weak b")

## Strong:
hypData$response_n <- c(0.95, 0.85, 0.55, 0.45)
p <- custom_barplot2_flat(data = hypData, xVar = "reqAction_f", zVar = "valence_f", yVar = "response_n", main = "Strong b")

# ============================================================================ #
#### 04) Pi: ####

hypData <- data.frame(
  reqAction_n = c(1, 1, 2, 2),
  valence_n = c(1, 2, 1, 2))
hypData$reqAction_f <- factor(hypData$reqAction_n, levels = c(1, 2), labels = c("Go", "NoGo"))
hypData$valence_f <- factor(hypData$valence_n, levels = c(1, 2), labels = c("Win", "Avoid"))

## Weak:
hypData$response_n <- c(0.80, 0.70, 0.30, 0.20)
p <- custom_barplot2_flat(data = hypData, xVar = "reqAction_f", zVar = "valence_f", yVar = "response_n", main = "Weak pi")

## Strong:
hypData$response_n <- c(0.90, 0.60, 0.40, 0.10)
p <- custom_barplot2_flat(data = hypData, xVar = "reqAction_f", zVar = "valence_f", yVar = "response_n", main = "Strong pi")

# ============================================================================ #
#### 05) Kappa: ####

hypData <- data.frame(
  response_last_n = c(1, 1, 2, 2),
  outcome_last_rel_n = c(1, 2, 1, 2))
hypData$response_last_f <- factor(hypData$response_last_n, levels = c(1, 2), labels = c("Go", "NoGo"))
hypData$outcome_last_rel_f <- factor(hypData$outcome_last_rel_n, levels = c(1, 2), labels = c("reward", "punishment"))

## Weak:
hypData$repeat_n <- c(0.80, 0.60, 0.75, 0.65)
p <- custom_barplot2_flat(data = hypData, xVar = "response_last_f", zVar = "outcome_last_rel_f", yVar = "repeat_n", main = "Weak kappa")

## Strong:
hypData$repeat_n <- c(0.90, 0.50, 0.75, 0.65)
p <- custom_barplot2_flat(data = hypData, xVar = "response_last_f", zVar = "outcome_last_rel_f", yVar = "repeat_n", main = "Strong kappa")

# ============================================================================ #
#### 06) Phi_Int: ####

hypData <- data.frame(
  valence_n = c(1, 2, 1, 2))
hypData$valence_f <- factor(hypData$valence_n, levels = c(1, 2), labels = c("Win", "Avoid"))

hypData$repeat_n <- c(0.75, 0.65)
p <- custom_barplot1_flat(data = hypData, xVar = "valence_f", yVar = "repeat_n", main = "Weak phi_Int")

hypData$repeat_n <- c(0.95, 0.85)
p <- custom_barplot1_flat(data = hypData, xVar = "valence_f", yVar = "repeat_n", main = "Strong phi_Int")

# ============================================================================ #
#### 07) Phi_Dif: ####

hypData <- data.frame(valence_n = c(1, 2))
hypData$valence_f <- factor(hypData$valence_n, levels = c(1, 2), labels = c("Win", "Avoid"))

hypData$repeat_n <- c(0.82, 0.78)
p <- custom_barplot1_flat(data = hypData, xVar = "valence_f", yVar = "repeat_n", main = "Weak phi_Dif")

hypData$repeat_n <- c(0.90, 0.70)
p <- custom_barplot1_flat(data = hypData, xVar = "valence_f", yVar = "repeat_n", main = "Strong phi_Dif")

# END