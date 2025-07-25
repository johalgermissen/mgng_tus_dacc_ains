#!/usr/bin/env Rscript
# ============================================================================ #
## 00_mgngtus_functions_regression.R
## MGNG-TUS study: Functions for plotting and fitting regressions to behavioral data.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

# ============================================================================ #
#### 01) Read in behavioral data: ####

read_behavior <- function(inputFileDir){
  #' Read in behavioral raw data.
  #' @return data   data frame un-processed behavioral raw data.

  ## Fixed settings:
  nTrial <- 320
  
  ## Find all raw data files:
  selPattern = ".txt"
  fileList <- list.files(inputFileDir, pattern = selPattern, full = TRUE)
  nFile <- length(fileList) # count subject
  if(nFile == 0){stop("No files found")}
  cat(paste0("Found ", nFile, " files\n"))
  
  ## Read data:
  data <- do.call("rbind", lapply(fileList, read.delim, header = F))
  
  names(data) <- c("stim_ID", "GW", "GAL", "NGW", "NGL", "jitter1", "jitter2", "RT", "outcomefeed")
  
  ## Add subject ID:
  fileVec <- basename(fileList) # remove directory
  fileVec <- substr(fileVec, 1, 8) # only keep subject ID
  data$subjectID <- rep(fileVec, each = nTrial)
  
  ## Inspect:
  print(head(data, n = 10))
  # print(table(data$Subject))
  cat("Finished! :-)\n")
  
  return(data)
}

# ============================================================================ #
#### 02) Pre-process behavioral data: #####

wrapper_preprocessing <- function(data){
  #' Just a wrapper around various pre-processing functions specified below.
  #' @param data    data frame with trial-level data.
  #' @return data   same data frame with additional pre-processed variables.

  ## Count input variables:
  nVar <- ncol(data)

  ## Fixed settings:
  nTrial <- 320
  nBlock <- 4
  nTrialBlock <- nTrial/nBlock
  nSub <- nrow(data)/nTrial
  
  # -------------------------------------------------------------------------- #
  ### ID variables:
  
  cat("Preprocess subject and session indices\n")
  
  # data$subject_n <- rep(1:nSub, each = nTrial)
  data$subID <- data$subjectID
  # data$subject_n <- as.numeric(substr(data$subjectID, 5, 8)) # not enough?
  data$subject_n <- 10000 * match(substr(data$subjectID, 4, 4), LETTERS) + as.numeric(substr(data$subjectID, 5, 8))
  data$subject_f <- factor(data$subject_n)

  data$block_n <- rep(1:nBlock, each = nTrialBlock, times = nSub)
  data$block_f <- factor(data$block_n)
  
  data$trialnr_n <- rep(1:nTrial, times = nSub)
  data$trialnr_f <- factor(data$trialnr_n)
  
  data$subject_block_n <- data$subject_n * 10 + data$block_n
  data$subject_block_f <- factor(data$subject_block_n)
  
  # -------------------------------------------------------------------------- #
  ### Stimuli:
  
  cat("Preprocess stimuli\n")
  
  data$cue_n <- data$stim_ID
  data$cue_block_n <- (data$cue_n - 1) %% 4 + 1
  
  data$reqAction_n <- ifelse((data$stim_ID == data$GW) | (data$stim_ID == data$GAL), 1, 0)
  data$reqAction_f <- factor(data$reqAction_n, levels = c(1, 0), labels = c("Go", "NoGo"))
  
  data$valence_n <- ifelse((data$stim_ID == data$GW) | (data$stim_ID == data$NGW), 1, 0)
  data$valence_f <- factor(data$valence_n, levels = c(1, 0), labels = c("Win", "Avoid"))
  data$valence_short_f <- factor(data$valence_n, levels = c(1, 0), labels = c("win", "avo"))
  
  ## Cue condition:
  data$condition_n <- (1 - data$reqAction_n) * 2 + (1 - data$valence_n) + 1
  # data[1:20, c("reqAction_n", "valence_n", "condition_n")]
  data$condition_f <- factor(data$condition_n, levels = 1:4, labels = c("G2W", "G2A", "NG2W", "NG2A"))
  data$condition_short1_f <- factor(data$condition_n, levels = 1:4, labels = c("G2W", "G2A", "N2W", "N2A"))
  data$condition_short2_f <- factor(data$condition_n, levels = 1:4, labels = c("G2W", "G2A", "N2W", "N2A"))
  
  # -------------------------------------------------------------------------- #
  ### Congruency valence and required response:
  
  data$reqCongruency_n <- ifelse(data$reqAction_n == data$valence_n, 1, 0)
  data$reqCongruency_f <- factor(data$reqCongruency_n, levels = c(1, 0), labels = c("congruent", "incongruent"))
  data$reqCongruency_short1_f <- factor(data$reqCongruency_n, levels = c(1, 0), labels = c("cong", "incong"))
  data$reqCongruency_short2_f <- factor(data$reqCongruency_n, levels = c(1, 0), labels = c("con", "inc"))
  
  # -------------------------------------------------------------------------- #
  ### Responses:

  cat("Preprocess responses\n")
  
  data$response_n <- ifelse(data$RT == 0, 0, 1)
  data$response_f <- factor(data$response_n, levels = c(1, 0), labels = c("Go", "NoGo"))

  # -------------------------------------------------------------------------- #
  ### Accuracy:
  
  cat("Preprocess accuracy\n")
  
  data$ACC_n <- ifelse(data$reqAction_n == data$response_n, 1, 0)
  data$ACC_f <- factor(data$ACC_n, levels = c(1, 0), labels = c("correct", "incorrect"))
  data$ACC_short_f <- factor(data$ACC_n, levels = c(1, 0), labels = c("cor", "inc"))

  # -------------------------------------------------------------------------- #
  ### RTs:
  
  cat("Pre-process RTs\n")
  
  data$RT_n <- data$RT/1000
  data$RT_n[data$RT_n == 0] <- NA
  data$RT_log_n <- log(data$RT_n)
  
  data$RTcleaned_n <- data$RT/1000
  data$RTcleaned_n[data$RTcleaned_n == 0] <- NA
  data$RTcleaned_n[data$RTcleaned_n < 0.3] <- NA
  data$RTcleaned_log_n <- log(data$RTcleaned_n)
  
  # -------------------------------------------------------------------------- #
  ## RT in ms:
  
  cat("Create version of RTs in ms\n")
  data$RT_ms_n <- data$RT
  data$RT_ms_log_n <- log(data$RT_ms_n)
  
  # -------------------------------------------------------------------------- #
  ## RT split in fast/slow per subject:
  
  cat("Split RTs into fast/ slow half per subject\n")
  
  data$RTcleaned_fast_n <- NA # initialize
  data$RTcleaned_valence_n <- NA # initialize
  data$RTcleaned_ACC_n <- NA # initialize
  nSub <- length(unique(data$subject_n)) # count subjects
  for (iSub in 1:nSub){ # iSub <- 1
    
    ## Overall:
    subIdx <- which(data$subject_n == iSub) # rows for this subject
    subMedianRT <- median(data$RTcleaned_n[subIdx], na.rm = T) # mean RT for this subject
    data$RTcleaned_fast_n[subIdx] <- ifelse(data$RTcleaned_n[subIdx] < subMedianRT, 1,
                                            ifelse(data$RTcleaned_n[subIdx] >= subMedianRT, 0,
                                                   NA))
    # data[subIdx, c("RTcleaned_n", "RTcleaned_fast_n")]
    
    ## For Win cues:
    condIdx <- which(data$subject_n == iSub & data$valence_n == 1)
    subMedianRT <- median(data$RTcleaned_n[condIdx], na.rm = T)
    data$RTcleaned_valence_n[condIdx] <- ifelse(data$RTcleaned_n[condIdx] < subMedianRT, 1,
                                                ifelse(data$RTcleaned_n[condIdx] >= subMedianRT, 3, 
                                                       NA))
    
    ## For Avoid cues:
    condIdx <- which(data$subject_n == iSub & data$valence_n == 0)
    subMedianRT <- median(data$RTcleaned_n[condIdx], na.rm = T)
    data$RTcleaned_valence_n[condIdx] <- ifelse(data$RTcleaned_n[condIdx] < subMedianRT, 2,
                                                ifelse(data$RTcleaned_n[condIdx] >= subMedianRT, 4, 
                                                       NA))
    
    ## For correct responses:
    condIdx <- which(data$subject_n == iSub & data$ACC_n == 1)
    subMedianRT <- median(data$RTcleaned_n[condIdx], na.rm = T)
    data$RTcleaned_ACC_n[condIdx] <- ifelse(data$RTcleaned_n[condIdx] < subMedianRT, 1,
                                            ifelse(data$RTcleaned_n[condIdx] >= subMedianRT, 3, 
                                                   NA))
    
    ## For incorrect responses:
    condIdx <- which(data$subject_n == iSub & data$ACC_n == 0)
    subMedianRT <- median(data$RTcleaned_n[condIdx], na.rm = T)
    data$RTcleaned_ACC_n[condIdx] <- ifelse(data$RTcleaned_n[condIdx] < subMedianRT, 2,
                                            ifelse(data$RTcleaned_n[condIdx] >= subMedianRT, 4, 
                                                   NA))
    
  } 
  
  ## To factor:
  # data[subIdx, c("RTcleaned_n", "RTcleaned_fast_sub_n")]
  data$RTcleaned_fast_f <- factor(data$RTcleaned_fast_n, levels = c(1, 0), labels = c("fast", "slow"))
  # table(data$RTcleaned_fast_f)
  # table(data$RTcleaned_fast_f, data$subject_f)
  
  data$RTcleaned_valence_f <- factor(data$RTcleaned_valence_n, levels = c(1:4), labels = c("F2W", "F2A", "S2W", "S2A"))
  # table(data$RTcleaned_valence_f)
  # table(data$RTcleaned_valence_f, data$subject_f)
  # data[1:50, c("RTcleaned_fast_f", "valence_f", "RTcleaned_valence_f")]
  
  ## Based on RTcleaned_fast_n, without per-subject correction for valence:
  data$RTcleaned_valence_uncor_n <- (1 - data$RTcleaned_fast_n) * 2 + (1 - data$valence_n) + 1
  data$RTcleaned_valence_uncor_f <- factor(data$RTcleaned_valence_uncor_n, levels = c(1:4), labels = c("F2W", "F2A", "S2W", "S2A"))
  # table(data$RTcleaned_valence_uncor_f)
  # table(data$RTcleaned_valence_uncor_f, data$subject_f)
  # data[1:50, c("RTcleaned_fast_f", "valence_f", "RTcleaned_valence_uncor_f")]
  
  ## To factor:
  data$RTcleaned_ACC_f <- factor(data$RTcleaned_ACC_n, levels = c(1:4), labels = c("Fcor", "Finc", "Scor", "Sinc"))
  # table(data$RTcleaned_ACC_f)
  # table(data$RTcleaned_ACC_f, data$subject_f)
  # data[1:50, c("RTcleaned_fast_f", "ACC_f", "RTcleaned_ACC_f")]
  
  ## Based on RTcleaned_fast_n, without per-subject correction for accuracy:
  data$RTcleaned_ACC_uncor_n <- (1 - data$RTcleaned_fast_n) * 2 + (1 - data$ACC_n) + 1
  data$RTcleaned_ACC_uncor_f <- factor(data$RTcleaned_ACC_uncor_n, levels = c(1:4), labels = c("Fcor", "Finc", "Scor", "Sinc"))
  # table(data$RTcleaned_ACC_uncor_f)
  # table(data$RTcleaned_ACC_uncor_f, data$subject_f)
  # data[1:50, c("RTcleaned_fast_f", "ACC_f", "RTcleaned_ACC_uncor_f")]
  
  # -------------------------------------------------------------------------- #
  ### Outcomes:
  
  cat("Pre-process outcomes\n")
  
  data$outcome_n <- data$outcomefeed
  data$outcome_f <- factor(data$outcome_n, levels = c(1, 0, -1), labels = c("reward", "neutral", "punishment"))
  data$outcome_short_f <- factor(data$outcome_n, levels = c(1, 0, -1), labels = c("rew", "neu", "pun"))
  
  ## Combine with response:
  data$outcome_response_n <- (2 - data$outcome_n) * 2 - data$response_n
  data$outcome_response_f <- factor(data$outcome_response_n, levels = 1:6, labels = c("rewGo", "rewNoGo", "neuGo", "neuNoGo", "punGo", "punNoGo"))
  # data[1:30, c("outcome_f", "response_f", "outcome_response_f")]
  
  ## Relative outcomes (positive/ negative):
  data$outcome_rel_n <- ifelse(data$outcome_n == 1 | data$outcome_n == 0 & data$valence_n == 0, 1,
                               ifelse(data$outcome_n == -1 | data$outcome_n == 0 & data$valence_n == 1, 0, 
                                      NA))
  data$outcome_rel_f <- factor(data$outcome_rel_n, levels = c(1, 0), labels = c("positive", "negative"))
  data$outcome_rel_short_f <- factor(data$outcome_rel_n, levels = c(1, 0), labels = c("pos", "neg"))

  ## All outcomes (rewarded/ not rewarded/ not punished/ punished):
  data$outcome_all_n <- ifelse(data$outcome_n == 1, 1,
                               ifelse(data$outcome_n == 0 & data$valence_n == 1, 2,
                                      ifelse(data$outcome_n == 0 & data$valence_n == 0, 3,
                                             ifelse(data$outcome_n == -1, 4,
                                                    NA))))
  data$outcome_all_f <- factor(data$outcome_all_n, levels = 1:4, labels = c("rewarded", "not rewarded", "not punished", "punished"))
  data$outcome_all_short_f <- factor(data$outcome_all_n, levels = 1:4, labels = c("rew", "¬rew", "¬pun", "pun"))
  # data[1:40, c("valence_f", "outcome_f", "outcome_all_f")]
  
  # -------------------------------------------------------------------------- #
  ## Feedback validity:
  
  data$validity_n <- ifelse((data$valence_n == 1 & data$ACC_n == 1 & data$outcome_n == 1) |
                            (data$valence_n == 0 & data$ACC_n == 1 & data$outcome_n == 0) |
                            (data$valence_n == 1 & data$ACC_n == 0 & data$outcome_n == 0) |
                            (data$valence_n == 0 & data$ACC_n == 0 & data$outcome_n == -1), 1,
                            ifelse((data$valence_n == 1 & data$ACC_n == 1 & data$outcome_n == 0) |
                                   (data$valence_n == 0 & data$ACC_n == 1 & data$outcome_n == -1) |
                                   (data$valence_n == 1 & data$ACC_n == 0 & data$outcome_n == 1) |
                                   (data$valence_n == 0 & data$ACC_n == 0 & data$outcome_n == 0), 0,
                                   NA))
  data$validity_f <- factor(data$validity_n, levels = c(1, 0), labels = c("valid", "invalid"))
  # data[1:40, c("valence_n", "ACC_n", "validity_n", "outcome_n")]
  
  # -------------------------------------------------------------------------- #
  ## Trial-number within block, cue repetition:
  
  data <- add_cueRep(data)
  data$cueRep_f <- factor(data$cueRep_n)
  table(data$cue_n)
  table(data$cueRep_n)
  # table(data$subject_n, data$cueRep_n)
  # subData <- subset(data, subject_n == 93)
  # subData <- subset(data, subject_n == 154)
  # table(subData$cue_n)
  # table(subData$stim_ID)
  
  ## Add factors:
  data$trialnr_block_f <- factor(data$trialnr_block_n)
  
  data$response_last_f <- factor(data$response_last_n, levels = c(1, 0), labels = c("Go", "NoGo"))
  data$response_last_short_f <- data$response_last_f
  
  data$outcome_last_f <- factor(data$outcome_last_n, levels = c(1, 0, -1), labels = c("reward", "neutral", "punishment"))
  data$outcome_last_short_f <- factor(data$outcome_last_n, levels = c(1, 0, -1), labels = c("rew", "neu", "pun"))
  # View(data[, c("Subject", "Block", "Trialnr", "trialnr_block_n", "Stimulus", "cue_block_n", "cueRep_n")])
  
  ## Relative outcomes last trial (positive/ negative):
  data$outcome_last_rel_n <- ifelse(data$outcome_last_n == 1 | data$outcome_last_n == 0 & data$valence_n == 0, 1,
                               ifelse(data$outcome_last_n == -1 | data$outcome_last_n == 0 & data$valence_n == 1, 0, 
                                      NA))
  data$outcome_last_rel_f <- factor(data$outcome_last_rel_n, levels = c(1, 0), labels = c("positive", "negative"))
  data$outcome_last_rel_short_f <- factor(data$outcome_last_rel_n, levels = c(1, 0), labels = c("pos", "neg"))

  data$outcome_last_all_n <- ifelse(data$outcome_last_n == 1, 1, # reward
                                    ifelse(data$outcome_last_n == 0 & data$valence_n == 1, 2, # no reward
                                           ifelse(data$outcome_last_n == 0 & data$valence_n == 0, 3, # no punishment
                                                  ifelse(data$outcome_last_n == -1, 4, 
                                                         NA))))
  data$outcome_last_all_f <- factor(data$outcome_last_all_n, levels = 1:4, labels = c("rewarded", "not rewarded", "not punished", "punished"))
  data$outcome_last_all_short_f <- factor(data$outcome_last_all_n, levels = 1:4, labels = c("rew", "¬rew", "¬pun", "pun"))
  
  ## Last outcome & responses:
  data$outcome_last_response_last_n <- NA
  data$outcome_last_response_last_n[data$outcome_last_all_f == "rewarded" & data$response_last_f == "Go"] <- 1
  data$outcome_last_response_last_n[data$outcome_last_all_f == "punished" & data$response_last_f == "NoGo"] <- 2
  data$outcome_last_response_last_f <- factor(data$outcome_last_response_last_n, levels = c(1, 2), labels = c("rew. Go", "pun. NoGo"))
  
  data$salience_last_n <- ifelse(data$outcome_last_all_n %in% c(1, 4), 1, 0)
  data$salience_last_f <- factor(data$salience_last_n, levels = c(1, 0), labels = c("salient", "neutral"))
  data$salience_last_short_f <- factor(data$salience_last_n, levels = c(1, 0), labels = c("sal", "neu"))
  
   ## Half of task:
  data$firstHalfTask_n <- ifelse(data$trialnr_n <= nTrial/2, 1, 0)
  data$firstHalfTask_f <- factor(data$firstHalfTask_n, levels = c(1, 0), labels = c("first", "second"))
  # table(data$firstHalfTask_n)
 
  ## Half of blocks:
  data$firstHalfBlock_n <- ifelse(data$trialnr_block_n <= nTrialBlock/2, 1, 0)
  data$firstHalfBlock_f <- factor(data$firstHalfBlock_n, levels = c(1, 0), labels = c("first", "second"))
  # table(data$firstHalfBlock_n)
  
  ## Half of cue repetitions:
  data$firstHalfCueRep_n <- ifelse(data$cueRep_n <= 10, 1, 0)
  data$firstHalfCueRep_f <- factor(data$firstHalfCueRep_n, levels = c(1, 0), labels = c("first", "second"))
  # table(data$firstHalfCueRep_n)
  
  # -------------------------------------------------------------------------- #
  ## Response last trial:
  
  cat("Create response last trial\n")
  
  data <- add_lag(data, "response_n")
  data$response_lag1_f <- factor(data$response_lag1_n, levels = c(1, 0), labels = c("Go", "NoGo"))
  # data[, c("trialnr_block_n", "response_n", "response_lag1_n")]

  # -------------------------------------------------------------------------- #
  ## Repeat/switch:
  
  cat("Create repeat/ switch variable\n")
  
  data$repeat_n <- ifelse(data$response_n == data$response_last_n, 1, 
                          ifelse(data$response_n != data$response_last_n, 0, NA))
  data$repeat_f <- factor(data$repeat_n, levels = c(1, 0), labels = c("repeat", "switch"))
  data$repeat_short_f <- factor(data$repeat_n, levels = c(1, 0), labels = c("repeat", "switch"))
  
  ## Per response:
  data$repeat_response_n <- (1 - data$repeat_n) * 2 + (1 - data$response_n) + 1
  data$repeat_response_f <- factor(data$repeat_response_n, levels = c(1:4), labels = c("repGo", "repNoGo", "swiGo", "swiNoGo"))
  # data[1:20, c("repeat_f", "response_f", "repeat_response_f")]
  
  ## Per valence:
  data$repeat_valence_n <- (1 - data$repeat_n) * 2 + (1 - data$valence_n) + 1
  data$repeat_valence_f <- factor(data$repeat_valence_n, levels = c(1:4), labels = c("rep2W", "rep2A", "swi2W", "swi2A"))
  # data[1:20, c("repeat_f", "valence_f", "repeat_valence_f")]
  
  data$repeat_valence_Go_n <- ifelse(data$response_f == "Go", data$repeat_valence_n, NA)
  data$repeat_valence_Go_f <- factor(data$repeat_valence_Go_n, levels = c(1:4), labels = c("rep2W", "rep2A", "swi2W", "swi2A"))
  # data[1:20, c("repeat_f", "valence_f", "response_f", "repeat_valence_Go_f")]
  
  # -------------------------------------------------------------------------- #
  ## Outcome last trial:
  
  cat("Create outcome last trial\n")
  
  data <- add_lag(data, "outcome_n")
  data$outcome_lag1_f <- factor(data$outcome_lag1_n, levels = c(1, 0), labels = c("reward", "punishment"))
  data$outcome_lag1_short_f <- factor(data$outcome_lag1_n, levels = c(1, 0), labels = c("rew", "pun"))
  # data[, c("trialnr_block_n", "outcome_n", "outcome_lag1_n")]
  
  # -------------------------------------------------------------------------- #
  ## Remove old variables:
  data <- data[, (nVar + 1):ncol(data)]
  # head(data)
  
  cat("Finished! :-)\n")
  return(data)
}

# ============================================================================ #
#### 04) Retrieve default values for plots: #####

retrieve_plot_defaults <- function(input){
  #' Retrieve default for given plotting parameter.
  #' @param input scalar string, name of parameter for which to set default.
  #' @return scalar numeric, default value of that parameter
  # retrieve_plot_defaults("FTS")
  
  if (input == "FTS"){
    output <- 28
  } else if (input == "LWD"){
    output <- 1.5
  } else if (input == "dotSize"){
    output <- 0.5
  } else if (input == "dodgeVal"){
    output <- 0.6
  } else {
    stop("Unknown input to function retrieve_plot_defaults()")
  }
  
  return(output)
}

# ============================================================================ #
#### 05) Automatically convert variable names to pretty names for plots: #####

substitute_label <- function(labels){
  #' Substitute certain manually defined factor names for prettier names.
  #' @param labels vector of strings with names of factors in model.
  #' @return same vector with certain strings substituted.
  
  for (iItem in 1:length(labels)){
    
    cat(paste0("Automatically substitute factor labels for ", labels[iItem], " according to manual mapping\n"))
    
    labels[iItem] <- gsub("(Intercept)", "Intercept", labels[iItem])
    labels[iItem] <- gsub("X.Intercept.", "Intercept", labels[iItem])
    
    #### Indices:
    labels[iItem] <- gsub("subject_n", "Subject", labels[iItem])
    labels[iItem] <- gsub("subject_f", "Subject", labels[iItem])

    labels[iItem] <- gsub("trialnr_block_n", "Trial number within block", labels[iItem])
    labels[iItem] <- gsub("trialnr_block_f", "Trial number within block", labels[iItem])

    labels[iItem] <- gsub("trialnr_n", "Trial number", labels[iItem])
    labels[iItem] <- gsub("trialnr_f", "Trial number", labels[iItem])
    
    labels[iItem] <- gsub("block_n", "Block number", labels[iItem])
    labels[iItem] <- gsub("block_f", "Block number", labels[iItem])
    
    labels[iItem] <- gsub("cueRep_n", "Cue repetition", labels[iItem])
    labels[iItem] <- gsub("cueRep_f", "Cue repetition", labels[iItem])
    
    labels[iItem] <- gsub("outcome_last_response_last_f", "Biased learning conditions", labels[iItem])
    
    ### Stimuli:
    labels[iItem] <- gsub("valence_n", "Valence", labels[iItem])
    labels[iItem] <- gsub("valence_f", "Valence", labels[iItem])
    labels[iItem] <- gsub("valence_first5_f", "Valence", labels[iItem])
    labels[iItem] <- gsub("valence_short_f", "Val.", labels[iItem])
    
    labels[iItem] <- gsub("reqAction_n", "Req. action", labels[iItem])
    labels[iItem] <- gsub("reqAction_f", "Req. action", labels[iItem])
    labels[iItem] <- gsub("reqAction_short_f", "Req. act.", labels[iItem])

    labels[iItem] <- gsub("arousal_n", "Prime", labels[iItem])
    labels[iItem] <- gsub("arousal_f", "Prime", labels[iItem])

    labels[iItem] <- gsub("emotion_n", "Emotion", labels[iItem])
    labels[iItem] <- gsub("emotion_f", "Emotion", labels[iItem])
    
    labels[iItem] <- gsub("reqCongruency_n", "Congruency", labels[iItem])
    labels[iItem] <- gsub("reqCongruency_f", "Congruency", labels[iItem])
    labels[iItem] <- gsub("reqCongruency_short1_f", "Congruency", labels[iItem])
    labels[iItem] <- gsub("reqCongruency_short2_f", "Cong.", labels[iItem])
    
    labels[iItem] <- gsub("actCongruency_n", "Congruency", labels[iItem])
    labels[iItem] <- gsub("actCongruency_f", "Congruency", labels[iItem])
    labels[iItem] <- gsub("actCongruency_short_f", "Cong.", labels[iItem])

    labels[iItem] <- gsub("condition_n", "Cue condition", labels[iItem])
    labels[iItem] <- gsub("condition_f", "Cue condition", labels[iItem])
    labels[iItem] <- gsub("condition_short1_f", "Cue condition", labels[iItem])
    labels[iItem] <- gsub("condition_short2_f", "Cue \ncond.", labels[iItem])

    labels[iItem] <- gsub("respCond_n", "Response condition", labels[iItem])
    labels[iItem] <- gsub("respCond_f", "Response condition", labels[iItem])
    labels[iItem] <- gsub("respCond_short1_f", "Response condition", labels[iItem])
    labels[iItem] <- gsub("respCond_short2_f", "Resp. \ncond.", labels[iItem])
    
    ### Responses:
    labels[iItem] <- gsub("response_last_f", "Last response", labels[iItem])
    labels[iItem] <- gsub("response_last_short_f", "Last resp.", labels[iItem])
    
    labels[iItem] <- gsub("response_n", "p(Go)", labels[iItem])
    labels[iItem] <- gsub("response_f", "Response", labels[iItem])
    
    labels[iItem] <- gsub("ACC_n", "p(correct)", labels[iItem])
    labels[iItem] <- gsub("ACC_f", "Accuracy", labels[iItem])
    labels[iItem] <- gsub("ACC_short_f", "Acc.", labels[iItem])
    labels[iItem] <- gsub("ACC_valence_f", "ACC x valence", labels[iItem])
    labels[iItem] <- gsub("ACC_valence_Go_f", "ACC x valence (Go)", labels[iItem])
    
    labels[iItem] <- gsub("repeat_n", "p(repeat last response)", labels[iItem])
    labels[iItem] <- gsub("repeat_f", "Response rep.", labels[iItem])
    labels[iItem] <- gsub("repeat_short_f", "Resp. rep.", labels[iItem])

    labels[iItem] <- gsub("RT_n", "RT (in sec.)", labels[iItem])
    labels[iItem] <- gsub("RTcleaned_n", "RT (in sec.)", labels[iItem])
    labels[iItem] <- gsub("RTcleaned_z", "RT (z)", labels[iItem])
    labels[iItem] <- gsub("RTcleaned_fast_f", "RT", labels[iItem])
    labels[iItem] <- gsub("RTcleaned_valence_f", "RT x valence", labels[iItem])
    labels[iItem] <- gsub("RTcleaned_valence_uncor_f", "RT x valence", labels[iItem])
    labels[iItem] <- gsub("RTcleaned_ACC_f", "RT x ACC", labels[iItem])
    
    labels[iItem] <- gsub("RT_ms_n", "RT (in ms)", labels[iItem])
    labels[iItem] <- gsub("RT_log_n", "RT (log(sec.))", labels[iItem])
    labels[iItem] <- gsub("RT_ms_log_n", "RT (log(ms))", labels[iItem])
    
    ### Outcome:
    labels[iItem] <- gsub("outcome_n", "Outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_f", "Outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_short_f", "Outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_rel_f", "Outcome valence", labels[iItem])
    labels[iItem] <- gsub("outcome_rel_short_f", "Out. val.", labels[iItem])
    labels[iItem] <- gsub("outcome_all_f", "Outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_all_short_f", "Outcome", labels[iItem])
    
    labels[iItem] <- gsub("outcome_lag1_n", "Previous outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_lag1_f", "Previous outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_lag1_short_f", "Prev. out.", labels[iItem])
    
    labels[iItem] <- gsub("outcome_last_n", "Previous outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_last_f", "Previous outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_last_short_f", "Prev. out.", labels[iItem])
    labels[iItem] <- gsub("outcome_last_rel_n", "Previous outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_last_rel_f", "Previous outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_last_rel_short_f", "Prev. out.", labels[iItem])
    labels[iItem] <- gsub("outcome_last_all_f", "Previous outcome", labels[iItem])
    labels[iItem] <- gsub("outcome_last_all_short_f", "Prev. out.", labels[iItem])
    
    ### Outcome:
    labels[iItem] <- gsub("sonication_f", "Sonication", labels[iItem])
    labels[iItem] <- gsub("sonication_short_f", "Son.", labels[iItem])
    
    
    ## General replacements:
    labels[iItem] <- gsub("1", "", labels[iItem])
    labels[iItem] <- gsub(":", "\nx ", labels[iItem])
    
  }
  
  return(labels)
  
}

# ============================================================================ #
#### 06) Retrieve colour given independent variable: #####

retrieve_colour <- function(input){
  #' Retrieve colour scheme given variable name (pattern) as input.
  #' If none found, then use colorbrewer to create unidimensional YlOrRd color scheme,
  #' which is repeated as necessary to achieve number of required levels.
  #' Check for color-blindness friendliness: https://www.color-blindness.com/coblis-color-blindness-simulator/
  #' Search for neighboring colors: https://www.rapidtables.com/web/color/RGB_Color.html
  #' @param input scalar string, pattern within variable name to match to colour scheme.
  #' @return output vector of strings, colours to use.
  
  if (input == "all_f"){ 
    output <- c("black")
  } else if (grepl("reqAction", input, fixed = TRUE)){ 
    output <- c("#B2182B", "#2166AC")
  } else if (grepl("goValence", input, fixed = TRUE)){ 
    output <- c("#76F013", "#ED462F") # old rich/poor colors
    output <- c("#007174", "#FF654E") # checked for red/green-friendliness
  } else if (grepl("condition", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness
  } else if (grepl("respCond", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness
  } else if (grepl("RTcleaned_valence_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness
  } else if (grepl("RTcleaned_valence_uncor_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness
  } else if (grepl("RTcleaned_ACC_uncor_f", input, fixed = TRUE)){ 
    output <- c("#961F1F", "#F19425", "#961F1F", "#F19425") # dark red/ light red from MetBrewer: Peru2(6)
  } else if (grepl("RTcleaned_ACC_f", input, fixed = TRUE)){ 
    output <- c("#961F1F", "#F19425", "#961F1F", "#F19425") # dark red/ light red from MetBrewer: Peru2(6)
  } else if (grepl("valence", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E") # checked for red/green-friendliness
  } else if (grepl("reqCongruency", input, fixed = TRUE)){ 
    output <- c("#4DAC26", "#D01C8B")
  } else if (grepl("actCongruency", input, fixed = TRUE)){ 
    output <- c("#4D9221", "#C51B7D")
  } else if (grepl("arousal", input, fixed = TRUE)){ 
    output <- c("#9A133D", "#F9B4C9")
  } else if (grepl("emotion", input, fixed = TRUE)){ 
    output <- c("#9A133D", "#F9B4C9")
  } else  if (input == "response_last_short_f"){ 
    output <- c("#B2182B", "#2166AC")
  } else  if (input == "response_last_f"){ 
    output <- c("#B2182B", "#2166AC")
  } else  if (input == "response_f"){ 
    output <- c("#B2182B", "#2166AC")
  } else if (grepl("ACC_f", input, fixed = TRUE)){ 
    output <- c("#961F1F", "#F19425") # dark red/ light red from MetBrewer: Peru2(6)
  } else if (grepl("ACC_short_f", input, fixed = TRUE)){ 
    output <- c("#961F1F", "#F19425") # dark red/ light red from MetBrewer: Peru2(6)
  } else if (grepl("ACC_response_f", input, fixed = TRUE)){ 
    output <- c("#961F1F", "#961F1F", "#F19425", "#F19425") # dark red/ light red from MetBrewer: Peru2(6)
  } else if (grepl("ACC_valence_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness
  } else if (grepl("ACC_valence_Go_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness    
  } else  if (input == "repeat_f"){ 
    output <- c("#453D8D", "#B0B0FF") # dark violett/ light violett from MetBrewer: Redon(12) #59385C #A1A1FF #AB84A5
  } else  if (grepl("repeat_response_f", input, fixed = TRUE)){ 
    output <- c("#453D8D", "#453D8D", "#B0B0FF", "#B0B0FF") # dark blue/ light blue from MetBrewer: Manet(11) #7EC5F4 #8CC8BC
  } else  if (grepl("repeat_valence_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness
  } else  if (grepl("repeat_valence_Go_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#FF654E", "#007174", "#FF654E") # checked for red/green-friendliness
  } else  if (grepl("RTcleaned", input, fixed = TRUE)){ 
    output <- c("#183571", "#7EC5F4") # dark blue/ light blue from MetBrewer: Manet(11) #7EC5F4 #8CC8BC
  } else  if (grepl("baseline", input, fixed = TRUE)){ 
    output <- c("darkturquoise")
  } else  if (grepl("dilation", input, fixed = TRUE)){ 
    output <- c("#845D29")    
  } else if (grepl("outcome_all_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#f0ae66", "#57c4ad", "#c93d21")
  } else if (grepl("outcome_all_short_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#f0ae66", "#57c4ad", "#c93d21")
  } else if (grepl("outcome_last_all_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#f0ae66", "#57c4ad", "#c93d21")
  } else if (grepl("outcome_last_all_short_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#f0ae66", "#57c4ad", "#c93d21")
  } else if (grepl("outcome_rel_f", input, fixed = TRUE)){ 
    output <- c("#009933", "#CC0000")
    
  } else if (grepl("outcome_last_response_last_f", input, fixed = TRUE)){ 
    output <- c("#007174", "#CC0000")
    
  } else if (grepl("outcome_last_rel_f", input, fixed = TRUE)){ 
    output <- c("#009933", "#CC0000")
  } else if (grepl("outcome_response_f", input, fixed = TRUE)){
    output <- c("#009933", "#009933", "grey", "grey", "#CC0000", "#CC0000")
  } else if (grepl("outcome", input, fixed = TRUE)){
    output <- c("#009933", "grey", "#CC0000")

  } else if (grepl("sonication", input, fixed = TRUE)){
    output <- c("grey90", "#D3436EFF", "#FEBA80FF") # sham, dACC, aIns

  } else {
    if (exists("plotData")){ # check if plotData exists
      
      cat("Could not find variable name, but found plotData, retrieve number of variable levels\n")
      
      if (any(grepl(input, names(plotData)))){
        
        cat(paste0("Retrieve variable \"", input, "\" from plotData\n"))
        
        if (is.numeric(plotData[, input])){ # check if input variable numeric
          
          output <- "black"
          
        } else { # if factor or character
          
          require(RColorBrewer)

          ## Count labels of variable:
          nLevel <- length(unique(plotData[, input]))
          cat(paste0("Found ", nLevel, " levels of variable ", input, " in plotData\n"))
          
          ## Retrieve number colours and repetitions:      
          cmap <- "YlOrRd"
          nColour <- min(nLevel, 9)
          nRep <- ceil(nLevel/9)
          cat(paste0("Retrieve ", nColour, " from colour map ", cmap, " from color brewer, repeat ", nRep, " times\n"))
          
          ## Create colour vector:
          output <- rep(brewer.pal(nColour, cmap), nRep)
          output <- output[1:nLevel]
          
        } # end if numeric
        
      }
      
    } else {
      
      output <- "black" # ggplot default blue: #619CFF
      cat(paste0("Cannot find plotData, return colour ", output, "\n"))
      
    } # end if plotData exists
      
  } # end loop over input
  
  cat(paste0("Retrieve colour scheme given variable name ", input, ": ", paste0(output, collapse = ", "), "\n"))
  return(output)
}

# ============================================================================ #
#### 07) Add cue repetition variable to behavioral data: ####

add_cueRep <- function(data){
  #' Add new variables representing 
  #' (a) trial number per block;
  #' (b) cue repetition within block;
  #' (c) response on last trial with same cue.
  #' (d) outcome on last trial with same cue.
  #' @param data      data frame with trial-level data.
  #' @return data     same data frame with extra variables added.

  cat(paste0("Add trial number within block\n"))
  cat(paste0("Add cue repetition\n"))
  cat(paste0("Add response from last trial with same cue\n"))
  cat(paste0("Add outcome from last trial with same cue\n"))
  
  ## General settings:
  splitVar <- "block_n"
  stimVar <- "cue_block_n"
  respVar <- "response_n"
  outVar <- "outcome_n"
  
  ## Initialize variables:
  data$trialnr_block_n <- NA
  data$cueRep_n <- NA
  data$response_last_n <- NA
  data$outcome_last_n <- NA
  
  # --------------------------------------------------------------------- #
  ## Initialize counts:
  
  trialCount <- 1
  nCue <- 4
  cueCount <- rep(0, nCue)
  lastResp <- rep(NA, nCue)
  lastOut <- rep(NA, nCue)
  
  # --------------------------------------------------------------------- #
  ## First row:
  
  data$trialnr_block_n[1] <- trialCount
  
  thisCue <- data[1, stimVar] # identify cue
  cueCount[thisCue] <- cueCount[thisCue] + 1 # update
  data$cueRep_n[1] <- cueCount[thisCue] # save
  
  data$response_last_n[1] <- lastResp[thisCue] # save
  lastResp[thisCue] <- data[1, respVar] # update
  
  data$outcomelast_n[1] <- lastOut[thisCue] # save
  lastOut[thisCue] <- data[1, outVar] # update
  
  # --------------------------------------------------------------------- #
  ## All other rows:
  for (iRow in 2:nrow(data)){
    
    ## If different block: reset
    if(data[iRow, splitVar] != data[iRow - 1, splitVar]){
      trialCount <- 0
      cueCount <- rep(0, nCue)
      lastResp <- rep(NA, nCue)
      lastOut <- rep(NA, nCue)
    }
    
    ## Increment trial:
    trialCount <- trialCount + 1 # increment
    
    ## Increment cue repetition:
    thisCue <- data[iRow, stimVar] # identify cue
    cueCount[thisCue] <- cueCount[thisCue] + 1 # update
    
    ## Save:
    data$trialnr_block_n[iRow] <- trialCount # save
    data$cueRep_n[iRow] <- cueCount[thisCue] # save
    data$response_last_n[iRow] <- lastResp[thisCue] # save
    data$outcome_last_n[iRow] <- lastOut[thisCue] # save
    
    ## Update response and outcome:
    lastResp[thisCue] <- data[iRow, respVar] # update
    lastOut[thisCue] <- data[iRow, outVar] # update
    
  }  # end iRow 
  
  return(data)
}

# data[1:20, c("subject_n", "trialnr_n", "cue_n", "cueRep_n")]
# data[data$subject_n == 1 & data$cue_n == 2, c("subject_n", "trialnr_n", "cue_n", "cueRep_n", "response_n", "response_last_n")]
# data[data$subject_n == 1 & data$cue_n == 1, c("subject_n", "trialnr_n", "cue_n", "cueRep_n", "outcome_n", "outcome_last_n")]

# ============================================================================ #
#### 08) Add lag 1 version of selected variable: ####

add_lag <- function(data, inputVar, nLag = 1){
  #' Overwrite reward lag 1 variable based on reward variable, delete after 
  #' choices and start of new round.
  #' @param data      data frame with trial-level data.
  #' @param inputVar  scalar string, name of variable to create lag for.
  #' @param nLag      scalar integer, lag to use (default: 1).
  #' @return data     same data frame with reward lag 1 variable corrected.
  
  # inputVar <- "outcome_n"; nLag = 1
  
  ## Variable to set new start of block:
  trialVar <- "trialnr_block_n"
  
  ## Create new variable name:
  outputVar <- inputVar
  outputVar <- gsub("_n", "", outputVar) # delete any trailing _n
  outputVar <- gsub("_f", "", outputVar) # delete any trailing _f
  outputVar <- gsub(" ", "", outputVar) # delete any spaces
  outputVar <- paste0(outputVar, "_lag", nLag)
  if (grepl("_n", inputVar, fixed = TRUE)){outputVar <- paste0(outputVar, "_n")}
  if (grepl("_f", inputVar, fixed = TRUE)){outputVar <- paste0(outputVar, "_f")}
  cat(paste0("Create new variable ", outputVar, "\n"))
  
  # -------------------------------------------------------------------------- #
  ## Copy over from reward variable:
  
  data[, outputVar] <- NA # create empty variable
  data[(1 + nLag):nrow(data), outputVar] <- data[1:(nrow(data) - nLag), inputVar] # copy over with lag
  # data[1:20, c(inputVar, outputVar)]
  
  # -------------------------------------------------------------------------- #
  ### Delete for first nLag trials of new block:
  
  data[data[, trialVar] <= nLag, outputVar] <- NA # delete after leave choices
  
  # -------------------------------------------------------------------------- #
  ### Convert back to factor:
  
  if (grepl("_f", inputVar, fixed = TRUE)){data[, outputVar] <- factor(data[, outputVar])}
  
  # -------------------------------------------------------------------------- #
  ### Final NA assessment:
  
  cat(paste0("New variable ", outputVar, " has ", 100*round(mean(is.na(data[, outputVar])), 2), "% NAs\n"))
  
  return(data)
  
}

# ============================================================================ #
#### 09) Select data, standardize variables: ####

select_standardize <- function(data, sub2excl = c()){
  #' Exclude subjects, standardize numerical variables of remaining data.
  #' @param data      data frame with trial-level data
  #' @param sub2excl  vector of integers, IDs of subjects to exclude (default: none).
  #' @return modData  data frame selected subjects removed and variables standardized. 

  # -------------------------------------------------------------------------- #
  ### Select data:
  
  if (length(sub2excl) == 0){
    cat("Retain data of all subjects\n")
  } else {
    cat(paste0("Select data, exclude subjects ", paste0(sub2excl, collapse = ", "), "\n"))
  }
  ## Select subject:
  modData <- subset(data, !(subject_n %in% sub2excl))
 
  # -------------------------------------------------------------------------- #
  ## Standardize variables:

  cat("Standardize relevant numeric variables ...\n")

  modData$trialnr_z <- as.numeric(scale(modData$trialnr_n))
  modData$trialnr_block_z <- as.numeric(scale(modData$trialnr_block_n))
  modData$cueRep_z <- as.numeric(scale(modData$cueRep_n))

  modData$RT_z <- as.numeric(scale(modData$RT_n))
  modData$RT_log_z <- as.numeric(scale(modData$RT_log_n))
  modData$RT_ms_log_z <- as.numeric(scale(modData$RT_ms_log_n))
  modData$RTcleaned_z <- as.numeric(scale(modData$RTcleaned_n))
  modData$RTcleaned_log_z <- as.numeric(scale(modData$RTcleaned_log_n))

  cat("Finished! :-)\n")

  return(modData)

}

# ============================================================================ #
#### 10) Recode formula in Wilkinson notation to handle that can be used for saving models as files: ####

formula2handle <- function(formula){
  #' Create name based on formula with underscores instead of spaces without random-effects part to be used in plot names.
  #' @param formula   string, formula in Wilkinson notation.
  #' @return handle   string, converted to be without spaces but with underscores, with random-effects part removed.
  require(stringr)
  
  cat(paste0("Input: ", formula, "\n"))
  # https://stackoverflow.com/questions/38291794/extract-string-before
  # https://statisticsglobe.com/extract-substring-before-or-after-pattern-in-r
  
  handle <- formula # copy over
  
  # ------------------------------------------------------------------------ #
  ## For survival models: delete Surv() surrounding:
  
  if (grepl("Surv\\(", handle)){
    
    handle <- sub(".*Surv\\(", "", handle) # delete everything up until Surv(
    handle <- sub("\\)", "", handle) # delete first )
  }
  
  # ------------------------------------------------------------------------ #
  ## Extract until random effects parentheses:
  
  handle  <- sub("\\(.*", "", handle) # delete everything after (
  
  # ------------------------------------------------------------------------ #
  ## Delete only very last (!) plus before random-effects part:
  # https://stackoverflow.com/questions/44687333/remove-characters-after-the-last-occurrence-of-a-specific-character
  # handle <- sub("+[^_]+$", "", handle)
  
  if(grepl( "+", str_sub(handle, -2, -1), fixed = T)){
    handle <- substring(handle, 1, nchar(handle) - 3)
    
  }
  
  ## Replace every * by x:
  handle <- gsub("\\*", "x", handle) # extract until last plus
  
  ## Substitute every space with underscore:
  handle <- gsub(" ", "_", handle)
  
  cat(paste0("Output: ", handle, "\n"))
  return(handle)
  
}

# ============================================================================ #
#### 11) Retrieve or fit & save linear mixed-effects model based on formula: ####

fit_lmem <- function(formula, useLRT = FALSE){
  #' Retrieve previously fitted model or fit model anew and save it.
  #' @param formula   string, formula in Wilkinson notation.
  #' @param useLRT    Boolean, compute p-values with LRTs using afex (TRUE) or not (FALSE; default).
  #' @return mod    fitted model object.

  require(lme4)
  require(afex)
  require(car)
  
  # ------------------------------------------------------------------------ #
  if (!exists("modData")){"modData does not exist"}

  # ------------------------------------------------------------------------ #
  ## Determine type of fitting:
  
  if (useLRT){
    fitType <- "LRT"
  } else {
    fitType <- "lme4"
  }
  
  # ------------------------------------------------------------------------ #
  ## Determine model family:
  
  DV <- sub("\\~.*", "", formula)
  if (grepl( "response", DV) | grepl( "ACC", DV) | grepl( "repeat", DV)){
    modFamily <- "binom"
  } else {
    modFamily <- "lin"
  } 
  
  ## Print specifics to console:
  cat(paste0("Fit model ", formula, " of family ", modFamily, " using ", fitType, "\n"))
  
  # ------------------------------------------------------------------------ #
  ## Determine model name:
  
  modName <- paste0(fitType, "_", modFamily, "_", formula2handle(formula), ".rds")
  
  # ------------------------------------------------------------------------ #
  ## Check if already exists; if yes, retrieve; if not, fit anew:
  
  if (file.exists(paste0(dirs$modelDir, modName))){
    
    cat(paste0(">>> Found ", modName, ", load \n"))
    mod <- readRDS(paste0(dirs$modelDir, modName))
    if (useLRT){
      print(anova(mod))
    } else {
      print(summary(mod))
      print(Anova(mod, type = "3")) # 1 p-value per factor
    }
    
  } else {
    
    # ---------------------------------------------------------------------- #
    ### Fit model:
    
    ## Start time:
    start.time <- Sys.time();
    cat(paste0(">>> Fit model with formula ", formula, "\n"))
    
    if (modFamily  == "binom"){ # if logistic regression
      if (useLRT){ # if LRT
        mod <- mixed(formula = formula, data = modData, method = "LRT", type = "III", family = binomial(), # all_fit = T,
                         control = glmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
      } else { # if lme4
        mod <- glmer(formula = formula, data = modData, family = binomial(),
                     control = glmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
      }
    } else { # if linear regression
      if (useLRT){ # if LRT
        mod <- mixed(formula = formula, data = modData, method = "LRT", type = "III", # all_fit = T,
                     control = lmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
      } else { # if lme4
        mod <- lmer(formula = formula, data = modData, 
                  control = lmerControl(optCtrl = list(maxfun = 1e+9), calc.derivs = F, optimizer = c("bobyqa")))
      }      
    }
    
    ## Stop time:
    end.time <- Sys.time(); beep()
    dif <- difftime(end.time,start.time); dif

    # ------------------------------------------------------------------------ #
    ### Print output:
    
    if (useLRT){
      print(anova(mod))
    } else {
      print(summary(mod))
      print(Anova(mod, type = "3")) # 1 p-value per factor
    }

    # ------------------------------------------------------------------------ #
    ### Save model:
    
    cat(paste0(">>> Save ", modName, "\n"))
    saveRDS(mod, paste0(dirs$modelDir, modName))
    cat(">>> Saved :-)\n")
    
  }
  
  return(mod)
  
}

# ============================================================================ #
#### 12) Determine y-axis limits: ####

determine_ylim_data_y <- function(data){
  #' Determine optimal y-axis limits based on some input heuristics
  #' @param data data frame, aggregated per subject, long format, with variable \code{y}
  #' @return yLim vector with to elements: minimal and maximal y-axis limit
  
  require(plyr)
  
  # Determine minimum and maximum:
  yMin <- min(data$y, na.rm = T)
  yMax <- max(data$y, na.rm = T)
  nRound <- 3
  cat(paste0("Detected yMin = ", round(yMin, nRound), ", yMax = ", round(yMax, nRound), "\n"))
  
  ## If binary input data:
  if(all(data$y[!is.nan(data$y)] %in% c(0, 1))){ 
    cat("Binary data, set y-axis limits to [0, 1]\n")
    yLim <- c(0, 1)
    
    ## if likely probability
  } else if (yMin >= 0 & yMax <= 1){ 
    cat("Set automatic yLim to [0, 1]\n")
    yLim <- c(0, 1)
    
    ## If positive number, but not huge:
  } else if(yMin >= 0 & yMax <= 10){ # if rather small positive number: plot from 0 onwards to 110% of yMax
    cat("Set automatic yLim to [0, round(yMax*1.1, 1)]\n")
    yLim <- c(0, round(yMax*1.1, 1))
    
    ## If positive number and huge:
  } else if ((yMin > 0) & (yMax > 100)) { # if very big number: plot from 0 onwards to next hundred
    cat("Set automatic yLim to [0, hundres]\n")
    yMin <- 0 # from zero onwards
    yMax <- round_any(yMax, 100, f = ceiling) # round up to next hundred
    yLim <- c(yMin, yMax)
    
    ## Else (if yMin negative): enforce symmetric yLim using the bigger of yMin and yMax
  } else { # take the numerically bigger one, symmetric
    cat("Set automatic yLim to be symmetric, use bigger of yMinAbs and yMaxAbs\n")
    yMaxAbs <- ceiling(c(abs(yMin), yMax)) # round to next integer
    yMaxAbs <- yMaxAbs[1] # only first entry
    yLim <- c(-1*yMaxAbs, 1*yMaxAbs)
  }
  
  ## Check if only 2 output elements:
  if (length(yLim) < 2){stop("yLim output has less than 2 elements, please check input\n")}
  if (length(yLim) > 2){stop("yLim output has more than 2 elements, please check input\n")}
  
  return(yLim)
} 

# ============================================================================ #
#### 13) Find plausible axis limits: #####

find_round_lim <- function(input){
  #' Round input xMin and xMax such that they become plausible axis limits 
  #' given their magnitude. 
  #' @param input vector of 2 numerics, axis limits.
  #' @return xStep scalar numeric, optimal step size
  
  # input
  signVec <- ifelse(input > 0, 1, -1)
  absVec <- abs(input)
  xUnit <- min(floor(log10(absVec))) # detect smaller of both magnitudes
  xScale <- 10^xUnit # scaling factor 
  output <- round(input/xScale)*xScale # scale up/down, round, scale down/up again
  
  while(output[1] == output[2]){
    xUnit <- xUnit - 1 # reduce unit 
    xScale <- 10^xUnit # scaling factor 
    output <- round(input/xScale)*xScale # scale up/down, round, scale down/up again
  }
  
  return(output)
}

# ============================================================================ #
#### 14) Find plausible tick step size given axis limits: #####

find_step <- function(input, nTickTarget = 5){
  #' Plot learning curve per cue per subject using basic plot() function 
  #' @param input vector of 2 numerics, axis limits.
  #' @param nTickTarget scalar integer, number of desired axis ticks (default: 5).
  #' @return step scalar numeric, optimal step size.
  
  # -------------------------------------------------------------------------- #
  ### Check inputs:
  
  if(!(is.numeric(input))){stop("input has to be numeric")}
  if(length(input) != 2){stop("xLim must have 2 elements")}
  if(input[2] < input[1]){stop("xMax must be larger than xMin")}
  if(length(nTickTarget) != 1){stop("nTickTarget must have 1 element")}
  if(nTickTarget != round(nTickTarget)){stop("nTickTarget must be an integer")}
  
  # -------------------------------------------------------------------------- #
  ### Compute ideal step size:
  
  ## Repertoire of possible ticks:
  expVec <- seq(-5, 5, 1) # exponents for candidate ticks
  tickVec <- sort(c(10^expVec, 5 * 10^expVec)) # candidate steps: either 1 or 5 of different magnitudes
  
  ## Find optimal step target:
  stepTarget <- (input[2] - input[1]) / nTickTarget # desired length step
  stepIdx <- which(abs(tickVec - stepTarget) == min(abs(tickVec - stepTarget))) # find minimum
  stepIdx <- stepIdx[1] # select first in case of multiple minima
  step <- tickVec[stepIdx] # extract optimal step
  
  ## Return:
  cat(paste0("Use step size ", step, " for axis ticks\n"))
  return(step)
  
}

# ============================================================================ #
#### 15) Plot group-level and subject-level coefficients as dots in horizontal dot-plot: #####

custom_coefplot <- function(mod, plotSub = TRUE, plotText = FALSE, dropIntercept = FALSE, revOrder = FALSE,
                            xLab = "Regression weight", yLab = "Predictor", main = NULL,
                            selCol = "blue", yLabels = NULL, xLim = NULL, FTS = NULL){
  #' Plot group-level  and subject-level coefficients as dots in horizontal dot-plot.
  #' @param mod model fitted with lme4.
  #' @param plotSub Boolean, whether to plot per-subject effects (TRUE) or not (FALSE; default: TRUE).
  #' @param plotText Boolean, whether to print value of group-level coefficient next to dot (TRUE) or not (FALSE; default: FALSE).
  #' @param dropIntercept Boolean, do not plot intercept (TRUE; default: false).
  #' @param revOrder Boolean, revert order of predictors (first one on top, TRUE) or not (last one on top FALSE) (default: false).
  #' @param xLab string, label for x-axis (default: "Regression weight").
  #' @param yLab string, label for y-axis (default: "Predictor").
  #' @param main string, title of plot (default: NULL).
  #' @param selCol strings (HEX colors), colors for group-level dots and error lines (default: "blue" for all).
  #' @param yLabels vector of strings, y-axis ticks (default: terms extracted from mod).
  #' @param xLim vector of two numerics, x-axis limits (optional).
  #' @param FTS scalar integer, font size (optional; default: NULL).
  #' @return coefplot created with ggplot.
  
  # -------------------------------------------------------------------------- #
  ## Required packages:
  
  require(ggplot2)
  require(lme4)
  require(arm) # for se.fixef
  
  # -------------------------------------------------------------------------- #
  ## Close any open plots:
  
  if (length(dev.list()!=0)){dev.off()}
  
  # -------------------------------------------------------------------------- #
  ## Fixed settings:
  
  SEweight <- 1.96 # width of whiskers (1.96 for two-sided 95%-CI)
  groupDotSize <- 5 # size of fixed-effects dot; used to be 5
  subDisplacement <- -0.20 # systematic vertical displacement of per-subject dots
  subJitter <- 0.05 # amount of jitter added to per-subject dots; used to be 0.07
  textOffset <- 0.35 # vertical upwards displacement of text; used to be 0.3
  lineWidth <- retrieve_plot_defaults("LWD") # linewidth of axes
  if(is.null(FTS)){
    FTS <- retrieve_plot_defaults("FTS") # font size for all text: 30 or 15 
  }
  colAlpha <- 0.6 # transparency of per-subject dots
  nRound <- 3 # how much to round plotted text.
  
  # -------------------------------------------------------------------------- #
  ## Extract group-level information from input:
  
  ## a) If mixed effects model: 
  modClass <- class(mod)
  if(modClass %in% c("glmerMod", "lmerMod", "lmerTest", "lmerModLmerTest")){ # from lme4
    
    # Extract fixed effect:
    meanVec <- as.numeric(fixef(mod))
    seVec <- se.fixef(mod)
    
    if (is.null(yLabels)){ # if not provided
      labelsVec <- colnames(mod@pp$X)
      labelsVec <- substitute_label(labelsVec) # translate labels
    } else { # if provided
      labelsVec <- yLabels
    }
    
    ## Concatenate group-level values to data frame:
    groupCoefs <- data.frame(labelsVec, meanVec, seVec)
    names(groupCoefs) <- c("label", "mean", "se")
    
    ## Subject-level coefficients:
    subCoefs <- coef(mod)[[1]]
    nSub <- nrow(subCoefs)
    
    ## b) If flat regression:
  } else if (is.list(mod) & "bMat" %in% names(mod)) {
    
    # Compute mean and SD of per-subject coefficients:
    meanVec <- colMeans(mod$bMat, na.rm = T)
    nSub <- nrow(mod$bMat)
    seVec <- as.numeric(sapply(data.frame(mod$bMat), sd, na.rm = T))/sqrt(nSub)
    
    if (is.null(yLabels)){ # if not provided
      labelsVec <- names(coef(mod$modList[[1]]))
      labelsVec <- substitute_label(labelsVec) # translate labels
    } else { # if provided
      labelsVec <- yLabels
    }
    
    ## Concatenate group-level values to data frame:
    groupCoefs <- data.frame(labelsVec, meanVec, seVec)
    names(groupCoefs) <- c("label", "mean", "se")
    
    ## Subject-level coefficients:
    subCoefs <- data.frame(mod$bMat)
    names(subCoefs) <- names(coef(mod$modList[[1]])) # copy over regressor names
    nSub <- nrow(subCoefs)
    
  } else {
    stop("Unknown input")
  }
  
  ## Text labels with significance stars based on z-values:
  # (1 - pnorm(1.64))*2
  # (1 - pt(1.96, df = 1000))*2
  # nRound <- 3
  ## Compute absolute z-value for determining significance:
  groupCoefs$z <- abs(groupCoefs$mean / groupCoefs$se) # z-value to evaluate significance
  ## Compute textual label:
  groupCoefs$zLabel <- as.character(round(groupCoefs$mean, nRound)) # copy over, to string
  ## Pad to desired string length:
  groupCoefs$zLabel <- ifelse(groupCoefs$mean > 0, str_pad(groupCoefs$zLabel, width = nRound + 2, pad = "0", side = "right"), groupCoefs$zLabel) # pad to nRound digits after comma
  groupCoefs$zLabel <- ifelse(groupCoefs$mean < 0, str_pad(groupCoefs$zLabel, width = nRound + 3, pad = "0", side = "right"), groupCoefs$zLabel) # pad to nRound digits after comma
  ## Handle cases of zero (no dot):
  groupCoefs$zLabel <- ifelse(!grepl("\\.", groupCoefs$zLabel), paste0("0.", paste0(rep("0", nRound), collapse = "")), groupCoefs$zLabel)
  ## Add stars and crosses for significance: 
  groupCoefs$zLabel <- ifelse(groupCoefs$z > 1.64 & groupCoefs$z < 1.96, paste0(groupCoefs$zLabel, "\U207A"), groupCoefs$zLabel) # latin cross
  groupCoefs$zLabel <- ifelse(groupCoefs$z > 1.96, paste0(groupCoefs$zLabel, "*"), groupCoefs$zLabel)
  groupCoefs$zLabel <- ifelse(groupCoefs$z > 3, paste0(groupCoefs$zLabel, "*"), groupCoefs$zLabel)
  
  # Alternatives to cross for marginally significant effects:
  # https://unicode-table.com/en/sets/crosses/
  # for (iLabel in 1:nrow(groupCoefs)){
  #   if (groupCoefs$z[iLabel] > 1.64 & groupCoefs$z[iLabel] < 1.96){
  #     groupCoefs$zLabel[iLabel] <- expression(paste(eval(groupCoefs$zLabel[iLabel]), "^+"))
  #     # groupCoefs$zLabel[iLabel] <- substitute(expression(n "^+"), list(n = groupCoefs$zLabel[iLabel]))
  #     # groupCoefs$zLabel[iLabel] <- bquote(.(groupCoefs$zLabel[iLabel])^+)
  #   }
  # } 
  
  # substitute(expression(a + b), list(a = groupCoefs$zLabel[iLabel]))
  # substitute(expression(a ^+), list(a = groupCoefs$zLabel[iLabel]))
  
  # groupCoefs$zLabel <- ifelse(groupCoefs$z > 1.64 & groupCoefs$z < 1.96, expression(paste0(groupCoefs$zLabel, "^+")), groupCoefs$zLabel) # latin cross
  # groupCoefs$zLabel <- ifelse(groupCoefs$z > 1.64 & groupCoefs$z < 1.96, paste0(groupCoefs$zLabel, "\U2670"), groupCoefs$zLabel) # latin cross
  # groupCoefs$zLabel <- ifelse(groupCoefs$z > 1.64 & groupCoefs$z < 1.96, paste0(groupCoefs$zLabel, "\U207A"), groupCoefs$zLabel) # superscript + (rather small)
  
  ## Drop intercept or not:
  if(dropIntercept){
    groupCoefs <- groupCoefs[2:nrow(groupCoefs), ] 
    # labels <- labels[2:length(labels)]
  }
  
  ## Determine final number of effects:
  nEff <- nrow(groupCoefs)
  txtFTS <- FTS # for axis labels and regression weights
  if (nEff > 5){txtFTS <- FTS * 0.75}
  
  ## Adjust number of colors:
  if (length(selCol) > nEff){selCol <-  selCol[1:nEff]} # if too many colors: only use first
  selCol <- rep(selCol, length.out = nEff) # if too few colors: repeat until enough
  # selCol <- rev(COL2("RdBu", nEff))
  
  ## Reverse order (first regressor will be plotted on top):
  if (revOrder){
    groupCoefs <- groupCoefs[nrow(groupCoefs):1,]
    selCol <- rev(selCol)
  }
  
  ## Compute index and lower/upper confidence bound:
  groupCoefs$idx <- seq(1, nrow(groupCoefs), 1) # numerical index of each effect to loop through (in correct order)
  groupCoefs$lower <- groupCoefs$mean - groupCoefs$se * SEweight
  groupCoefs$upper <- groupCoefs$mean + groupCoefs$se * SEweight
  
  # -------------------------------------------------------------------------- #
  ## Group-level plot:
  
  p <- ggplot(groupCoefs, aes(x = mean, y = label)) # define ggplot and axed
  
  ## A) Add error bar lines:
  cat("Plot error bar whiskers\n")
  for (iEff in 1:nEff){ # iEff <- 1
    ## For this effect: extract index, upper and lower end of whisker
    effData <- data.frame(x = c(groupCoefs$lower[iEff], groupCoefs$upper[iEff]),
                          y = rep(groupCoefs$idx[iEff], 2))
    p <- p + geom_line(data = effData, aes(x = x, y = y), size = 1.2, color = selCol[iEff])
  }
  
  # -------------------------------------------------------------------------- #
  ## B) Add fixed-effects points:
  
  cat("Plot fixed-effect coefficients\n")
  p <- p + geom_point(aes(x = mean, y = idx, color = factor(idx)), size = groupDotSize) +  # points for point estimates; size = 5
    scale_color_manual(values = selCol)
  
  # -------------------------------------------------------------------------- #
  ## C) Add subject-level points:
  
  ## Drop intercept or not (do outside plotSub for xLim determination):
  if(dropIntercept){
    subCoefs <- subCoefs[, 2:ncol(subCoefs)] 
    # labels <- labels[2:length(labels)]
  }
  if (is.vector(subCoefs)){subCoefs <- data.frame(subCoefs)} # ensure it has a column dimension
  
  ## Reverse order (first regressor will be plotted on top):
  if (revOrder){
    subCoefs <- subCoefs[, ncol(subCoefs):1]
  }
  if (is.vector(subCoefs)){subCoefs <- data.frame(subCoefs)} # ensure it has a column dimension
  
  if (plotSub){
    
    cat("Plot effect per subject\n")
    for (iEff in 1:nEff){ # iEff <- 1
      ## For this effect: extract and plot effects per subject
      effData <- data.frame(x = subCoefs[, iEff], # per-subject effect
                            y = rep(groupCoefs$idx[iEff], nSub) + subDisplacement) # y-axis position
      effData$y <- jitter(effData$y, amount = subJitter) # add jitter to distinuish subjects
      p <- p + geom_point(data = effData, aes(x = x, y = y), size = 2, 
                          # shape = 16, color = "gray30", # all grey
                          # shape = 21, color = "black", fill = "gray70", stroke = 1.2, # black edge, white fill
                          shape = 1, color = "black", # or color = selCol[iEff],
                          alpha = colAlpha)
    }  
    
  }
  
  # -------------------------------------------------------------------------- #
  ## Determine x-axis dimensions for scaling:
  
  ## Extract range of subject-level effects for axis limits:
  if (!is.null(xLim)){ # if provided: retrieve from input
    xMin <- xLim[1]
    xMax <- xLim[2]
  } else { # else determine empirically based on subject coefficients
    ## Extract:
    if (plotSub){
      xMin <- min(subCoefs, na.rm = T)
      xMax <- max(subCoefs, na.rm = T)
    } else {
      xMin <- min(groupCoefs$lower, na.rm = T)
      xMax <- max(groupCoefs$upper, na.rm = T)
    }
    ## Erode a bit (need 10% for printing text for most positive coefficient):
    if(xMin > 0){xMin <- xMin * 0.90} else (xMin <- xMin * 1.10)
    if(xMax > 0){xMax <- xMax * 1.10} else (xMax <- xMax * 0.90)
    ## Assign:
    xLim <- c(xMin, xMax)
  }
  
  # -------------------------------------------------------------------------- #
  ## D) Add group-level coefficient as text:
  
  if (plotText){
    textDisplacement <- (xMax - xMin) * 0.10 # 10% of x-axis width
    cat("Print values of group-level effects as text\n")
    p <- p + geom_text(data = groupCoefs, aes(x = mean, y = idx, label = zLabel),  
                       nudge_x = textDisplacement, nudge_y = textOffset, na.rm = T, check_overlap = T, size = txtFTS/3) # nudge_x = 0.20
  }
  
  # -------------------------------------------------------------------------- #
  ### Other settings:
  
  ## Horizontal line at x = 0:  
  p <- p + geom_vline(xintercept = 0, 
                      linetype = "dashed", colour = "#949494", lwd = 1) # line at zero
  
  # -------------------------------------------------------------------------- #
  ## X-axis ticks:
  
  # xMin = -0.049; xMax = 0.459
  cat(paste0("xMin = ", round(xMin, 3), "; xMax = ", round(xMax, 3), "\n"))
  xRange <- xMax - xMin # determine range
  
  ## If symmetric: 5 symmetric break points
  if (abs(xMin) == abs(xMax)){
    
    breakVec <- sort(c(xMin, (xMin + mean(xLim))/2, mean(xLim), (mean(xLim) + xMax)/2, xMax)) # extremes and middle between extreme and center
    breakVec <- round(breakVec, 2) # round to 2 decimals
    
    ## else: determine adaptively:
  } else {
    
    ## Determine x-axis lower limit:
    iMag <- log10(abs(xMin)) # determine order of magnitude for rounding
    iMag <- ifelse(iMag < 0, floor(iMag), ceil(iMag)) # round
    xUnit <- 10 ^ iMag
    xBreakMin <- floor(xMin/xUnit)*xUnit # remove post-digit part, round, transform back
    
    ## Determine x-axis upper limit:
    iMag <- log10(abs(xMax)) # determine order of magnitude for rounding
    iMag <- ifelse(iMag < 0, floor(iMag), ceil(iMag)) # round
    xUnit <- 10 ^ iMag
    xBreakMax <- ceiling(xMax/xUnit)*xUnit # remove post-digit part, round, transform back
    
    ## xStep either 1 or 5; try out both:
    expVec <- seq(-3, 3, 1) # exponents for candidate ticks
    xTickVec <- sort(c(10^expVec, 5 * 10^expVec)) # candidate xSteps: either 1 or 5 of different magnitudes
    nTickTarget <- 4 # number desired ticks on x-axis
    xStepTarget <- (xBreakMax - xBreakMin) / nTickTarget # desired length xStep
    xStepIdx <- which(abs(xTickVec - xStepTarget) == min(abs(xTickVec - xStepTarget))) # find minimum
    xStepIdx <- xStepIdx[1] # first in case of multiple minima
    xStep <- xTickVec[xStepIdx] # extract optimal xStep
    
    ## Correct if one limit smaller than xStep:
    if (abs(xBreakMin) < xStep){xBreakMin <- 0}
    if (abs(xBreakMax) < xStep){xBreakMax <- 0}
    
    cat(paste0("xBreakMin = ", xBreakMin, ", xBreakMax = ", xBreakMax, ", xStep = ", xStep, "\n"))
    
    ## Distance between x-axis ticks:
    breakVec <- seq(xBreakMin, xBreakMax, xStep) # just very broad break points, aligned to magnitude
    
  }
  
  ## Axes:
  p <- p + coord_cartesian(xlim = xLim) # set x limits
  p <- p + scale_x_continuous(breaks = breakVec)
  p <- p + scale_y_continuous(breaks = 1:nEff, labels = groupCoefs$label)
  
  ## Labels:
  p <- p + labs(x = xLab,
                y = yLab)
  
  ## Add title:
  if (!(is.null(main))){
    p <- p + ggtitle(main)  
  }
  
  ## Theme:
  p <- p + theme_classic() # base_size = 14
  
  ## Font sizes:
  p <- p + theme(axis.text.x = element_text(colour = "black", size = FTS),
                 axis.text.y = element_text(colour = "black", size = txtFTS),
                 axis.line = element_line(colour = "black"), # , linewidth = LWD), # fixed font sizes
                 axis.title = element_text(colour = "black", size = FTS), 
                 plot.title = element_text(colour = "black", size = FTS, hjust = 0.5), # center title 
                 legend.position = "none")
  
  print(p)
  cat("Finished :-)\n")
  
  return(p)
  
}

# ============================================================================ #
#### 16) Plot intercorrelations of regressors in design matrix: #####

corrplot_regressors <- function(mod, perSub = F, varNames = NULL, savePNG = TRUE){
  #' Plot intercorrelations between regressors in design matrix using coefplot.
  #' @param mod model object fitted with lme4 or another package.
  #' @param perSub compute correlation between regressors separately per subject, than average (TRUE) (default: FALSE).
  #' @param varNames vector of strings, names of variables to use for rows/ columns of design matrix.
  #' @param savePNG Boolean, save as PNG to dirs$plot (TRUE, default) or not (FALSE).
  #' @return nothing, plots to console and saves in dirs$plot.
  
  require(psych) # for fisherz and fisherz2r
  require(corrplot)
  
  # -------------------------------------------------------------------------- #
  ## Close any open plots:
  
  if (length(dev.list()!=0)){dev.off()}
  
  # -------------------------------------------------------------------------- #
  ## Extract design matrix:
  
  DM <- model.matrix(mod) # extract design matrix
  DM <- DM[, 2:ncol(DM)] # drop intercept
  
  # -------------------------------------------------------------------------- #
  ## Compute correlation:
  
  if (perSub){
    
    cat("Separate DM per subject, average\n")
    subIdx <- mod@frame[, ncol(mod@frame)] # extract subject indices
    stopifnot(nrow(DM) == length(subIdx)) # assure dimensions match
    subVec <- unique(subIdx)
    nSub <- length(subVec)
    
    Mlist <- vector(mode = "list", length = nSub) # initialize
    
    for (iSub in 1:nSub){ # iSub <- 1
      
      subID <- subVec[iSub] # subject ID
      DMsub <- DM[subIdx == subID, ] # select part of design matrix for this subject
      M <- cor(DMsub) # correlation
      MF <- fisherz(M) # Fisher-z transform
      diagIdx <- which(MF == Inf) # detect diagonal elements (infinite)
      MF[diagIdx] <- 1 # temporarily overwrite to 1, correct later after transforming back
      
      Mlist[[iSub]] <- MF # store
    }
    
    M <- Reduce("+", Mlist)/nSub # mean across subjects
    M <- fisherz2r(M) # transform back
    M[diagIdx] <- 1 # set diagonal back to 1 
    
  } else {
    M <- cor(DM)
  }
  
  ## Print range to console:
  Mvec <- as.vector(M) # to vector
  diagVec <- seq(1, length(Mvec), nrow(M) + 1) # identify indices of diagonal
  Mvec[diagVec] <- NA # set diagonal to NA
  nRound <- 2
  cat(paste0("All correlations between r = ", round(min(Mvec, na.rm = T), nRound), " and r = ", round(max(Mvec, na.rm = T), nRound), "\n"))
  
  # -------------------------------------------------------------------------- #
  ## Overwrite variables names:
  
  if (is.null(varNames)){
    rownames(M) <- substitute_label(rownames(M)) # substitute for known variable names
  } else {
    stopifnot(nrow(M) == length(varNames)) # check if same length
    rowNames(M) <- varNames # overwrite
  }
  colnames(M) <- rownames(M)
  
  # -------------------------------------------------------------------------- #
  ## Title and name for saving:
  
  # https://stackoverflow.com/questions/14671172/how-to-convert-r-formula-to-text
  if (class(mod) %in% c("glmerMod")){
    
    formulaStr <- mod@call$formula
    
  } else {
    
    formulaStr <- attr(mod@frame, "formula")
    
  }
  formulaStr <- Reduce(paste, deparse(formulaStr, width.cutoff = 500)) # convert from formula to string object
  
  # https://stackoverflow.com/questions/40509217/how-to-have-r-corrplot-title-position-correct
  # titleStr <- paste0("Intercorrelation regressors for \n", deparse(formulaStr), width.cutoff = 20))
  
  plotName <- paste0("corr_reg_", formula2handle(formulaStr))
  if (perSub){plotName <- paste0(plotName, "_perSub")}
  plotName <- paste0(plotName, ".png")
  
  # -------------------------------------------------------------------------- #
  ## Make corrplot:
  
  # mar = c(0,0, 1,0)  
  # if(savePNG) {png(paste0(dirs$plot, "ic_reg/", plotName), width = 480, height = 480)}
  if(savePNG) {png(paste0(dirs$plot, plotName), width = 480, height = 480)}
  
  # https://stackoverflow.com/questions/40352503/change-text-color-in-corrplot-mixed
  
  # corrplot(M, method = "circle", col = rev(COL2('RdBu', 200))) # colored dots of different size
  # corrplot(M, method = "number", col = rev(COL2('RdBu', 200))) # numerals of different color
  
  ## Upper half colored dots of different size, lower half black numerals, variable names in diagonal:
  # corrplot.mixed(M, lower = "number", upper = "circle", lower.col = "black", upper.col = rev(COL2('RdBu', 200)), tl.col = "black")
  
  ## Colors dots of different size with black numerals in them:
  corrplot::corrplot(M, addCoef.col = 'black', col = rev(COL2('RdBu')), tl.col = "black", tl.pos = "lt")
  # corrplot(M, addCoef.col = 'black', col = rev(COL2('RdBu')), tl.col = "black", tl.offset = 1, tl.srt = 0) # column labels higher, not rotated
  
  ## Also numerals in color, different color scale (uniform), variable names in diagonal:
  # corrplot.mixed(M, lower = "number", upper = "circle", lower.col = COL1('YlOrRd', 200), upper.col = rev(COL2('RdBu')))
  # corrplot.mixed(M, lower = "number", upper = "circle", lower.col = COL1('YlOrRd', 200), upper.col = COL1('YlOrRd', 200))
  
  # print(p)
  if(savePNG){
    dev.off(); 
    cat(paste0("Saved under \n", plotName, " :-)\n"))
    corrplot::corrplot(M, addCoef.col = 'black', col = rev(COL2('RdBu')), tl.col = "black", tl.pos = "lt")
  }
  
}

# ============================================================================ #
#### 17) Plot intercorrelations of coefficients from model: #####

corrplot_coefficients <- function(input, varNames = NULL, savePNG = TRUE){ 
  #' Plot intercorrelations between regressors in design matrix using coefplot.
  #' @param mod model object fitted with lme4 or another package.
  #' @param varNames vector of strings, names of variables to use for rows/ columns of design matrix.
  #' @param savePNG Boolean, save as PNG to dirs$plot (TRUE, default) or not (FALSE).
  #' @return nothing, plots to console and saves in dirs$plot.
  
  require(corrplot)
  
  # -------------------------------------------------------------------------- #
  ## Close any open plots:
  
  if (length(dev.list()!=0)){dev.off()}
  
  # -------------------------------------------------------------------------- #
  ### Detect class and extract coefficients:
  
  ## Detect model class:  
  modClass <- class(input)
  if (modClass == "list"){modClass <- class(input$modList[[1]]); modClass <- modClass[1]}
  cat(paste0("Input model of class ", modClass, "\n"))
  
  ## Extract coefficients, parameter names, formula:
  
  if(modClass %in% c("glmerMod", "lmerMod", "lmerTest", "lmerModLmerTest")){ # from lme4
    
    coefMat <- coef(input)[[1]]
    
    parNamesVec <- colnames(coefMat)
    
    if (modClass %in% c("glmerMod")){
      
      formulaStr <- input@call$formula
      
    } else {
      
      formulaStr <- attr(input@frame, "formula")
      
    }
    formulaStr <- Reduce(paste, deparse(formulaStr, width.cutoff = 500)) # convert from formula to string object
    
    # lmer
  } else if (modClass %in% c("mixed")){ # from afex
    
    coefMat <- coef(input$full_model)[[1]]
    parNamesVec <- rownames(coefMat)
    
    formulaStr <- input@call$formula
    formulaStr <- Reduce(paste, deparse(formulaStr, width.cutoff = 500)) # convert from formula to string object
    
  } else if (modClass %in% c("lm", "glm")){ # from lm
    
    coefMat <- input$bMat
    parNamesVec <- names(coef(input$modList[[1]]))
    if (modClass == "glm"){
      formulaStr <- input$modList[[1]]$formula
    } else if (modClass == "lm"){
      formulaStr <- eval(input$modList[[1]]$call[[2]]) 
    } else {
      stop("Unknown model class")
    }
    
  } else if (modClass %in% c("brmsfit")){ # from brms
    
    ## Parameter names and formula:
    parNamesVec <- row.names(fixef(input)) # names of all predictors
    nParam <- length(parNamesVec)
    
    formulaStr <- input$formula
    formulaStr <- formulaStr[[1]] # extract only first object
    formulaStr <- Reduce(paste, deparse(formulaStr, width.cutoff = 500)) # convert from formula to string object
    
    ## Exttract correlation estimates:
    brmsVarCorr <- VarCorr(input)[[1]]$cor 
    brmsVarCorr <- VarCorr(input)$subject_f$cor 
    
    coefMat <- matrix(NA, nParam, nParam) # initialize
    rownames(coefMat) <- parNamesVec
    colnames(coefMat) <- parNamesVec
    for (iParam1 in 1:nParam){ # iParam1 <- 1
      for (iParam2 in 1:nParam){ # iParam2 <- 2
        coefMat[iParam1, iParam2] <- brmsVarCorr[iParam1, 1, iParam2]
      }
    }
    
  } else {
    
    stop("Unknown model class")
    
  }
  
  # -------------------------------------------------------------------------- #
  ## Compute correlation:
  
  M <- cor(coefMat)
  
  ## Print range to console:
  Mvec <- as.vector(M) # to vector
  diagVec <- seq(1, length(Mvec), nrow(M) + 1) # identify indices of diagonal
  Mvec[diagVec] <- NA # set diagonal to NA
  nRound <- 2
  cat(paste0("All correlations between r = ", round(min(Mvec, na.rm = T), nRound), " and r = ", round(max(Mvec, na.rm = T), nRound), "\n"))
  
  # -------------------------------------------------------------------------- #
  ## Overwrite variables names:
  
  if (is.null(varNames)){
    
    rownames(M) <- parNamesVec
    rownames(M) <- substitute_label(rownames(M)) # substitute for known variable names
    
  } else { # overwrite with inputs
    
    stopifnot(nrow(M) == length(varNames)) # check if same length
    rowNames(M) <- varNames # overwrite
  }
  
  colnames(M) <- rownames(M) # copy over
  
  # -------------------------------------------------------------------------- #
  ## Title and name for saving:
  
  # https://stackoverflow.com/questions/14671172/how-to-convert-r-formula-to-text
  
  plotName <- paste0("corr_coef_", modClass, "_", formula2handle(formulaStr), ".png")
  # plotNameFull <- paste0(dirs$plot, "ic_coef/", plotName)
  plotNameFull <- paste0(dirs$plot, plotName)
  cat(paste0("File path has ", nchar(plotNameFull), " characters\n"))
  if (nchar(plotNameFull) > 260){
    warning("File path too long, shorten\n")
    plotNameFull <- paste0(substr(plotNameFull, 1, 255)[1], ".png")
  }
  
  # -------------------------------------------------------------------------- #
  ## Visualize correlation matrix:
  # https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html
  
  if(savePNG) {png(plotNameFull, width = 480, height = 480)}
  
  # corrplot(M, method = "circle", col = rev(COL2('RdBu', 200)))
  # corrplot(M, method = "number", col = rev(COL2('RdBu', 200)))
  corrplot::corrplot(M, addCoef.col = 'black', col = rev(COL2('RdBu')), tl.col = "black", tl.pos = "lt")
  
  if(savePNG){
    dev.off(); 
    cat(paste0("Saved under \n", plotName, " :-)\n"))
    ## Plot again:
    corrplot::corrplot(M, addCoef.col = 'black', col = rev(COL2('RdBu')), tl.col = "black", tl.pos = "lt")
  }
  
}

# ============================================================================ #
#### 18) Quick CIs based on SEs: ####

quickCI <- function(mod, selEff = NULL, level = 0.95, nRound = 3){
  #' Compute CIs for given lme4 model given SEs from model.
  #' @param data mod model objected fitted with lme4.
  #' @param selEff vector of integers, index of effect in model for which to compute effect size (default: 2).
  #' @param level numeric, 0-1, level of CIs (default: 0.95).
  #' @param nRound integer, number of digits after comma to round to (default: 2).
  #' @return print to console.
  require(arm) # for se.fixef
  
  ## Determine z-value by which to multiply SE:
  twoSideLevel <- 1 - (1 - level) / 2 # correct for two-sided test
  zVal <- qnorm(twoSideLevel) # respective z-level threshold
  
  ## If no effect selected: print all effects in model (skipping intercept)
  if (is.null(selEff)){selEff <- 2:length(fixef(mod))}
  
  ## Loop through effects:
  for (iEff in selEff){
    
    # print(round(c(fixef(mod)[iEff] - zVal*se.fixef(mod)[iEff], fixef(mod)[iEff] + zVal*se.fixef(mod)[iEff]), nRound))
    tmp <- round(c(fixef(mod)[iEff] - zVal*se.fixef(mod)[iEff], 
                   fixef(mod)[iEff] + zVal*se.fixef(mod)[iEff]), 
                 nRound)  
    cat(paste0(level*100, "%-CIs for ", colnames(model.matrix(mod))[iEff], 
               ": b = ", round(fixef(mod)[iEff], nRound), ", ", 
               level*100, "%-CI [", paste(tmp, collapse = ", "), "]\n"))
  }
}

# ============================================================================ #
#### 19) Print effect from lme4 model: #####

print_effect <- function(mod, eff, nDigit = 3){
  #' Print selected effect from lme4 model
  #' @param mod fitted model
  #' @param eff string, name of effect for which to print effect
  #' @param nDigit integer, number of digits to round after comma, default 2
  #' @return nothing returned, but printed
  require(stringr)
  
  nPad <- nDigit + 2
  
  if (str_sub(eff,-1) == "f"){eff <- paste0(eff, "1")} # add 1 at the end if eff is factor
  
  # Extract output of fixed effects:
  coefs <- summary(mod)$coefficients # extract coefficients
  idx <- which(rownames(coefs) == eff) # find effect back
  if (length(idx) == 0){stop(paste0("Effect ", eff, " not found"))} 
  
  ## Retrieve coefficients:
  if (summary(mod)$objClass == "glmerMod"){ # glmer
    
    # Extract relevant info:
    b <- coefs[idx, 1]
    se <- coefs[idx, 2]
    zScore <- coefs[idx, 3]
    pVal <- coefs[idx, 4]
    
  } else if (summary(mod)$objClass == "lmerModLmerTest"){ # lmer
    
    # Extract relevant info:
    b <- coefs[idx, 1]
    se <- coefs[idx, 2]
    dfs <- coefs[idx, 3]
    zScore <- coefs[idx, 4]
    pVal <- coefs[idx, 5]
    
  } else {
    stop("Unknown model type")
  }
  
  # Variable padding of b based on sign:
  bPad <- ifelse(b > 0,nPad,nPad+1) # pad to 5 digits if negative
  zPad <- ifelse(zScore > 0,nPad,nPad+1) # pad to 5 digits if negative
  
  ## Handle b:
  if (round(b,nDigit) == 0){
    bText <- "0"
  } else {
    bText <- str_pad(round(b,nDigit), bPad, side = "right", pad = "0")
  }
  
  ## Handle se:
  if (round(se,nDigit) == 0){
    seText <- "0"
  } else {
    seText <- str_pad(round(se,nDigit), nPad, side = "right", pad = "0")
  }
  
  ## Handle statistic for given object:
  if (summary(mod)$objClass == "glmerMod"){
    zStat <- ", z = "
  } else {
    zStat <- paste0(", t(",round(dfs,nDigit), ") = ")
  }
  
  if (round(zScore,nDigit) == 0){
    zText <- "0"
  } else {
    zText <- str_pad(round(zScore,nDigit), zPad, side = "right", pad = "0")
  }
  
  ## Handle very small p-values:
  if (pVal < 0.001){
    pText <- "p < .001"
  } else {
    pText <- paste0("p = ", str_pad(round(pVal,(nDigit+1)), 5, side = "right", pad = "0")) # p-value: always 5 digits
  }
  
  # Print to console:
  cat(paste0("b = ", bText,
             ", se = ", seText,
             zStat, zText,
             ", ", pText, "\n"))
}

# ============================================================================ #
#### 20) Fit lm per subject: #####

loop_lm_subject <- function(data, formula, isBinomial = F, family = "binomial",
                            subVar = "subject_n"){
  #' Perform lm separately for each subject, store coefficients and models, 
  #' one-sample t-test across subjects for each effect, return.
  #' @param data data frame with variable subject and DVs and IVs.
  #' @param formula string with formula to fit in Wilkinson notation.
  #' @param isBinomial boolean, fit generalized lm with binomial link function (T) or not (F).
  #' @param family distribution of DV to use (default: binomial).
  #' @return output list with elements:
  #' output$bVec: vector of size nSub x nEff, b weights for each effect for each subject.
  #' output$modList: list of models of each subject.
  #' Prints results from t-test across subjects for each effect.
  
  require(DescTools)
  
  # ----------------------------------------------- #
  ## Fixed variables:
  if (!(subVar %in% names(data))){stop(paste0("subVar ", subVar, "not contained in data"))}
  nDigit <- 3
  
  # ----------------------------------------------- #
  ## Determine number of subjects:
  subVec <- unique(data[, subVar])
  nSub <- length(subVec)
  cat(paste0("Found data from ", nSub, " subjects\n"))
  
  # ----------------------------------------------- #
  ## Fit model for first subject available to determine number of coefficients:
  subIdx <- which(data[, subVar] == subVec[1])
  subData <- data[subIdx, ]
  mod <- lm(formula = formula, data = subData) # fit model
  nEff <- length(mod$coefficients)
  
  # ----------------------------------------------- #
  ## Initialize matrix to store coefficients:
  
  bMat <- matrix(NA, nrow = nSub, ncol = nEff) # initialize
  modList <- list()
  sumModList <- list()
  
  ## Loop through all subjects:
  for (iSub in 1:nSub){ # iSub <- 1
    
    ## Select subject and data:    
    subID <- subVec[iSub]
    cat(paste0("Start subject ", subID, "\n"))
    subIdx <- which(data[, subVar] == subID)
    subData <- data[subIdx, ]
    
    ## Fit model:
    if (isBinomial) {
      if (family == "binomial"){
        mod <- glm(formula = formula, data = subData, family = binomial())
      }
      else if (family == "poisson"){
        mod <- glm(formula = formula, data = subData, family = poisson())
      } else {
        stop("Unknown family for DV")
      }
    } else {
      mod <- lm(formula = formula, data = subData)
    }
    
    modList[[iSub]] <- mod
    sumModList[[iSub]] <- summary(mod)
    bMat[iSub, ] <- mod$coefficients # store data
    
  } # end iSub
  
  # names(bMat) <- names(coef(mod)) # copy over regressor names
  
  # ----------------------------------------------- #
  ## Perform 1-sample t-test across subjects for each effect:
  
  if(nEff > 0) {
    for (iEff in 1:nEff){ # iEff <- 1
      # out <- t.test(FisherZ(bMat[, iEff]) # one-sample t-test: only for correlations in range [-1, 1], so not for intercept, not for glm
      out <- t.test((bMat[, iEff])) # one-sample t-test
      cat(paste0("Effect for ", names(mod$coefficients)[iEff], 
                 ": t(", out$parameter, ") = ", round(out$statistic, nDigit), 
                 ", p = ", out$p.value, "\n"))
    }
    
  } else {
    cat("Intercept-only model, no effects printed\n")
  }
  
  cat("Finished! :-)\n")
  
  # ----------------------------------------------- #
  ## Output:
  output <- list()
  output$bMat <- bMat
  output$modList <- modList
  output$sumModList <- sumModList
  
  return(output)
}

# ============================================================================ #
#### 21) Fit glm per subject: #####

loop_glm_subject <- function(data, formula, family = "binomial", subVar = "subject_n"){
  #' Wrapper on loop_lm_subject to perform glm separately for each subject.
  #' @param data data frame with variable subject and DVs and IVs.
  #' @param formula string with formula to fit in Wilkinson notation.
  #' @param family distribution of DV to use (default: binomial).
  #' @return modList list with elements:
  #' modList$bVec: vector of size nSub x nEff, b weights for each effect for each subject.
  #' modList$modList: list of models of each subject.
  #' Prints results from t-test across subjects for each effect.
  
  ## Call loop_lm_subject with isGLM = T:
  out <- loop_lm_subject(data, formula, isBinomial = T, family = family, subVar = subVar)
  
  return(out)
}

# ============================================================================ #
#### 22) Aggregate data per subject per condition: ####

aggregate_sub_cond <- function(data, yVar, xVarVec, subVar = "subject_f",
                               format = "long", printSumStats = F){
  #' Compute mean and SD of yVar per conditions spanned by xVarVec.
  #' @param data data frame, input trial-by-trial data.
  #' @param yVar scalar string, name of dependent variable which to aggregate.
  #' @param xVarVec vector of strings, names of independent variables by which to aggregate.
  #' @param subVar scalar string, name of subject identifier (default: subject_f).
  #' @return nothing, just print to console
  require(plyr)
  
  # yVar <- "RTcleaned_n"
  # xVarVec <- c("arousal_f", "reqAction_f", "valence_f")
  # subVar <- "subject_f"
  
  ## Copy over:
  input <- data
  
  ## Aggregate into long format:
  cat("Aggregate data per subject per condition into long format\n")
  cat(paste0("Conditions are formed by ", paste0(xVarVec, collapse = ", "), "\n"))
  aggrData_long <- eval(parse(text = paste0("ddply(input, .(subject_f, ", paste0(xVarVec, collapse = ", "), "), function(subData){
    ", yVar, " <- mean(subData[, \"", yVar, "\"], na.rm = T)
    return(data.frame(", yVar, "))
    dev.off()})")))
  output <- aggrData_long
  
  ## Create overall condition variable by concenating xVars:
  if (format == "wide" | format == "WIDE"){
    cat("Cast into wide format\n")
    aggrData_long$condition_f <- eval(parse(text = paste0("paste0(aggrData_long$", paste0(xVarVec, collapse = ", \"_\", aggrData_long$"), ")")))
    aggrData_long <- aggrData_long[, c(subVar, yVar, "condition_f")]
    
    ## Reshape into wide format:
    aggrData_wide <- reshape(aggrData_long, direction = "wide",
                             idvar = subVar, v.names = yVar, timevar = "condition_f")
    output <- aggrData_wide
    
    if(printSumStats){
      ## Print condition means and SDs:
      nRound <- 3
      condData <- aggrData_wide[, grepl(yVar, names(aggrData_wide))]
      cat("Mean per condition:\n")
      # colMeans(condData, na.rm = T)
      print(round(apply(aggrData_wide[, grepl(yVar, names(aggrData_wide))], 2, mean, na.rm = T), nRound))
      cat("SD per condition:\n")
      print(round(apply(aggrData_wide[, grepl(yVar, names(aggrData_wide))], 2, sd, na.rm = T), nRound))
      cat("Finished! :-)\n")
      
    }
    
  }
  # str(aggrData_wide)
  
  return(output)
}

# ============================================================================ #
#### 23) Quick RM-ANOVA: ####

custom_RMANOVA <- function(data, yVar, subVar, ...) {
  #' Remove NAs, 
  #' aggregate per subject per condition into long-format using ddply,
  #' run RM-ANOVA with ezANOVA().
  #' @param data        data frame with trial-by-trial data.
  #' @param yVar        scalar string, name of response variable (DV) to aggregate.
  #' @param subVar      scalar string, name of subject identifier variable (to use for aggregation).
  #' @param ...         vector of strings, conditions to use for aggregation.
  #' @return  $ANOVA part of the output from the ezANOVA() function call.
  #' For the idea of evaluation + substitution, see    
  # https://stackoverflow.com/questions/32616639/in-a-custom-r-function-that-calls-ezanova-how-do-i-parameterize-the-dv
  
  require(plyr)
  require(ez)
  
  ## Extract within subjects factors:
  withinVarVec <- list(...)
  if(length(withinVarVec) < 1){stop("Must provide other factors as inputs after subVar argument")}
  cat(paste0("Provided factors are ", paste0(withinVarVec, collapse = ", "), "\n"))
  
  ## ------------------------------------------------------------------------- #
  ### Check input variables:
  
  ## Drop factor levels:
  data <- droplevels(data)
  
  ## Check if all variables available in data frame:
  if(!(yVar %in% names(data))){stop("yVar not found in data")}
  if(!(subVar %in% names(data))){stop("subVar not found in data")}
  for (withinVarName in withinVarVec){ # withinVarName <- withinVarVec[1]
    if(!(withinVarName %in% names(data))){stop(paste0(withinVarName, " not found in data"))}
    if(!(is.factor(data[, withinVarName]))){stop(paste0(withinVarName, " has to be a factor"))}
    cat(paste0("Factor ", withinVarName, " has ", length(levels(data[, withinVarName])), " levels: ", paste0(levels(data[, withinVarName]), collapse = ", "), "\n"))
  }
  
  cat(paste0("Run RM-ANOVA on DV ", yVar, " with factors ", paste0(withinVarVec, collapse = ", "), "\n"))
  
  ## ------------------------------------------------------------------------- #
  ### Remove NAs:
  
  cat(paste0("Input data has ", nrow(data), " rows before NA exclusion\n"))
  data <- data[complete.cases(data[, yVar]), ] # response variable
  data <- data[complete.cases(data[, subVar]), ] # subject identifier variable
  for (withinVarName in withinVarVec){ # loop over all within variables
    data <- data[complete.cases(data[, withinVarName]), ]
  } 
  cat(paste0("Input data has ", nrow(data), " rows after NA exclusion\n"))
  
  ## Drop factor levels:
  data <- droplevels(data)
  
  ## ------------------------------------------------------------------------- #
  ### Aggregate data:
  
  ## Specify formula for aggregation:
  aggrFormula <- as.formula(paste("~", paste(c(subVar, withinVarVec), collapse = "+")))
  
  ## Aggregate data with ddply:
  aggrData_long <- ddply(data, aggrFormula, function(x) {
    yMean <- mean(x[[yVar]], na.rm = TRUE)
    return(data.frame(yMean))
  })
  
  ## Check for NaNs:
  if(any(is.na(aggrData_long$yMean))){
    naIdx <- which(is.na(aggrData_long$yMean))
    warning(paste0("Subjects ", paste0(aggrData_long[naIdx, subVar], collapse = ", "), " have NAs in aggregated data\n"))
  }

  ## Check for empty cells:
  cellCount <- tapply(aggrData_long$yMean, aggrData_long[, subVar], length)
  if (any(cellCount < max(cellCount))){
    incompleteIdx <- which(cellCount < max(cellCount))
    warning(paste0("Subjects ", paste0(names(incompleteIdx), collapse = ", "), " have incomplete designs\n"))
    
  }

  ## ------------------------------------------------------------------------- #
  ### Run RM-ANOVA:
  
  ## Convert to correct format:
  subExpr <- as.name(subVar)
  withinExpr <- as.call(c(as.name("."), lapply(withinVarVec, as.name)))
  
  ## Run RM-ANOVA using ezANOVA:
  results <- eval(substitute(
    ezANOVA(
      data = aggrData_long,
      dv = .(yMean),               # Dependent variable is the aggregated response
      within =  withinVars,        # List of within-subject variables
      wid = subVar,                # Subject variable (unique identifier for subjects)
      type = 3,                    # Type 3 sum of squares
      detailed = TRUE), 
    list(subVar = subExpr, withinVars = withinExpr))
  )
  
  ## Print output to console:
  print(results$ANOVA)
  return(results$ANOVA)
}

# ============================================================================ #
#### 24) Plot single bar plot with individual data points: ####

custom_singlebar <- function(data, yVar, yLim = c(0, 1), isViolin = FALSE, hLine = NULL,
                             selCol = "grey80", xLab = "x", yLab = NULL, main = NULL){
  #' Plot single bar or half-density (violin) with single points per data point.
  #' @param data data frame, with variable \code{yVar} to plot.
  #' @param yVar string, name of variable to plot.
  #' @param isViolin Boolean, plot half-density (violin) instead of bar (default: FALSE)
  #' @param hLine scalar numeric, y-axis coordinate for horizontal dashed line (default: NULL).
  #' @param selCol scalar string, color to use for violin/ bar (default: grey80).
  #' @param xLab string, label for x-axis (default: "x")
  #' @param yLab string, label for y-axis (default: "y")
  #' @param main string, title of plot (default: "NULL")
  #' @return prints and returns ggplot object.
  
  ## Load packages:
  require(ggplot2)
  require(gghalves)
  require(ggbeeswarm)
  
  ## Aggregate again with Rmisc:
  # library(Rmisc)
  # summary_d <- summarySEwithin(d,measurevar = "ACC", idvar = "sID", na.rm = T)
  
  # -------------------------------------------------------------------------- #
  ### Check inputs:
  
  ## Check if input variables included in data set:
  if(!(is.data.frame((data)))){stop("data must be a data frame")}
  if(!(yVar %in% names(data))){stop("yVar not found in data")}
  
  ## Check variable types:
  if(!(is.numeric(data[, yVar]))){stop("yVar has to be numeric")}
  
  ## y-axis label:
  if(is.null(yLab)){yLab <- substitute_label(yVar)}
  if(!(is.character(yLab))){stop("yLab has to be a character string")}
  
  # -------------------------------------------------------------------------- #
  ### Fixed settings:
  
  FTS <- 30
  LWD <- 1.5
  colAlpha <- .70
  
  # -------------------------------------------------------------------------- #
  ### Prepare data set:
  
  ## Add jittered x-axis position:
  nSub <- nrow(data)
  data$x <- rep(1, nSub)
  data$j <- jitter(rep(0, nrow(data)), amount = .05)
  data$xj <- data$x + data$j
  
  ## Repeat selected variable:
  data$y <- data[, yVar]
  
  # -------------------------------------------------------------------------- #
  ### Start plot:
  
  p <- ggplot(data = data, aes(x = x, y = y)) # initialize
  
  # -------------------------------------------------------------------------- #
  ## Bar or violin:
  
  if (isViolin){ # if violin
    p <- p + geom_half_violin(color = "black", fill = selCol, alpha = colAlpha, trim = FALSE)
  } else { # if bar
    p <- p + stat_summary(fun = mean, geom = "bar", fill = selCol, alpha = colAlpha,
                          color = 'black', width = 0.3, lwd = LWD)
  }
  
  # -------------------------------------------------------------------------- #
  ## Confidence intervals: 
  
  p <- p + stat_summary(fun.data = mean_cl_normal, geom =
                          "errorbar", width = 0.05, lwd = LWD)
  
  # -------------------------------------------------------------------------- #
  ## Individual data points:
  
  # p <- p + geom_beeswarm(color = "black", fill = color, alpha = colAlpha)
  p <- p + geom_point(data = data, aes(x = xj), color = "black", fill = "grey40",
                      shape = 21, size = 4,
                      alpha = colAlpha)
  
  # -------------------------------------------------------------------------- #
  ## Other settings:
  
  if (!(is.null(hLine))){
    p <- p + geom_hline(yintercept = hLine, linetype = 2, color = "black")
  }
  if (mean(yLim) == 0.5){ # if conditional probabilities:
    p <- p + geom_hline(yintercept = 0.5, linetype = 2, color = "black")
  }
  
  ## X-axis:
  p <- p + scale_x_continuous(limits = c(0.5, 1.5), breaks = c(0, 1, 2), labels = c("", "", ""))
  
  ## Y-axis:
  if (yLim[1] >= 0 & yLim[-1] <= 1){
    yBreak <- 0.25
    p <- p + scale_y_continuous(limits = yLim, breaks = seq(yLim[1], yLim[-1], yBreak))
  } else {
    yBreak <- ceiling((yLim[-1] - yLim[1])/5)
    cat(paste0("Use yBreak = ", yBreak))
    p <- p + scale_y_continuous(limits = yLim, breaks = seq(yLim[1], yLim[-1], yBreak))
  }
  if (yLim[1] > 0){
    p <- p + coord_cartesian(ylim = yLim) # to avoid bar being dropped
  }
  
  ## Axis labels:
  p <- p + xlab(xLab) + ylab(yLab)
  
  ## Add title:
  if(!is.null(main)){p <- p + ggtitle(main)}    
  
  ## Add theme:
  p <- p + theme_classic()
  
  ## Font sizes:
  p <- p + theme(axis.text = element_text(size = FTS),
                 axis.title = element_text(size = FTS), 
                 plot.title = element_text(size = FTS, hjust = 0.5), # center title 
                 legend.text = element_text(size = FTS))
  
  # Print plot in the end:
  print(p)
  return(p)
  
}

# ============================================================================ #
#### 25) Barplot 1 IV: Aggregate per condition per subject, plot (1 IV on x-axis): ####

custom_barplot1 <- function(data, xVar = NULL, yVar = NULL, subVar = "subject_n", 
                            xLab = NULL, yLab = NULL, main = NULL, selCol = NULL,
                            isPoint = T, isConnect = T, isMidLine = F, hLine = NULL, isBeeswarm = F, 
                            yLim = NULL, FTS = NULL, 
                            savePNG = F, saveEPS = F, saveSVG = F, savePDF = F, prefix = NULL, suffix = NULL){
  #' Make bar plot with error bars and individual-subject data points.
  #' @param data data frame, trial-by-trial data.
  #' @param xVar string, name of variable that goes on x-axis. If numeric, it will be converted to an (ordered) factor.
  #' @param yVar string, name of variable that goes on y-axis. Needs to be numeric.
  #' @param subVar string, name of variable containing subject identifier (default: subject).
  #' @param xLab string, label for x-axis (default: retrieve appropriate name with substitute_label()).
  #' @param yLab string, label for y-axis (default: retrieve appropriate name with substitute_label()).
  #' @param main string, overall plot label (optional).
  #' @param selCol vector of strings (HEX colors), colors for bars (default: retrieve via retrieve_colour()).
  #' @param isPoint Boolean, plot individual data points per condition as small points (default: FALSE).
  #' @param isMidLine Boolean, add horizontal line at midpoint of y-axis (default: FALSE).
  #' @param yLine scalar numeric, draw horizontal line at given y value (default: NULL).   
  #' @param isConnect Boolean, connect individual data points with grey lines (default: FALSE).
  #' @param isBeewswarm Boolean, plot individual data points per condition as beeswarm densities (default: FALSE).
  #' @param yLim vector of two numbers, y-axis (default: automatically determined by ggplot).
  #' @param FTS scalar integer, font size to use.
  #' @param savePNG Boolean, save as .png file.
  #' @param saveEPS Boolean, save as .eps file.
  #' @param saveSVG Boolean, save as .svg file.
  #' @param savePDF Boolean, save as .pdf file.
  #' @param prefix string, string to add at the beginning of plot name (optional).
  #' @param suffix string, string to add at the end of plot name (optional).
  #' @return creates (and saves) plot.
  
  # -------------------------------------------------------------------------- #
  ## Load required packages:
  
  require(plyr) # for ddply
  require(Rmisc) # for summarySEwithin
  
  # -------------------------------------------------------------------------- #
  ## Close any open plots:
  
  if (length(dev.list()!=0)){dev.off()}
  
  # -------------------------------------------------------------------------- #
  ## Check inputs:
  
  ## Input variables:
  if(!(yVar %in% names(data))){stop("yVar not found in data")}
  if(!(xVar %in% names(data))){stop("xVar not found in data")}
  if(!(subVar %in% names(data))){stop("subVar not found in data")}
  
  ## Axis labels:
  if(is.null(xLab)){xLab <- substitute_label(xVar)}
  if(is.null(yLab)){yLab <- substitute_label(yVar)}
  
  # -------------------------------------------------------------------------- #
  ## Fixed plotting settings:
  
  SEweight <- 1
  LWD <- retrieve_plot_defaults("LWD")
  dodgeVal <- retrieve_plot_defaults("dodgeVal")
  colAlpha <- 0.5 # 1
  jitterSize <- 0.02 # used to be 0.09
  
  if (is.null(FTS)){
    FTS <- retrieve_plot_defaults("FTS") # 30 or 15?
  }
  
  if (length(unique(data[, xVar])) > 20){
    cat("More than 20 levels on x-axis, reduce font size and line width\n")
    FTS <- 12
    LWD <- 0.5
  }
  
  # -------------------------------------------------------------------------- #
  ## Create variables under standardized names:
  
  cat("Overall condition means (without first aggregating per subject):\n")
  print(tapply(data[, yVar], data[, xVar], mean, na.rm = T))
  
  data$x <- data[, xVar]
  data$y <- data[, yVar]
  data$subject <- data[, subVar]
  
  ## Exclude NAs:
  nRow1 <- nrow(data)
  data <- droplevels(subset(data, !(is.na(x)) & !(is.na(y))))
  nRow2 <- nrow(data)
  cat(paste0("Excluded ", nRow1 - nRow2, " rows due to NAs\n"))
  
  ## Colours:
  if(is.null(selCol)){
    selCol <- retrieve_colour(xVar)
    selCol <- rep(selCol, length.out = length(unique(data[, xVar])))
  }
  if(length(selCol) != length(unique(data[, xVar]))){
    stop(paste0("Length selCol = ", length(selCol), " while number levels xVar = ", length(unique(data[, xVar])), ", do not match"))
  }
  
  # -------------------------------------------------------------------------- #
  ## Aggregate data per subject per condition:
  
  aggrData <- ddply(data, .(subject, x), function(x){
    y <- mean(x$y, na.rm = T)
    return(data.frame(y))
    dev.off()})
  cat(paste0("Min = ", round(min(aggrData$y), 3), "; Max = ", round(max(aggrData$y), 3)), "\n")
  
  # -------------------------------------------------------------------------- #
  ## Add jittered x-axis variable for points:
  
  aggrData$xpos <- as.numeric(aggrData$x) # to numeric
  aggrData$xpos <- aggrData$xpos - min(aggrData$xpos) + 1 # plot starts at lowest level of x-variable
  aggrData$j <- jitter(rep(0, nrow(aggrData)), amount = jitterSize) # jitter 0.09
  aggrData$xj <- aggrData$xpos + aggrData$j # add jitter
  
  # -------------------------------------------------------------------------- #
  ## Determine y limits if not given:
  
  if(is.null(yLim)){
    yLim <- determine_ylim_data_y(aggrData)
  }
  
  # -------------------------------------------------------------------------- #
  ## Aggregate across subjects with Rmisc:
  
  summary_d <- summarySEwithin(aggrData, measurevar = "y", idvar = "subject", na.rm = T,
                               withinvars = c("x"))
  
  # -------------------------------------------------------------------------- #
  ## Control settings for saving:
  
  ## Additions:
  if(is.null(prefix)){prefix <- ""} else {prefix <- paste0(prefix, "_")}
  if(is.null(suffix)){suffix <- ""} else {suffix <- paste0("_", suffix)}
  
  ## Name:
  plotName <- paste0("custombarplot1_", prefix, yVar, "_", xVar)
  if (isPoint){plotName <- paste0(plotName, "_points")} 
  plotName <- paste0(plotName, suffix)
  cat(paste0("Start plot ", plotName, "\n"))
  
  # Saving:
  if (saveEPS){cat("Save as eps\n"); setEPS(); postscript(paste0(dirs$plotDir, plotName, ".eps"), width = 480, height = 480)}
  if (savePNG){cat("Save as png\n"); png(paste0(dirs$plotDir, plotName, ".png"), width = 480, height = 480)}
  
  # -------------------------------------------------------------------------- #
  ## Start ggplot:
  p <- ggplot(summary_d,aes(x, y))
  
  ## Bars of means:
  cat("Add group-level bars \n")
  p <- p + stat_summary(fun = mean, geom = "bar", position = "dodge", width = 0.6,
                        lwd = LWD, fill = selCol, color = "black") + 
    
    ## Error bars:
    cat("Add error bars \n")
  p <- p + geom_errorbar(data = summary_d,
                         aes(x = x, y = y, ymin = y - se * SEweight, ymax = y + se * SEweight),
                         position = position_dodge(width = dodgeVal), width = 0.1,
                         lwd = LWD, color = "black", alpha = 1)
  
  # -------------------------------------------------------------------------- #
  ## Individual data points:
  
  if (isPoint){
    cat("Add per-subject data points\n")
    ## Colored dots:
    p <- p + geom_point(data = aggrData, aes(x = xj, fill = x), shape = 21, size = 2, stroke = 1.2, # size = 0.6, 
                        color = "black", alpha = colAlpha)
    p <- p + scale_fill_manual(values = selCol, limits = levels(aggrData$x))
    ## Grey dots:
    # p <- p + geom_point(data = aggrData, aes(x = xj), shape = 21, size = 2, fill = NA, stroke = 1.5, # size = 0.6, 
    #                     color = "grey", alpha = colAlpha) # color = black, grey60,
  }
  
  if (isConnect){
    cat("Add line connections to per-subject data points\n")
    ## Connect colored dots:
    
    subVec <- sort(unique(aggrData$subject))
    nSub <- length(subVec)
    for(iSub in 1:nSub){
      subData <- subset(aggrData, subject == subVec[iSub])
      p <- p + geom_path(data = subData, aes(x = xj, y= y), color = 'grey40', # color = 'grey70'
                         alpha = 0.40, lwd = 0.5) # alpha = 0.80, lwd = 1
    }
  }
  
  if (isBeeswarm){
    p <- p + geom_beeswarm(data = aggrData, aes(x = xpos), shape = 1, size = 2, stroke = 1, # size = 0.6, 
                           color = "black", alpha = colAlpha)
  }
  
  # -------------------------------------------------------------------------- #
  ### Settings:
  
  ## Add horizontal lines:
  if (isMidLine){
    yMid <- (yLim[1] + yLim[2])/2
    p <- p + geom_hline(yintercept = yMid, linetype = 2, color = "black", linewidth = 1) # Middle line at 0
  }
  
  if (!(is.null(hLine))){
    p <- p + geom_hline(yintercept = hLine, linetype = 2, color = "black")
  }
  
  ## Y-axis labels:
  if (yLim[1] == 0 & yLim[2] == 1){
    p <- p + scale_y_continuous(breaks = seq(0, 1, by = 0.5)) # only 0, 0.5, 1 as axis labels
  }
  p <- p + coord_cartesian(ylim = yLim)
  
  ## Axis labels:
  p <- p + labs(x = xLab, y = yLab)
  
  # Add title:
  if (!(is.null(main))){
    cat("Add title\n")
    p <- p + ggtitle(main)  
  }
  
  ## Theme:
  p <- p + theme_classic()
  
  ## Font sizes:
  p <- p + theme(axis.text = element_text(size = FTS),
                 # axis.text.x = element_blank(), # remove x-axis labels
                 # axis.ticks.x = element_blank(), # remove x-axis labels
                 axis.title = element_text(size = FTS), 
                 title = element_text(size = FTS),
                 legend.position = "none",
                 axis.line = element_line(colour = 'black')) # , linewidth = LWD)) # fixed font sizes
  print(p)
  if(savePNG | saveEPS){
    dev.off(); 
    print(p)
  }
  if (saveSVG){save_plot(paste0(dirs$plot, plotName, ".svg"), fig = p, width = 20, height = 20)}
  if (savePDF){ggsave(paste0(dirs$plot, plotName, ".pdf"), plot = p, width = 20, height = 20, units = "cm")}
  return(p)
  cat("Finished :-)\n")
}

# ============================================================================ #
#### 26) Barplot 2 IVs: Aggregate per condition per subject, plot (2 IVs, 1 on x-axis, 1 as color): ####

custom_barplot2 <- function(data, xVar, yVar, zVar, subVar = "subject_n", 
                            xLab = NULL, yLab =  NULL, zLab = NULL, main = NULL,
                            selCol = NULL, 
                            isPoint = T, isConnect = T, isBeeswarm = F, addLegend = FALSE,
                            yLim = NULL, FTS = NULL, dotSize = NULL,
                            savePNG = F, saveEPS = F, saveSVG = F, savePDF = F, prefix = NULL, suffix = NULL){
  #' Make bar plots with 2 IVs: x-axis and color.
  #' @param data data frame, trial-by-trial data.
  #' @param xVar string, name of variable that goes on x-axis. If numeric, it will be converted to an (ordered) factor.
  #' @param yVar string, name of variable that goes on y-axis. Needs to be numeric.
  #' @param zVar string, name of variable that determines bar coloring. Needs to be a factor.
  #' @param subVar string, name of variable containing subject identifier (default: subject).
  #' @param xLab string, label for x-axis (default: retrieve appropriate name with substitute_label()).
  #' @param yLab string, label for y-axis (default: retrieve appropriate name with substitute_label()).
  #' @param zLab string, label for color legend (default: retrieve appropriate name with substitute_label()).
  #' @param main string, overall plot label (optional).
  #' @param selCol vector of strings (HEX colors), colors for bars (default: retrieve via retrieve_colour()).
  #' @param yLim vector of two numbers, y-axis (default: automatically determined by ggplot).
  #' @param isPoint Boolean, plot individual data points per condition as small points (default: TRUE).
  #' @param isConnect Boolean, connect individual data points with grey lines (default: FALSE).
  #' @param isBeeswarm Boolean, plot individual data points per condition as beeswarm density (default: FALSE).
  #' @param addLegend Boolean, add legend for z-axis (colour) (default: TRUE).
  #' @param FTS scalar integer, font size to use (default: 30).
  #' @param dotSize scalar integer, size of single-subject dots to use (default: 1).
  #' @param savePNG Boolean, save as .png file.
  #' @param saveEPS Boolean, save as .eps file.
  #' @param saveSVG Boolean, save as .svg file.
  #' @param savePDF Boolean, save as .pdf file.
  #' @param prefix string, string to add at the beginning of plot name (optional).
  #' @param suffix string, string to add at the end of plot name (optional).
  #' @return creates (and saves) plot.
  
  # xLab = NULL; yLab = NULL; zLab = NULL; main = NULL; selCol = NULL;
  # isPoint = T; isConnect = T; isBeeswarm = F; addLegend = TRUE; yLim = NULL; FTS = NULL; dotSize = NULL; savePNG = T; saveEPS = F; prefix = NULL; suffix = NULL
  
  # -------------------------------------------------------------------------- #
  ## Load packages:
  require(plyr) # for ddply
  require(Rmisc) # for summarySEwithin
  require(ggbeeswarm) # for ggbeeswarm
  
  # -------------------------------------------------------------------------- #
  ## Close any open plots:
  
  if (length(dev.list()!=0)){dev.off()}
  
  # -------------------------------------------------------------------------- #
  ## Check inputs:
  
  ## Input variables:
  if(!(yVar %in% names(data))){stop("yVar not found in data")}
  if(!(xVar %in% names(data))){stop("xVar not found in data")}
  if(!(zVar %in% names(data))){stop("zVar not found in data")}
  if(!(subVar %in% names(data))){stop("subVar not found in data")}
  
  if(is.numeric(data[, xVar])){data[, xVar] <- factor(data[, xVar]); cat("Convert xVar to factor\n")}
  
  ## Axis labels:
  if(is.null(xLab)){xLab <- substitute_label(xVar)}
  if(is.null(yLab)){yLab <- substitute_label(yVar)}
  if(is.null(zLab)){zLab <- substitute_label(zVar)}
  zLab <- gsub(" ", " \n", zLab) # add newline to any z-label
  
  # -------------------------------------------------------------------------- #
  ## Fixed plotting settings:
  
  LWD <- retrieve_plot_defaults("LWD") # 1.3
  if (is.null(FTS)){
    FTS <- retrieve_plot_defaults("FTS") # 30
    if (length(unique(data[, xVar])) > 10){FTS <- FTS/2; cat("Half font size because many x levels\n")}
  }
  if (is.null(dotSize)){
    dotSize <- retrieve_plot_defaults("dotSize") # 0.5
    if (length(unique(data[, xVar])) * length(unique(data[, zVar])) > 15){dotSize <- 0.5; cat("Lower dotSize from 1 to 0.5 because many x/z levels\n")}
  }
  
  dodgeVal <- 0.6
  colAlpha <- 1
  jitterSize <- 0.02 # used to be 0.05
  
  # -------------------------------------------------------------------------- #
  ## Create variables under standardized names:
  
  cat("Overall condition means (without first aggregating per subject):\n")
  print(tapply(data[, yVar], interaction(data[, zVar], data[, xVar]), mean, na.rm = T))
  
  cat("Create new variables x, y, z, subject based on inputs\n")
  data$x <- data[, xVar]
  data$y <- data[, yVar]
  data$z <- data[, zVar]
  data$subject <- data[, subVar]
  
  ## Exclude NAs:
  nRow1 <- nrow(data)
  data <- droplevels(subset(data, !(is.na(x)) & !(is.na(y)) & !(is.na(z))))
  nRow2 <- nrow(data)
  cat(paste0("Excluded ", nRow1 - nRow2, " rows due to NAs\n"))
  
  ## Colours:
  if(is.null(selCol)){
    selCol <- retrieve_colour(zVar)
    selCol <- rep(selCol, length.out = length(unique(data[, zVar])))
  }
  if(length(selCol) != length(unique(data[, zVar]))){
    stop(paste0("Length selCol = ", length(selCol), " while number levels zVar = ", length(unique(data[, zVar])), ", do not match"))
  }
  condCol <- rep(selCol, length(unique(data[, xVar])))
  
  # -------------------------------------------------------------------------- #
  ## Aggregate data per subject per condition:
  cat("Aggregate data per subject\n")
  aggrData <- ddply(data, .(subject, x, z), function(x){
    y <- mean(x$y, na.rm = T)
    return(data.frame(y))
    dev.off()})
  # Wide format: each subject/condition1/condition2 in one line, variables subject, x, y, z
  
  ## Add condition variable:
  cat("Create condition variable\n")
  nZlevel <- length(unique(data$z))
  posScale <- 0.48 * exp(-0.27 * nZlevel) # negative exponential function of # levels of zVar
  aggrData$cond <- as.numeric(aggrData$x)*nZlevel - nZlevel + as.numeric(aggrData$z) # necessary for proper axis positions
  nCond <- length(unique(aggrData$cond))
  if (length(condCol) < nCond){condCol <- rep(condCol, length.out = nCond)}
  
  ## Add jittered x-axis for points:
  cat("Add jitter for points\n")
  aggrData$j <- jitter(rep(0, nrow(aggrData)), amount = .05) # pure jitter .05
  
  ## X-axis position of each condition given x and y levels:
  zMid <- (min(as.numeric(data$z)) + max(as.numeric(data$z)))/2
  aggrData$xpos <- as.numeric(aggrData$x) - min(as.numeric(aggrData$x)) + 1 + ((as.numeric(aggrData$z) - zMid)) * posScale
  aggrData$xj <- aggrData$xpos + aggrData$j # add jitter to xpos
  
  # ## Add condition variable:
  # cat("Create condition variable\n")
  # nZlevel <- length(unique(data$z))
  # posScale <- 0.05 * (nZlevel + 1)
  # aggrData$cond <- as.numeric(aggrData$x)*nZlevel - nZlevel + as.numeric(aggrData$z) # necessary for proper axis positions
  # # aggrData$cond <- 1 + as.numeric(aggrData$x)*2 + as.numeric(aggrData$z)
  # nCond <- length(unique(aggrData$cond))
  # if (length(condCol) < nCond){condCol <- rep(condCol, length.out = nCond)}
  # 
  # ## Add jittered x-axis for points:
  # cat("Add jitter for points\n")
  # aggrData$j <- jitter(rep(0, nrow(aggrData)), amount = jitterSize) # pure jitter .05
  # if (nZlevel == 2){
  #   aggrData$xpos <- as.numeric(aggrData$x) - min(as.numeric(aggrData$x)) + 1 + (as.numeric(aggrData$z) - 1.5) * 2 * posScale # convert to [1 2], to [-0.5 0.5], * 2 so [-1 1], scale by 0.15
  # } else if (nZlevel == 3) {
  #   zMid <- round(mean(as.numeric(data$z)))
  #   aggrData$xpos <- as.numeric(aggrData$x) - min(as.numeric(aggrData$x)) + 1 + ((as.numeric(aggrData$z) - zMid)) * posScale  # demean, scale by 0.20
  # } else {
  #   zMid <- round(mean(as.numeric(data$z)))
  #   zScale <- ceiling(max(as.numeric(data$z))) - zMid
  #   aggrData$xpos <- as.numeric(aggrData$x) - min(as.numeric(aggrData$x)) + 1 + ((as.numeric(aggrData$z) - zMid)) * zScale * posScale  # demean, bring min/max to 1, scale by 0.20
  #   warning(paste0("Not yet implement for z variable with ", nZlevel, " levels\n"))
  # }
  # aggrData$xj <- aggrData$xpos + aggrData$j # add jitter to xpos
  
  ## Determine y limits if not given:
  if(is.null(yLim)){
    cat("Automatically determine y-axis limits based on per-subject-per-condition means\n")
    yLim <- determine_ylim_data_y(aggrData)
  }
  
  # -------------------------------------------------------------------------- #
  ## Aggregate across subjects with Rmisc:
  cat("Aggregate data across subjects\n")
  summary_d <- summarySEwithin(aggrData, measurevar = "y", idvar = "subject", na.rm = T,
                               withinvars = c("x", "z"))
  # Aggregated over subjects, one row per condition, variables x, z, N, y, sd, se, ci
  
  # -------------------------------------------------------------------------- #
  ### Start plot:
  
  ## Additions:
  # prefix <- NULL; suffix <- NULL
  if(is.null(prefix)){prefix <- ""} else {prefix <- paste0(prefix, "_")}
  if(is.null(suffix)){suffix <- ""} else {suffix <- paste0("_", suffix)}
  
  ## Name:
  plotName <- paste0("custombarplot2_", prefix, yVar, "_", xVar, "_", zVar)
  if (isPoint){plotName <- paste0(plotName, "_points")} 
  if (isBeeswarm){plotName <- paste0(plotName, "_beeswarm")} 
  plotName <- paste0(plotName, suffix)
  cat(paste0("Start plot ", plotName, "\n"))
  
  ## Saving:
  if (saveEPS){cat("Save as eps\n"); setEPS(); postscript(paste0(dirs$plotDir, plotName, ".eps"), width = 480, height = 480)}
  if (savePNG){cat("Save as png\n"); png(paste0(dirs$plotDir, plotName, ".png"), width = 480, height = 480)}
  
  ## Start plot:
  p <- ggplot(summary_d, aes(x, y, fill = z))
  
  ## Bars of means:
  cat("Add bars\n")
  p <- p + stat_summary(fun = mean, geom = "bar", position = "dodge", width = dodgeVal,
                        lwd = LWD, color = "black")
  
  ## Error bars:
  cat("Add error bars\n")
  p <- p + geom_errorbar(data = summary_d,
                         aes(x = x, y = y, ymin = y - se, ymax = y + se),
                         position = position_dodge(width = dodgeVal), width = 0.2,
                         lwd = LWD, color = "black", alpha = 1)
  
  # Individual data points:
  if (isPoint){
    cat("Start adding per-subject points \n")
    for(iCond in 1:nCond){ # add separately per condition
      p <- p + geom_point(data = aggrData[aggrData$cond == iCond, ],
                          aes(x = xj), # position = "dodge",
                          shape = 21, size = 2, stroke = 1.2, color = "black", fill = condCol[iCond],
                          alpha = 0.5) # colAlpha)
    }
  }
  
  ## Connect colored dots:
  if (isConnect){
    cat("Start connecting per-subject points \n")
    
    subVec <- sort(unique(aggrData$subject))
    nSub <- length(subVec)
    
    for(iSub in 1:nSub){ # iSub <- 1
      subData <- subset(aggrData, subject == subVec[iSub])
      p <- p + geom_path(data = subData, aes(x = xj, y = y, group = 1), color = 'grey40', # color = 'grey70'
                         alpha = 0.50, size = dotSize) # consider alpha = 0.80
    }
  }  
  
  ## Beeswarm style plots:
  if (isBeeswarm){
    cat("Start adding beeswarm \n")
    for(iCond in 1:nCond){ # add separately per condition
      p <- p + geom_beeswarm(data = aggrData[aggrData$cond == iCond, ],
                             aes(x = xpos), # position = "dodge",
                             # priority = "ascending",
                             shape = 21, size = 2, stroke = 1.2, color = "black", fill = condCol[iCond],
                             alpha = 0.5) # colAlpha)
    }
  }
  
  # Add title:
  if (!(is.null(main))){
    cat("Add title\n")
    p <- p + ggtitle(main)  
  }
  
  # Settings:
  if (yLim[1] == 0 & yLim[2] == 1){
    cat("Add y-axis ticks for 0, 0.5, 1\n")
    # p <- p + scale_y_break(c(0, 0.5, 1))
    p <- p + scale_y_continuous(breaks = seq(0, 1, by = 0.5)) # only 0, 0.5, 1 as axis labels
  }
  if(!(is.null(yLim))){p <- p + coord_cartesian(ylim = yLim)}
  # if(!(is.null(yLim))){p <- p + scale_y_continuous(limits = yLim, breaks = seq(yLim[1], yLim[-1], (yLim[-1] - yLim[1])/2))}
  
  # Add theme, font sizes:
  cat("Add axis labels, colors, theme, font sizes\n")
  require(ggthemes)
  p <- p + labs(x = xLab, y = yLab, fill = zLab) +
    scale_fill_manual(values = selCol, limits = levels(summary_d$z)) + 
    theme_classic() + 
    theme(axis.text = element_text(size = FTS),
          axis.title = element_text(size = FTS), 
          plot.title = element_text(size = FTS, hjust = 0.5), 
          axis.line = element_line(colour = 'black')) # , linewidth = LWD)) # fixed font sizes
  
  ## Add legend:
  if (addLegend){
    p <- p + theme(
      legend.text = element_text(size = FTS),
      legend.title = element_text(size = FTS)
    )
  } else {
    p <- p + theme(
      legend.title = element_blank(), legend.position = "none"
    )
  }
  
  print(p)
  if(savePNG | saveEPS){dev.off(); print(p)}
  if (saveSVG){save_plot(paste0(dirs$plot, plotName, ".svg"), fig = p, width = 20, height = 20)}
  if (savePDF){ggsave(paste0(dirs$plot, plotName, ".pdf"), plot = p, width = 20, height = 20, units = "cm")}
  cat("Finished :-)\n")
  return(p)
}

# ============================================================================ #
#### 27) Barplot 3 IVs: Aggregate per condition per subject, plot (3 IVs, 1 on x-axis, 1 as color, 1 as facets): ####

custom_barplot3 <- function(data, yVar, xVar, zVar, splitVar, subVar = "subject_n", 
                            yLab = NULL, xLab = NULL, zLab = NULL, main = NULL,
                            xLevels = NULL, zLevels = NULL, splitLevels = NULL,
                            selCol = NULL, isPoint = T, addLegend = T, 
                            yLim = NULL,  FTS = NULL, LWD = NULL,
                            savePNG = F, saveEPS = F, saveSVG = F, savePDF = F, prefix = NULL, suffix = NULL){
  #' Make bar plots with 3 IVs: x-axis and color and facetwrap.
  #' Can add points with geom_point, 
  #' but not beeswarm plots because no position argument (hence no dodge) and manual x-position not compatible with facet_wrap.
  #' Note: In order to get the order of bars (from left to right) correctly, all factors are recoded into values from
  #' (nLevels - 1) to 0 in descending order. Later, factor levels are added again in the correct order.
  #' Check in print out if relabeling is done correctly!
  #' @param data data frame, trial-by-trial data.
  #' @param yVar string, name of variable that goes on y-axis. Needs to be numeric.
  #' @param xVar string, name of variable that goes on x-axis. If numeric, it will be converted to an (ordered) factor.
  #' @param zVar string, name of variable that determines bar coloring. Needs to be a factor.
  #' @param splitVar string, name of variable by which to split plot (facetwrap, optional).
  #' @param subVar string, name of variable containing subject identifier (default: subject).
  #' @param xLab string, label for x-axis (default: retrieve appropriate name with substitute_label()).
  #' @param yLab string, label for y-axis (default: retrieve appropriate name with substitute_label()).
  #' @param zLab string, label for color legend (default: retrieve appropriate name with substitute_label()).
  #' @param main string, title of plot (optional).
  #' @param xLevels string, level names for x-axis (default: retrieve from xVar in alphabetical order).
  #' @param zLevels string, level names for x-axis (default: retrieve from zVar in alphabetical order).
  #' @param splitLevels string, level names for x-axis (default: retrieve from splitVar in alphabetical order).
  #' @param selCol vector of strings (HEX colors), colors for bars (default: retrieve via retrieve_colour()).
  #' @param isPoint Boolean, plot individual data points per condition as small points (default: TRUE).
  #' @param addLegend Boolean, add legend for z-axis (colour) (default: TRUE).
  #' @param yLim vector of two numbers, y-axis (default: automatically determined by ggplot).
  #' @param FTS scalar integer, font size to use for axis labels and title (optional).
  #' @param LWD scalar integer, line width used for axis and bars in plot (optional). 
  #' @param suffix string, string to add at the end of plot name (optional).
  #' @param savePNG Boolean, save as .png file.
  #' @param saveEPS Boolean, save as .eps file.
  #' @param saveSVG Boolean, save as .svg file.
  #' @param savePDF Boolean, save as .pdf file.
  #' @return creates (and saves) plot.  #' Make bar plot per subject
  #' @param data data frame, with variables \code{variables}
  
  # yLab = NULL; xLab = NULL; zLab = NULL; main = NULL;
  # xLevels = NULL; zLevels = NULL; splitLevels = NULL;
  # selCol = NULL; isPoint = F; yLim = NULL; savePNG = T; saveEPS = F
  
  # -------------------------------------------------------------------------- #
  ### Load packages:
  
  require(ggplot2) # for ggplot
  require(ggthemes) # for theme_classic()
  require(ggbeeswarm) # for ggbeeswarm
  require(plyr) # for ddply
  require(Rmisc) # for summarySEwithin
  
  # -------------------------------------------------------------------------- #
  ### Close any open plots:
  
  if (length(dev.list() != 0)){dev.off()}
  
  # -------------------------------------------------------------------------- #
  ### Check inputs:
  
  ## Check if input variables included in data set:
  if(!(is.data.frame((data)))){stop("data must be a data frame")}
  if(!(yVar %in% names(data))){stop("yVar not found in data")}
  if(!(xVar %in% names(data))){stop("xVar not found in data")}
  if(!(zVar %in% names(data))){stop("zVar not found in data")}
  if(!(splitVar %in% names(data))){stop("splitVar not found in data")}
  if(!(subVar %in% names(data))){stop("subVar not found in data")}
  
  ## Check variable types:
  if(!(is.numeric(data[, yVar]))){stop("yVar has to be numeric")}
  if(!(is.factor(data[, xVar]))){stop("xVar has to be a factor")}
  if(!(is.factor(data[, zVar]))){stop("zVar has to be a factor")}
  if(!(is.factor(data[, splitVar]))){stop("splitVar has to be a factor")}
  
  ## Retrieve axis labels:
  if(is.null(xLab)){xLab <- substitute_label(xVar)}
  if(is.null(yLab)){yLab <- substitute_label(yVar)}
  if(is.null(zLab)){zLab <- substitute_label(zVar)}
  zLab <- gsub(" ", " \n", zLab) # add newline to any z-label
  if(!(is.character(xLab))){stop("xLab has to be a character string")}
  if(!(is.character(yLab))){stop("yLab has to be a character string")}
  if(!(is.character(zLab))){stop("zLab has to be a character string")}
  
  ## Exclude any rows with NAs: 
  rowIdx <- which(complete.cases(data[, xVar]) & complete.cases(data[, yVar]) & complete.cases(data[, zVar]) & complete.cases(data[, splitVar]))
  cat(paste0("Excluding rows with NA on xVar or yVar or zVar or splitVar: Retain ", length(rowIdx), " out of ", nrow(data), " rows (excluded ", nrow(data) - length(rowIdx), " rows)\n"))
  data <- droplevels(data[rowIdx, ])
  
  # -------------------------------------------------------------------------- #
  ### General plotting settings:
  
  ## Colours (must be determined after NA exclusion):
  if(is.null(selCol)){
    selCol <- retrieve_colour(zVar)
    selCol <- rep(selCol, length.out = length(unique(data[, zVar]))) # copy as often as necessary
  }
  if(length(selCol) != length(unique(data[, zVar]))){
    stop(paste0("Length selCol = ", length(selCol), " while number levels zVar = ", length(unique(data[, zVar])), ", do not match"))
  }
  condCol <- rep(selCol, length(unique(data[, xVar])))
  
  ## Font size: 
  if(is.null(FTS)){FTS <- retrieve_plot_defaults("FTS")} # 15 # 30
  
  ## Line width:
  if(is.null(LWD)){LWD <- retrieve_plot_defaults("LWD")} # 1.3 # 1.5
  # if (savePNG | saveEPS){FTS <- retrieve_plot_defaults("FTS")} else {FTS <- 15} # 30
  
  ## Other settings:
  dodgeVal <- 0.6 # displacement of dots
  barWidth <- 0.15 # width of error bars
  colAlpha <- 0.6 # transparency of dots
  
  SEweight <- 1.96 # weight for error bars
  isPrint <- T # print data sets to check proper recoding
  
  # -------------------------------------------------------------------------- #
  ### Create variables under standardized names:
  
  cat("Create new numerical variables x, y, z, subject based on inputs\n")
  data$y <- data[, yVar]
  data$x <- as.numeric(data[, xVar]) # convert to numeric
  data$z <- as.numeric(data[, zVar]) # convert to numeric
  if (!is.null(splitVar)){data$split <- as.numeric(data[, splitVar])} # convert to numeric
  data$subject <- data[, subVar]
  
  ## Determine level names if not set as input:
  if(is.null(xLevels)){xLevels <- as.character(levels(data[, xVar])); cat(paste0("Original levels of xVar are: ", paste0(xLevels, collapse = ", "), "\n"))}
  if(is.null(zLevels)){zLevels <- as.character(levels(data[, zVar])); cat(paste0("Original levels of zVar are: ", paste0(zLevels, collapse = ", "), "\n"))}
  # if (!all(levels(data[, zVar]) == sort(levels(data[, zVar])))){zLevels <- rev(zLevels); cat("Factor levels of zVar not in alphabetical order, invert\n")} # invert levels of z if factor levels not in alphabetical order
  if(is.null(splitLevels)){
    splitLevels <- sort(unique(data[, splitVar]))
    cat(paste0("Original levels of splitVar are: ", paste0(splitVar, collapse = ", "), "\n"))
    # if (!all(levels(data[, splitVar]) == sort(levels(data[, splitVar])))){splitLevels <- rev(splitLevels); cat("Factor levels of splitVar not in alphabetical order, invert\n")} # invert levels of split if factor levels not in alphabetical order
  }
  
  # -------------------------------------------------------------------------- #
  ### Recode to 0 until (nLevels - 1) for combining into condition variable:
  
  ## X-axis levels:
  xLevelVec <- sort(unique(data$x)) # levels
  nXlevels <- length(xLevelVec) # number of levels
  if (isPoint & nXlevels > 3){stop("Points not implemented for x variable with > 3 levels")}
  
  ## Z-axis levels:
  zLevelVec <- sort(unique(data$z)) # levels
  nZlevels <- length(zLevelVec) # number of levels
  if (isPoint & nZlevels > 2){stop("Points not implemented for z variable with > 2 levels")}
  
  ## Recode variables to go from (nLevels - 1) till 0 in descending order:
  data$x <- nXlevels - data$x # recode to (nXlevels - 1) to 0 in descending order
  data$z <- nZlevels - data$z # recode to (nXlevels - 1) to 0 in descending order
  xLevelVec <- rev(sort(unique(data$x))) # update, descending order
  zLevelVec <- rev(sort(unique(data$z))) # update, descending order
  
  if (!is.null(splitVar)){
    sLevelVec <- sort(unique(data$split))
    nSlevels <- length(sLevelVec)
    if (isPoint & nSlevels > 3){stop("Points not implemented for split variable with > 2 levels")}
    data$split <- max(data$split) - data$split # recode to (nXlevels - 1) to 0 in reverse order
    sLevelVec <- rev(sort(unique(data$split))) # update, descending order
  } # to 0 - 1
  
  ## Print recoding of factor levels into descending numbers to console: 
  if(isPrint){cat(paste0("\nMapping of original variable ", xVar, " (rows) on numeric variable x (columns; from 0 - (nLevels - 1)):\n")); print(table(data[, xVar], data$x))} # 1-N becomes (N-1)-0
  if(isPrint){cat(paste0("\nMapping of original variable ", zVar, " (rows) on numeric variable z (columns; from 0 - (nLevels - 1)):\n")); print(table(data[, zVar], data$z))} # 1-N becomes (N-1)-0
  if(isPrint & !is.null(splitVar)){cat(paste0("\nMapping of original variable ", splitVar, " (rows) on numeric variable split (columns; from 0 - (nLevels - 1)):\n")); print(table(data[, splitVar], data$split))} # # 1-N becomes (N-1)-0
  
  # -------------------------------------------------------------------------- #
  ### Combine into single condition variable:
  
  if (!is.null(splitVar)){ # if splitVar: 8 conditions
    # z is fastest changing variable, then x, then split
    data$condition <- 1 + data$split*nXlevels*nZlevels + data$x*nZlevels + data$z
  } else { # No splitVar: 4 conditions
    data$condition <- 1 + data$x*nZlevels + data$z
  }
  nCondExp <- nXlevels * nZlevels * nSlevels
  cat(paste0("Expected ", nCondExp, " levels of condition variable (namely ", nXlevels, " levels for xVar x ", nZlevels, " levels for zVar x ", nSlevels, " levels for splitVar)\n"))
  condVec <- sort(unique(data$condition))
  nCond <- length(condVec)
  if(nCondExp != nCond){cat(paste0("Found only ", nCond, " conditions: ", paste0(condVec, collapse = ", "), "\n"))}
  # stopifnot(min(data$condition) == 1)
  # stopifnot(max(data$condition) == nCond)
  
  # sort(unique(data$condition)) # from 1 to nCond
  # table(data$condition, data$split) # slowest factor, everything nXlevels*nZlevels times, from 0-nSlevels in ascending order
  # table(data$condition, data[, splitVar]) # slowest factor, everything nXlevels*nZlevels times, from nSlevels-0 in descending order
  # table(data$condition, data$x) # middle factor, everything nZlevels times, from 0-nXlevels in ascending order
  # table(data$condition, data[, xVar]) # middle factor, everything nZlevels times, from nXlevels-0 in descending order
  # table(data$condition, data$z) # fastest factor, odd and even, from 0-nZlevels in ascending order
  # table(data$condition, data[, zVar]) # fastest factor, odd and even, from nZlevels-0 in descending order
  
  # -------------------------------------------------------------------------- #
  ## Aggregate data per subject per condition:
  
  cat("Aggregate data per subject\n")
  aggrData <- ddply(data, .(subject, condition), function(x){
    y <- mean(x$y, na.rm = T)
    return(data.frame(y))
    dev.off()})
  
  ## Recover original variables:
  aggrData$z <- (aggrData$condition - 1) %% nZlevels # fastest factor, odd or even
  aggrData$x <- (ceiling(aggrData$condition/nZlevels) - 1) %% nXlevels # middle factor, everything nZlevels times 
  if (!is.null(splitVar)){
    aggrData$split <- ceiling(aggrData$condition/(nXlevels*nZlevels) - 1)
  }
  
  # print(head(aggrData, n = nCond)) # needs to match condition meaning in data object above
  # table(aggrData$condition, aggrData$split) # slowest factor, everything nXlevels*nZlevels times, from 0-nSlevels in ascending order
  # table(aggrData$condition, aggrData$x) # middle factor, everything nZlevels times, from 0-nXlevels in ascending order
  # table(aggrData$condition, aggrData$z) # fastest factor, odd and even, from 0-nZlevels in ascending order
  
  ### Create factors:
  ## Reverse above inversion: xLevelVec is inverted, but xLevels the right way around
  aggrData$x_f <- factor(aggrData$x, levels = xLevelVec, labels = xLevels) # assign factor levels to numerics (in descending order) 
  aggrData$z_f <- factor(aggrData$z, levels = zLevelVec, labels = zLevels) # assign factor levels to numerics (in descending order)
  if (!is.null(splitVar)){aggrData$split_f <- factor(aggrData$split, levels = sLevelVec, labels = splitLevels)} # assign factor levels to numerics (in descending order)
  
  cat(paste0("Assume new factor levels ", paste0(xLevelVec, collapse = ", "), " corresponds to original factor levels ", paste0(xLevels, collapse = ", "), "\n"))
  cat(paste0("Assume new factor levels ", paste0(zLevelVec, collapse = ", "), " corresponds to original factor levels ", paste0(zLevels, collapse = ", "), "\n"))
  if (!is.null(splitVar)){cat(paste0("Assume new factor levels ", paste0(sLevelVec, collapse = ", "), " corresponds to original factor levels ", paste0(splitLevels, collapse = ", "), "\n"))}
  
  if(isPrint){
    cat("\nHead of data file with condition mean per subject; check correspondence of condition to x, z, split:\n")
    print(head(aggrData[, c("subject", "condition", "y", "x", "x_f", "z", "z_f", "split", "split_f")], n = nCond))
  } # needs to match condition meaning in data object above
  
  # -------------------------------------------------------------------------- #
  ### Determine y limits if not given:
  
  if(is.null(yLim)){
    cat("Automatically y-axis limits based on per-subject-per-condition means\n")
    yLim <- c(floor(min(aggrData[, yVar])), ceiling(max(aggrData[, yVar])))
  }
  if (length(yLim) != 2){stop("yLim must be of length 2")}
  
  # -------------------------------------------------------------------------- #
  ### Aggregate across subjects with Rmisc:
  cat("Aggregate data across subjects\n")
  
  d <- summarySEwithin(aggrData, measurevar = "y", withinvar = "condition", idvar = "subject", na.rm = T)
  d$condition <- condVec # condition will be from 1 to nCond found; instead overwrite with empirical conditions from previous data set
  # d$condition <- as.numeric(as.factor(d$condition)) # condition back to numeric
  # condVec <- sort(unique(d$condition))
  # nCond <- length(unique(condVec))
  # cat(paste0("Expected ", nCondExp, " condition levels; found ", nCond, " condition levels, namely ", paste0(condVec, collapse = ", "), "\n"))
  
  ## Recover independent variables from condition:
  d$z <- (d$condition - 1) %% nZlevels # fastest variable
  d$x <- ceiling(d$condition/nZlevels - 1) %% nXlevels # intermediate variable
  if (!is.null(splitVar)){
    d$split <- ceiling(d$condition/(nXlevels*nZlevels) - 1) # slowest variable
  }
  
  # print(d)
  
  ## Create factors:
  d$x_f <- factor(d$x, levels = xLevelVec, labels = xLevels)
  d$z_f <- factor(d$z, levels = zLevelVec, labels = zLevels)
  if (!is.null(splitVar)){d$split_f <- factor(d$split, levels = sLevelVec, labels = splitLevels)}
  
  if(isPrint){
    cat("\nAggregated data file, check correspondence of x, z, split to factor labels\n")
    print(d[, c("condition", "N", "y", "sd", "se", "ci", "x", "x_f", "z", "z_f", "split", "split_f")])
  }
  
  ## Check if y +/- se within ylim:
  if (any(d$y - d$se < yLim[1], na.rm = T)){warning("Lower error bars will exceed y-axis limit")}
  if (any(d$y + d$se > yLim[2], na.rm = T)){warning("Upper error bars will exceed y-axis limit")}
  
  # -------------------------------------------------------------------------- #
  # -------------------------------------------------------------------------- #
  # -------------------------------------------------------------------------- #
  ## Start plot:
  
  ## Name:
  plotName <- paste0("custombarplot3_",  yVar, "~", xVar, "_", zVar, "_")
  if (!(is.null(splitVar))){plotName <- paste0(plotName, splitVar)}
  if (isPoint){plotName <- paste0(plotName, "_points")} 
  if(is.null(suffix)){suffix <- ""} else {suffix <- paste0("_", suffix)}
  plotName <- paste0(plotName, suffix)  
  cat(paste0("Start plot ", plotName, "\n"))
  
  ## Initialize ggplot object:
  p <- ggplot(d, aes(x = x_f, y = y, fill = z_f))
  
  ## Add bars of means:
  cat("Add bars\n")
  p <- p + geom_bar(position = "dodge", stat = "summary", fun = "identity",
                    color = "black", width = dodgeVal, lwd = LWD)
  
  ## Add error bars:
  cat("Add error bars\n")
  p <- p + geom_errorbar(data = d,
                         aes(x = x_f, y = y, ymin = y - se, ymax = y + se),
                         position = position_dodge(width = dodgeVal), width = barWidth,
                         lwd = LWD, color = "black", alpha = 1)
  
  ## Add individual data points:
  if (isPoint){
    cat("Start adding per-subject points \n")
    p <- p + geom_point(data = aggrData,
                        position = position_dodge(width = dodgeVal),
                        shape = 21, size = 2, stroke = 1.2, color = "black",
                        alpha = 0.5) 
  }
  
  ## Add facet wrap:
  if (!is.null(splitVar)){
    cat("Start adding facet_wrap\n")
    p <- p + facet_wrap(vars(split_f))
  }
  
  ## Add y-axis limits:
  cat("Start adding y-axis ticks\n")
  p <- p + scale_y_continuous(breaks = seq(yLim[1], yLim[-1], (yLim[-1] - yLim[1])/2)) 
  p <- p + coord_cartesian(ylim = yLim)
  
  ## Add labels:
  cat("Start labels\n")
  if (addLegend){
    p <- p + labs(x = xLab, fill = zLab, y = yLab)
  } else {
    p <- p + labs(x = xLab, y = yLab)
  }
  
  ## Add color:
  cat("Start colors for fill\n")
  p <- p + scale_fill_manual(values = rep(selCol, 4), limits = levels(d$z_f))
  
  ## Add theme:
  cat("Start theme\n")
  p <- p + theme_classic()
  
  # Add title:
  if (!(is.null(main))){
    cat("Add title\n")
    p <- p + ggtitle(main)  
  }
  
  ## Add font sizes:
  cat("Start line width and font size \n")
  p <- p + theme(axis.line = element_line(colour = 'black'), # linewidth = LWD),
                 axis.text = element_text(size = FTS),
                 axis.title = element_text(size = FTS), 
                 plot.title = element_text(size = FTS, hjust = 0.5), # center title 
                 strip.text.x = element_text(size = FTS)) # facetwrap FTS
  
  if (addLegend){
    p <- p + theme(legend.title = element_text(size = FTS),
                   legend.text = element_text(size = FTS))
  } else {
    p <- p + theme(legend.position = "none",
                   legend.title = element_blank(),
                   legend.text = element_blank())
  }
  
  ## Save if requested:
  if (savePNG){
    plotNameFull <- paste0(dirs$plotDir, plotName, ".png")
    cat(paste0("Save as ", plotNameFull, "\n"))
    png(plotNameFull, width = 480, height = 480)
    print(p)
    dev.off()
  }  
  ## Save if requested:
  if (saveEPS){
    plotNameFull <- paste0(dirs$plotDir, plotName, ".eps")
    cat(paste0("Save as ", plotNameFull, "\n"))
    setEPS(); postscript(plotNameFull, width = 480, height = 480)
    print(p)
    dev.off()
  }
  if (saveSVG){save_plot(paste0(dirs$plot, plotName, ".svg"), fig = p, width = 20, height = 20)}
  if (savePDF){ggsave(paste0(dirs$plot, plotName, ".pdf"), plot = p, width = 20, height = 20, units = "cm")}
  
  ## Print to console:
  print(p)
  
  ## Return:
  cat("Finished :-)\n")
  return(p)
  
} # end of function

# ============================================================================ #
#### 28) Lineplot 1 IV: Aggregate per time point per condition per subject, plot (1 IV for any condition, time on x-axis): ####

custom_lineplot <- function(data, xVar = "counter", yVar = "response_cleaned", zVar = "condition_f", subVar = "subject_n", 
                            xLab = "Time (trial number)", yLab = "p(Go)", main = "",
                            selCol = c("#009933", "#CC0000", "#009933", "#CC0000"), selLineType = c(1, 1, 2, 2),
                            SEweight = 1, yLim = NULL, savePNG = F, saveEPS = F){
  #' Make line plot with group-level and individual lines.
  #' @param data data frame, trial-by-trial data.
  #' @param xVar string, name of variable that goes on x-axis. Variable needs to be numeric.
  #' @param yVar string, name of variable that goes on y-axis. Variable needs to be numeric.
  #' @param zVar string, name of variable that determines bar coloring. Variable needs to be a factor.
  #' @param subVar string, name of variable containing subject identifier (default: subject).
  #' @param xLab string, label for x-axis (default: "x").
  #' @param yLab string, label for y-axis (default: "y").
  #' @param main string, title of plot (optional).
  #' @param selCol vector of strings (HEX colors), colors for input levels of zVar (default: c("#009933", "#CC0000", "#009933", "#CC0000")).
  #' @param selLineType vector of numerics, line types to use (default: c(1, 1, 2, 2))
  #' @param SEweight scalar, weight to use for error shades (how many times SE; default: 1).
  #' @param yLim vector of two numbers, y-axis (default: NULL).
  #' @param savePNG Boolean, save as .png file.
  #' @param saveEPS Boolean, save as .eps file.
  #' @return creates (and saves) plot.
  
  # -------------------------------------------------------------------------- #
  ## Load packages:
  require(plyr) # for ddply
  require(Rmisc) # for summarySEwithin
  
  # -------------------------------------------------------------------------- #
  ## Fixed plotting settings:
  LWD <- retrieve_plot_defaults("LWD") * 2 # 3 # axes of plot
  CEX <- 1.5 # axes ticks and labels
  lineWidth <- retrieve_plot_defaults("LWD") * 2 # 3
  FTS <- retrieve_plot_defaults("FTS")
  dodgeVal <- retrieve_plot_defaults("dodgeVal")
  colAlpha <- 1
  
  # -------------------------------------------------------------------------- #
  ## Create variables under standardized names:
  data$x <- data[,xVar]
  data$y <- data[,yVar]
  data$z <- data[,zVar]
  data$subject <- data[,subVar]
  
  # -------------------------------------------------------------------------- #
  ## Aggregate data:
  aggrData <- ddply(data, .(subject, x, z), function(x){
    y <- mean(x$y, na.rm = T)
    return(data.frame(y))
    dev.off()})
  # Wide format: each subject/x condition/z condition in one line, variables subject, x, y, z
  
  ## Determine y limits if not given:
  if(is.null(yLim)){
    yLim <- determine_ylim_data_y(aggrData)
  }
  
  # -------------------------------------------------------------------------- #
  ## Aggregate across subjects with Rmisc:
  summary_d <- summarySEwithin(aggrData, measurevar = "y", idvar = "subject", na.rm = T,
                               withinvars = c("x", "z"))
  # Aggregated over subjects, one row per condition, variables x, z, N, y, sd, se, ci
  
  # -------------------------------------------------------------------------- #
  ## Data dimensions:
  xVec <- unique(sort(as.numeric(summary_d$x)))
  xMax <- max(xVec)
  condNames <- unique(summary_d$z)
  nCond <- length(unique(summary_d$z))
  
  # -------------------------------------------------------------------------- #
  ## Plot name:
  
  plotName <- paste0("lineplot_",yVar, "_",xVar, "_",zVar)
  
  # -------------------------------------------------------------------------- #
  # Saving:
  
  if (saveEPS){cat("Save as eps\n"); setEPS(); postscript(paste0(dirs$plot, plotName, ".eps"), width = 480, height = 480)}
  if (savePNG){cat("Save as png\n"); png(paste0(dirs$plot, plotName, ".png"), width = 480, height = 480)}
  
  # -------------------------------------------------------------------------- #
  ### Start plot:
  
  par(mar = c(5.1, 5.1, 4.1, 2.1)) # bottom, left, top, right
  
  # dev.off()
  for (iCond in 1:nCond){ # iCond <- 1
    condName <- condNames[iCond] # name of condition
    yVec <- summary_d$y[summary_d$z == condName] # y-variable
    seVec <- summary_d$se[summary_d$z == condName] # se variable
    plot(xVec, yVec, type = "l", 
         col = selCol[iCond], lty = selLineType[iCond], axes = F,
         lwd = LWD, cex.lab = CEX, cex.axis = CEX, cex.main = CEX,
         xlab = xLab, ylab = yLab, main = main,
         xlim = c(0, xMax), ylim = yLim)
    axis(side = 1, lwd = LWD, cex.axis = CEX, at = seq(0,xMax, 5), line = 0)
    axis(side = 2, lwd = LWD, cex.axis = CEX, at = c(0, 0.5, 1))
    polygon(c(xVec,rev(xVec)),
            c(yVec-SEweight*seVec,rev(yVec+SEweight*seVec)),col = alpha(selCol[iCond],0.2), border = F)
    par(new = TRUE)
    
  }
  
  # Add legend:
  legend("top", legend=condNames,
         col=selCol, lty = selLineType, border = 0, lwd = LWD, cex = CEX, horiz=TRUE, bty = "n")
  
  if(savePNG | saveEPS){dev.off()}
  par(mar = c(5.1, 4.1, 4.1, 2.1)) # bottom, left, top, right
  
}

# ============================================================================ #
#### 29) Lineplot 1 IV with ggplot: Aggregate per time point per condition per subject, plot (1 IV for any condition, time on x-axis): ####

custom_lineplot_gg <- function(data, xVar, yVar, zVar, subVar = "subject_n", 
                               xLab = NULL, yLab = NULL, main = NULL,
                               selCol = NULL, selLineType = c(1), breakVec = NULL,
                               prefix = NULL, suffix = NULL,
                               SEweight = 1, yLim = NULL, addLegend = F, 
                               savePNG = F, saveEPS = F, saveSVG = F, savePDF = F){
  #' Make line plot with group-level lines plus shades in ggplot.
  #' @param data data frame, trial-by-trial data.
  #' @param xVar string, name of variable that goes on x-axis. Variable needs to be numeric.
  #' @param yVar string, name of variable that goes on y-axis. Variable needs to be numeric.
  #' @param zVar string, name of variable that determines bar coloring. Variable needs to be a factor.
  #' @param subVar string, name of variable containing subject identifier (default: subject).
  #' @param xLab string, label for x-axis (default: retrieve appropriate name with substitute_label()).
  #' @param yLab string, label for y-axis (default: retrieve appropriate name with substitute_label()).
  #' @param main string, overall plot label (optional).
  #' @param selCol vector of strings (HEX colors), colors for bars (default: retrieve via retrieve_colour()).
  #' @param selLineType vector of numerics, line types to use (default: c(1, 1, 2, 2))
  #' @param SEweight scalar, weight to use for error shades (how many times SE; default: 1).
  #' @param yLim vector of two numbers, y-axis (default: NULL).
  #' @param addLegend Boolean, add legend at the top or not (default: FALSE).
  #' @param savePNG Boolean, save as .png file (default: FALSE).
  #' @param saveEPS Boolean, save as .eps file (default: FALSE).
  #' @param saveSVG Boolean, save as .svg file (default: FALSE).
  #' @param savePDF Boolean, save as .pdf file (default: FALSE).
  #' @return creates (and saves) plot.
  
  # -------------------------------------------------------------------------- #
  ## Load packages:
  require(plyr) # for ddply
  require(Rmisc) # for summarySEwithin
  
  # -------------------------------------------------------------------------- #
  ## Close any open plots:
  
  if (length(dev.list()!=0)){dev.off()}
  
  # -------------------------------------------------------------------------- #
  ## Check inputs:
  
  ## Input variables:
  if(!(yVar %in% names(data))){stop("yVar not found in data")}
  if(!(xVar %in% names(data))){stop("xVar not found in data")}
  if(!(subVar %in% names(data))){stop("subVar not found in data")}
  
  ## Axis labels:
  if(is.null(xLab)){xLab <- substitute_label(xVar)}
  if(is.null(yLab)){yLab <- substitute_label(yVar)}
  # if(is.null(zLab)){zLab <- substitute_label(zVar)}
  
  ## Colours:
  if(is.null(selCol)){selCol <- retrieve_colour(zVar)}
  
  # -------------------------------------------------------------------------- #
  ## Fixed plotting settings:
  
  LWD <- retrieve_plot_defaults("LWD") # 1.3
  FTS <- retrieve_plot_defaults("FTS")
  colAlpha <- 1
  
  # -------------------------------------------------------------------------- #
  ## Create variables under standardized names:
  
  data$x <- data[, xVar]
  data$y <- data[, yVar]
  data$z <- data[, zVar]
  data$subject <- data[, subVar]
  
  # -------------------------------------------------------------------------- #
  ## Aggregate data per subject per conditions x/y:
  
  aggrData <- ddply(data, .(subject, x, z), function(x){
    y <- mean(x$y, na.rm = T)
    return(data.frame(y))
    dev.off()})
  # Wide format: each subject/x condition/z condition in one line, variables subject, x, y, z
  
  ## Determine y limits if not given:
  if(is.null(yLim)){
    yLim <- determine_ylim_data_y(aggrData)
  }
  
  # -------------------------------------------------------------------------- #
  ## Aggregate data across subjects with Rmisc:
  
  summary_d <- summarySEwithin(aggrData, measurevar = "y", idvar = "subject", na.rm = T,
                               withinvars = c("x", "z"))
  summary_d$x <- as.numeric(summary_d$x) # back to numeric to get continuous x-axis
  # Aggregated over subjects, one row per condition, variables x, z, N, y, sd, se, ci
  
  # Data dimensions:
  xVec <- unique(sort(as.numeric(summary_d$x)))
  condNames <- unique(summary_d$z)
  nCond <- length(unique(summary_d$z))
  
  if (length(selLineType) == 1){selLineType <- rep(selLineType, nCond)}
  
  # -------------------------------------------------------------------------- #
  ## Start plot with ggplot:

  ## Additions:
  if(is.null(prefix)){prefix <- ""} else {prefix <- paste0(prefix, "_")}
  if(is.null(suffix)){suffix <- ""} else {suffix <- paste0("_", suffix)}
  
  ## Name:
  plotName <- paste0("lineplot_gg_", yVar, "_", xVar, "_", zVar, suffix)

  ## Saving:
  if (saveEPS){cat("Save as eps\n"); setEPS(); postscript(paste0(dirs$plot, plotName, ".eps"), width = 480, height = 480)}
  if (savePNG){cat("Save as png\n"); png(paste0(dirs$plot, plotName, ".png"), width = 480, height = 480)}
  
  ## Start plot:
  # par(mar = c(5.1, 5.1, 4.1, 2.1)) # bottom, left, top, right
  p <- ggplot(data = summary_d, aes(x = x, y = y, col = z, fill = z))
  
  # p + geom_path() # just to get legend going
  
  ## Loop over conditions, make shade and line on top:
  for (iCond in 1:nCond){ # iCond <- 1
    
    ## Select data, set upper and lower shade limits:
    condData <- subset(summary_d, z == condNames[iCond]) # select data for this condition
    condData$ymin <- condData$y - SEweight * condData$se # lower edge of shade
    condData$ymax <- condData$y + SEweight * condData$se # upper edge of shade
    
    ## Shade:
    p <- p + geom_ribbon(data = condData, aes(x = x, y = y, ymin = ymin, ymax = ymax, group = 1), 
                         # col = NA, # remove outer border of shades
                         linetype = 0, # remove outer border of shades
                         # fill = selCol[iCond], # comment out for legend in colours (not grey)
                         # show.legend = T, 
                         alpha = 0.2, lwd = 0)
    
    ## Line:
    p <- p + geom_path(data = condData, aes(x = x, y = y, group = 1),
                       # col = selCol[iCond], 
                       linetype = selLineType[iCond], size = LWD) 
  }
  
  # Add title:
  if (!(is.null(main))){
    p <- p + ggtitle(main)  
  }
  
  ## X-axis:
  xMin <- min(xVec)
  xMax <- max(xVec)
  if (is.null(breakVec)){
    xRange <- xMax - xMin
    xStep <- ceiling(xRange/5)
    breakVec <- seq(xMin, xMax, xStep)
  }
  p <- p + scale_x_continuous(limits = c(xMin, xMax), breaks = breakVec)
  
  ## Y-axis:
  if (yLim[1] == 0 & yLim[2] == 1){
    p <- p + scale_y_continuous(breaks = seq(0, 1, by = 0.5)) # only 0, 0.5, 1 as axis labels
  }
  if(!(is.null(yLim))){p <- p + coord_cartesian(ylim=yLim)}
  
  ## Add labels:
  p <- p + labs(x = xLab, y = yLab, fill = condNames, col = condNames)
  
  ## Add line colors:
  p <- p + scale_fill_manual(values = selCol, limits = levels(data$z)) # set limits for correct order
  p <- p + scale_color_manual(values = selCol, limits = levels(data$z), guide = "none") # set limits for correct order
  
  # Add theme, font sizes:
  require(ggthemes)
  p <- p + theme_classic() + 
    theme(axis.text = element_text(size = FTS),
          axis.title = element_text(size = FTS), 
          plot.title = element_text(size = FTS, hjust = 0.5))
  
  ## Add legend:
  if (addLegend){
    p <- p + theme(
      legend.position = "top",
      legend.box = "horizontal",
      legend.title = element_blank(),
      # legend.title = element_text(size = FTS),
      legend.text = element_text(size = FTS/2)
    )
  } else {
    p <- p + theme(
      legend.title = element_blank(), legend.position = "none"
    )
  }
  
  print(p)
  if(savePNG | saveEPS){dev.off()}
  # par(mar = c(5.1, 4.1, 4.1, 2.1)) # bottom, left, top, right
  
  if (saveSVG){save_plot(paste0(dirs$plot, plotName, ".svg"), fig = p, width = 20, height = 20)}
  if (savePDF){ggsave(paste0(dirs$plot, plotName, ".pdf"), plot = p, width = 20, height = 20, units = "cm")}
  
  return(p)
  
}

# ============================================================================ #
#### 30) Plot density split by zVar: ####

customplot_density2 <- function(data, xVar, zVar, 
                                xLab = NULL, zLab = NULL, xLim = NULL, main = NULL,
                                selCol = NULL, addLegend = F, isPNG = T){
  #' Plot density of xVar split by yVar.
  #' @param data data frame, trial-by-trial data.
  #' Param xVar scalar string, variable for which to compute density.
  #' @param zVar scalar string, name of variable to split by (differently colored lines). Variable needs to be a factor.
  #' @param xLab scalar string, x-axis label (optional).
  #' @param zLab scalar string, color label (optional).
  #' @param main string, overall plot label (optional).
  #' @param xLim vector of two numbers, x-axis limits (optional).
  #' @param selCol vector of strings (HEX colors), colors for bars (default: retrieve via retrieve_colour()).
  #' @param addLegend Boolean, add legend at the top or not (default: FALSE).
  #' @param isPNG Boolean, save as .png file (default: TRUE).
  #' @return creates (and saves) plot.
  
  require(ggplot2)
  cat(paste0("Plot density of ", xVar, " split by ", zVar, "\n"))
  
  if(!is.numeric(data[, xVar])){stop("xVar must be numeric")}
  if(is.numeric(data[, zVar])){stop("zVar must be numeric")}
  
  # -------------------------------------------------------------------------- #
  ### Retrieve settings:
  
  FTS <- retrieve_plot_defaults("FTS")
  LWD <- retrieve_plot_defaults("LWD")
  if (is.null(xLab)){xLab <- substitute_label(xVar)}
  if (is.null(zLab)){zLab <- substitute_label(zVar)}
  if (is.null(selCol)){
    selCol <- retrieve_colour(zVar)
  } else {
    if(length(selCol) != length(levels(data[, zVar]))){"selCol and level(data$zVar) of different lengths"}
  }
  
  if (is.null(xLim)){
    if (grepl("RT_n", xVar)){
      xLim <- c(0, 1.3)
    # } else if (grepl("dilation_n", xVar)){
    #     xLim <- c(0, 80)
    } else {
      xLim <- c(min(data[, xVar], na.rm = T), max(data[, xVar], na.rm = T))
    }
  }

  ## Copy over data:
  data$x <- data[, xVar]
  data$z <- data[, zVar]

  ## Exclude NAs:
  data <- data[which(!is.na(data$x) & !is.na(data$z)), ]  
  
  # -------------------------------------------------------------------------- #
  ### Start plot:
  
  p <- ggplot(data = data, aes(x = x, fill = z)) # initialize
  p <- p + geom_density(color = "black", alpha = 0.7, trim = FALSE, lwd = LWD)
  
  ## Fill colour:
  p <- p + scale_fill_manual(values = selCol)

  ## Limits:
  p <- p + coord_cartesian(xlim = xLim) 

  # -------------------------------------------------------------------------- #
  ### Labels:

  ## Labels:
  p <- p + labs(x = xLab, y = "Density", fill = zLab)
  
  ## Add title:
  if (!(is.null(main))){
    p <- p + ggtitle(main)  
  }
  
  # -------------------------------------------------------------------------- #
  ### Add theme, font sizes:
  
  ## Theme:
  p <- p + theme_classic() # theme
  
  ## Font sizes:
  p <- p + theme(axis.text = element_text(size = FTS),
                 axis.title = element_text(size = FTS), 
                 plot.title = element_text(size = FTS, hjust = 0.5)) # center title 

  ## Add legend:
  if (addLegend){
    p <- p + theme(
      legend.title = element_blank(),
      # legend.title = element_text(size = FTS),
      legend.text = element_text(size = FTS)
    )
  } else {
    p <- p + theme(
      legend.title = element_blank(), legend.position = "none"
    )
  }
  
  # -------------------------------------------------------------------------- #
  ### Save:
  if (isPNG){
    ## Save:  
    figName <- paste0("density_", xVar, "~", zVar)
    if(addLegend){figName <- paste0(figName, "_addLegend")}
    png(paste0(dirs$plotDir, figName,  ".png"), width = 480, height = 480)
    print(p)
    dev.off()
  }
  
  # -------------------------------------------------------------------------- #
  ### Return:
  
  print(p)
  return(p)
  cat("Finished! :-)\n")
  
}

# END OF FILE.