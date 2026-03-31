#!/usr/bin/env Rscript
# ============================================================================ #
## 01_mgngtus_regression.R
## MGNG-TUS study: Fit mixed-effects logistic/linear regression models to behaviour (responses, repetitions, RTs).
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

## Inspect:
length(unique(data$subID))
table(data$subID, data$sonication_f)
table(data$subID, data$cue_n)
table(data$subID, data$cueRep_n)

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
#### 01e) Select data, standardize variables, add age, gender, session number: ####

modData <- select_standardize(data)
modData <- add_demographics(modData) # add age and gender
modData <- add_session_order(modData) # add session order

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 02a) Fit mixed-effects logistic regression models on RESPONSES: ####

# ---------------------------------------------------------------------------- #
### Select formula:

## 2-way interactions:
formula <- "response_n ~ reqAction_f * valence_f + (reqAction_f * valence_f|subject_f)"

## 3-way interaction:
formula <- "response_n ~ reqAction_f * valence_f * sonication_f + (reqAction_f * valence_f * sonication_f|subject_f)"

## 4-way interaction:
formula <- "response_n ~ reqAction_f * valence_f * sonication_f * firstHalfBlock_f + (reqAction_f * valence_f * sonication_f * firstHalfBlock_f|subject_f)"

## Interactions with age and gender:
formula <- "response_n ~ reqAction_f * valence_f * age_z + reqAction_f * valence_f * gender_f + (reqAction_f * valence_f|subject_f)"
formula <- "response_n ~ reqAction_f * valence_f * sonication_f * age_z + reqAction_f * valence_f * sonication_f * gender_f + (reqAction_f * valence_f * sonication_f|subject_f)"

## Interactions with session ID:
formula <- "response_n ~ reqAction_f * valence_f * session_f + (reqAction_f * valence_f * session_f|subject_f)"

## Interactions with session order:
formula <- "response_n ~ reqAction_f * valence_f * sonOrder_f + (reqAction_f * valence_f|subject_f)"
formula <- "response_n ~ reqAction_f * valence_f * sonication_f * sonOrder_f + (reqAction_f * valence_f * sonication_f|subject_f)"

## Effect of cue set:
formula <- "response_n ~ cue_set_f + (cue_set_f|subject_f)"
formula <- "response_n ~ session_f * block_f + (session_f * block_f|subject_f)"

# ---------------------------------------------------------------------------- #
### Fit or read existing model back in:
mod <- fit_lmem(formula)
quickCI(mod, nRound = 3)
# mod <- fit_lmem(formula, useLRT = T) # for LRTs; very slow

## Plots:
plot(effect("reqAction_f:valence_f", mod))
plot(effect("reqAction_f:valence_f", mod, x.var = "valence_f"))
plot(effect("reqAction_f:valence_f", mod), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))

plot(effect("valence_f:sonication_f", mod), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))
plot(effect("reqAction_f:valence_f:sonication_f", mod))
plot(effect("reqAction_f:valence_f:sonication_f", mod), multiline = T)
plot(effect("reqAction_f:valence_f:sonication_f", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))

plot(effect("reqAction_f:valence_f:sonication_f:firstHalfBlock_f", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))

plot(effect("reqAction_f:age_z", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))
plot(effect("reqAction_f:gender_f", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))

plot(effect("session_f", mod), multiline = T, lwd = 4)
plot(effect("reqAction_f:session_f", mod), multiline = T, lwd = 4)

plot(effect("sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("reqAction_f:sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("sonication_f:sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("reqAction_f:sonication_f:sonOrder_f", mod), multiline = T, lwd = 4)

plot(effect("cue_set_f", mod), multiline = T, lwd = 4)
plot(effect("session_f:block_f", mod), multiline = T, lwd = 4)
plot(effect("session_f:block_f", mod, x.var = "session_f"), multiline = T, lwd = 4)

# ============================================================================ #
#### 02b) Fit logistic regression models to responses manually & separately per cue condition: ####

# ---------------------------------------------------------------------------- #
### Select cue conditions:

selData <- droplevels(modData) ## all data
selData <- droplevels(subset(modData, reqAction_f == "Go"))
selData <- droplevels(subset(modData, reqAction_f == "NoGo"))

selData <- droplevels(subset(modData, reqAction_f == "Go" & valence_f == "Win"))
selData <- droplevels(subset(modData, reqAction_f == "Go" & valence_f == "Avoid"))
selData <- droplevels(subset(modData, reqAction_f == "NoGo" & valence_f == "Win"))
selData <- droplevels(subset(modData, reqAction_f == "NoGo" & valence_f == "Avoid"))

## Inspect:
table(selData$reqAction_f)
table(selData$valence_f)
table(selData$reqAction_f, selData$valence_f)

# ---------------------------------------------------------------------------- #
### Select block half:

selData <- droplevels(subset(selData, firstHalfBlock_f == "first"))
selData <- droplevels(subset(selData, firstHalfBlock_f == "second"))

## Inspect:
table(selData$firstHalfBlock_f)

# ---------------------------------------------------------------------------- #
### Select sonication conditions:

selData <- droplevels(subset(selData, sonication_f == "sham"))
selData <- droplevels(subset(selData, sonication_f %in% c("sham", "dACC")))
selData <- droplevels(subset(selData, sonication_f %in% c("sham", "aIns")))

## Inspect:
table(selData$sonication_f)

# ---------------------------------------------------------------------------- #
### Select formula:

## Sonication main effect:
formula <- "response_n ~ sonication_f + (sonication_f|subject_f)"

## 2-way interactions:
formula <- "response_n ~ reqAction_f * valence_f + (reqAction_f * valence_f|subject_f)"
formula <- "response_n ~ valence_f * sonication_f + (valence_f * sonication_f|subject_f)"
formula <- "response_n ~ sonication_f * firstHalfBlock_f + (sonication_f * firstHalfBlock_f|subject_f)"

## 3-way interactions:
formula <- "response_n ~ valence_f * sonication_f * firstHalfBlock_f + (valence_f * sonication_f * firstHalfBlock_f|subject_f)"

# ---------------------------------------------------------------------------- #
### Fit manually:

mod <- glmer(formula = formula, data = selData, family = binomial(),
             control = glmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
summary(mod, correlation = F); beep()
quickCI(mod)
Anova(mod, type = "3")

# ---------------------------------------------------------------------------- #
### Plot:

plot(effect("reqAction_f:valence_f", mod), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))

plot(effect("sonication_f", mod), multiline = T, lwd = 4)
plot(effect("valence_f:sonication_f", mod, x.var = "sonication_f"), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))

plot(effect("sonication_f:firstHalfBlock_f", mod, x.var = "firstHalfBlock_f"), multiline = T, lwd = 4, colors = c("grey90", "#D3436EFF", "#FEBA80FF"))
plot(effect("sonication_f:firstHalfBlock_f", mod, x.var = "firstHalfBlock_f"), multiline = T, lwd = 4, colors = c("grey90", "#D3436EFF"))
plot(effect("sonication_f:firstHalfBlock_f", mod, x.var = "firstHalfBlock_f"), multiline = T, lwd = 4, colors = c("grey90", "#FEBA80FF"))

plot(effect("valence_f:sonication_f:firstHalfBlock_f", mod, x.var = "valence_f"), multiline = T, lwd = 4)
plot(effect("valence_f:sonication_f:firstHalfBlock_f", mod, x.var = "firstHalfBlock_f"), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))

# ---------------------------------------------------------------------------- #
### Post-hoc z-tests with emmeans:

emmeans(mod, specs = pairwise ~ valence_f | reqAction_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 
emmeans(mod, specs = pairwise ~ reqAction_f | valence_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 

emmeans(mod, specs = pairwise ~ sonication_f | reqAction_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 
emmeans(mod, specs = pairwise ~ sonication_f | valence_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 
emmeans(mod, specs = pairwise ~ sonication_f | firstHalfBlock_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 

## Sonication effect given required action x valence x block half combination:
emmeans(mod, specs = pairwise ~ sonication_f | valence_f:reqAction_f:firstHalfBlock_f, 
        regrid = "response", interaction = "pairwise", adjust = "none") 
emmeans(mod, specs = pairwise ~ sonication_f | valence_f:reqAction_f:firstHalfBlock_f, 
        interaction = "pairwise", adjust = "none") 

## Difference in Valence effect between sonications given reqAction level:
emmeans(mod, specs = pairwise ~ valence_f:sonication_f | reqAction_f, 
        regrid = "response", interaction = "pairwise", adjust = "none") 
emmeans(mod, specs = pairwise ~ reqAction_f:sonication_f | valence_f, 
        regrid = "response", interaction = "pairwise", adjust = "none")

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 03a) Fit mixed-effects logistic regression models to RESPONSE REPETITIONS: ####

# ---------------------------------------------------------------------------- #
### Select formula:

## Learning bias: stronger outcome effect for Go than NoGo (trials are valenced outcomes only):
formula <- "repeat_n ~ outcome_last_rel_f * response_last_f + (outcome_last_rel_f * response_last_f|subject_f)"

## Persistence bias: main effect of cue valence:
formula <- "repeat_n ~ valence_f + (valence_f|subject_f)"

## Interactions with age and gender:
formula <- "repeat_n ~ outcome_last_rel_f * response_last_f * age_z + outcome_last_rel_f * response_last_f * gender_f + (outcome_last_rel_f * response_last_f|subject_f)"
formula <- "repeat_n ~ outcome_last_rel_f * response_last_f * sonication_f * age_z + outcome_last_rel_f * response_last_f * sonication_f * gender_f + (outcome_last_rel_f * response_last_f * sonication_f|subject_f)"
formula <- "repeat_n ~ valence_f * age_z + valence_f * gender_f + (valence_f|subject_f)"
formula <- "repeat_n ~ valence_f * sonication_f * age_z + valence_f * sonication_f * gender_f + (valence_f * sonication_f|subject_f)"

## Interactions with session ID:
formula <- "repeat_n ~ outcome_last_rel_f * response_last_f * session_f + (outcome_last_rel_f * response_last_f * session_f|subject_f)"
formula <- "repeat_n ~ valence_f * session_f + (valence_f * session_f|subject_f)"

## Interactions with session order:
formula <- "repeat_n ~ sonOrder_f + (1|subject_f)"
formula <- "repeat_n ~ outcome_last_rel_f * response_last_f * sonOrder_f + (outcome_last_rel_f * response_last_f|subject_f)"
formula <- "repeat_n ~ valence_f * sonOrder_f + (valence_f|subject_f)"
formula <- "repeat_n ~ valence_f * sonication_f * sonOrder_f + (valence_f * sonication_f|subject_f)"

## Effect of cue set:
formula <- "repeat_n ~ cue_set_f + (cue_set_f|subject_f)"
formula <- "repeat_n ~ session_f * block_f + (session_f * block_f|subject_f)"

# ---------------------------------------------------------------------------- #
### Fit model automatically or read past fit back in:

mod <- fit_lmem(formula)

# ============================================================================ #
#### 03b) Fit logistic regression model to response repetitions manually & separately per condition: ####

# ---------------------------------------------------------------------------- #
### Select task conditions:

selData <- droplevels(modData) # all data

## For learning bias:
selData <- droplevels(subset(modData, salience_last_f == "salient"))

## For learning bias modulation by sonication:
selData <- droplevels(subset(modData, (outcome_last_all_f == "rewarded" & response_last_f == "Go") | (outcome_last_all_f == "punished" & response_last_f == "NoGo")))

## Inspect:
table(selData$outcome_last_all_f)
table(selData$response_last_f)
table(selData$outcome_last_all_f, selData$response_last_f)

# ---------------------------------------------------------------------------- #
### Select sonication conditions:

selData <- droplevels(subset(selData, sonication_f == "sham"))
selData <- droplevels(subset(selData, sonication_f %in% c("sham", "dACC")))
selData <- droplevels(subset(selData, sonication_f %in% c("sham", "aIns")))

## Inspect:
table(selData$sonication_f)

# ---------------------------------------------------------------------------- #
### Select formula:

## Learning bias: only after salient outcomes:
formula <- "repeat_n ~ outcome_last_rel_f * response_last_f + (outcome_last_rel_f * response_last_f|subject_f)"

## Learning bias modulated by TUS aIns: only rewarded Gos & punished NoGos:
formula <- "repeat_n ~ sonication_f * outcome_last_rel_f + (sonication_f * outcome_last_rel_f|subject_f)"

## Persistence bias: all outcomes/conditions:
formula <- "repeat_n ~ sonication_f * valence_f + (sonication_f * valence_f|subject_f)"

# ---------------------------------------------------------------------------- #
### Fit manually:

mod <- glmer(formula = formula, data = selData, family = binomial(),
             control = glmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
summary(mod); beep()
Anova(mod, type = "3")
quickCI(mod)

# ---------------------------------------------------------------------------- #
### Plot:

plot(effect("outcome_last_rel_f", mod), multiline = T, lwd = 4)
plot(effect("response_last_f", mod), multiline = T, lwd = 4)
plot(effect("outcome_last_rel_f:response_last_f", mod, x.var = "response_last_f"), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))

plot(effect("sonication_f", mod), multiline = T, lwd = 4)
plot(effect("valence_f", mod), multiline = T, lwd = 4)
plot(effect("sonication_f:valence_f", mod), multiline = T, lwd = 4)

plot(effect("age_z", mod), multiline = T, lwd = 4)
plot(effect("gender_f", mod), multiline = T, lwd = 4)
plot(effect("outcome_last_rel_f:age_z", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))
plot(effect("response_last_f:age_z", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))

plot(effect("session_f", mod), multiline = T, lwd = 4)
plot(effect("outcome_last_rel_f:session_f", mod), multiline = T, lwd = 4)
plot(effect("response_last_f:session_f", mod), multiline = T, lwd = 4)

plot(effect("sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("sonication_f:sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("outcome_last_rel_f:response_last_f:sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("valence_f:sonOrder_f", mod), multiline = T, lwd = 4)
plot(effect("valence_f:sonication_f:sonOrder_f", mod), multiline = T, lwd = 4)

plot(effect("cue_set_f", mod), multiline = T, lwd = 4)
plot(effect("session_f:block_f", mod), multiline = T, lwd = 4)
plot(effect("session_f:block_f", mod, x.var = "session_f"), multiline = T, lwd = 4)

# ---------------------------------------------------------------------------- #
### Post-hoc z-tests with emmeans:

emmeans(mod, specs = pairwise ~ sonication_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 
emmeans(mod, specs = pairwise ~ sonication_f | outcome_last_rel_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 

emmeans(mod, specs = pairwise ~ sonication_f | valence_f, 
        interaction = "pairwise", regrid = "response", adjust = "none") 

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #
#### 04a) Fit mixed-effects linear regression models to RTs: ####

## Select sonication conditions:
selData <- modData # all data
selData <- droplevels(subset(modData, sonication_f == "sham"))
selData <- droplevels(subset(modData, sonication_f %in% c("sham", "dACC")))
selData <- droplevels(subset(modData, sonication_f %in% c("sham", "aIns")))

## Inspect:
table(selData$sonication_f)
length(unique(selData$subID))
table(selData$subID)

## Inspect outliers:
sum(selData$RT_n < 0.2, na.rm = T)
tapply(selData$RTcleaned_n, selData$response_f, mean, na.rm = T)
tapply(selData$RTcleaned_n, selData$reqAction_f, mean, na.rm = T)
tapply(selData$RTcleaned_n, selData$valence_f, mean, na.rm = T)
densityplot(selData$RTcleaned_z)

# ---------------------------------------------------------------------------- #
### Select formula:

## 2-way interactions:
formula <- "RTcleaned_z ~ reqAction_f * valence_f + (reqAction_f * valence_f|subject_f)"

## 3-way interaction:
formula <- "RTcleaned_z ~ reqAction_f * valence_f * sonication_f + (reqAction_f * valence_f * sonication_f|subject_f)"

# ---------------------------------------------------------------------------- #
### Fit linear regression or read in past fit:

mod <- fit_lmem(formula)
quickCI(mod, nRound = 3)
mod <- fit_lmem(formula, useLRT = T)

# ---------------------------------------------------------------------------- #
### Fit manually:

mod <- lmer(formula = formula, data = selData, 
            control = lmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
summary(mod, correlation = F); beep()
quickCI(mod)
Anova(mod, type = "3")

# ---------------------------------------------------------------------------- #
### Plot:

plot(effect("reqAction_f", mod), multiline = T, lwd = 4)
plot(effect("valence_f", mod), multiline = T, lwd = 4)
plot(effect("sonication_f", mod), multiline = T, lwd = 4)

plot(effect("reqAction_f:valence_f", mod), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))

plot(effect("reqAction_f:sonication_f", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))
plot(effect("valence_f:sonication_f", mod), multiline = T, lwd = 4, colors = c("#007174", "#c93d21"))
plot(effect("reqAction_f:valence_f:sonication_f", mod), multiline = T, lwd = 4, colors = c("#B2182B", "#2166AC"))

# ---------------------------------------------------------------------------- #
### Post-hoc z-tests with emmeans:

emmeans(mod, specs = pairwise ~ valence_f | reqAction_f, 
        interaction = "pairwise", djust = "none") 
emmeans(mod, specs = pairwise ~ reqAction_f | valence_f, 
        interaction = "pairwise", djust = "none") 

emmeans(mod, specs = pairwise ~ sonication_f | reqAction_f, 
        interaction = "pairwise", djust = "none") 
emmeans(mod, specs = pairwise ~ sonication_f | valence_f, 
        interaction = "pairwise", djust = "none") 

emmeans(mod, specs = pairwise ~ valence_f:sonication_f | reqAction_f, 
        interaction = "pairwise", adjust = "none") 
emmeans(mod, specs = pairwise ~ reqAction_f:sonication_f | valence_f, 
        interaction = "pairwise", adjust = "none")

# END OF FILE.