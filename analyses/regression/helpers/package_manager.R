#!/usr/bin/env Rscript
# ============================================================================ #
## package_manager.R
## MGNG-TUS study: Load packages and set scipen, contrasts, and seed.
## Also see sessionInfo() and loadedNamespaces() at the bottom.
## Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

# =========================================================================================== #
#### Packages: ####

cat("Start loading packages\n")

# ----------------------------------------- #
## Descriptives and plots:

require(car)
require(Rmisc) # for summarySEwithin
require(ggplot2)
require(lattice)
require(ltm)
require(pastecs) # for stat.desc
require(psych)
require(effsize) # for Cohen.d

require(stringr) # for str_pad etc.

# ----------------------------------------- #
## For reading Matlab files:

require(rmatio) # read.mat
require(data.table) # rbindlist

# ----------------------------------------- #
## RM-ANOVA:

require(ez)

# ----------------------------------------- #
## Tidyverse:

require(plyr)
require(dplyr)
require(magrittr)

# ----------------------------------------- #
## Linear mixed effects models:

require(lme4)
require(afex)
require(effects)
require(emmeans)
require(DescTools)

# ----------------------------------------- #
## Generalized additive mixed models:

require(mgcv)
require(itsadug)

# ----------------------------------------- #
## For corrplots:

library(corrplot) # for corrplots
library(synthesisr) # for line breaks in title

# ----------------------------------------- #
## Color bars:

require(sommer)
require(viridis)
require(RColorBrewer)
require(MetBrewer)
require(scales)

# ----------------------------------------- #
# For raincloud plots:

require(readr)
require(tidyr)
require(ggplot2)
require(Hmisc)
require(plyr)
require(RColorBrewer)
require(reshape2)
require(ggstatsplot) # for geom_flat_violin
require(gghalves) # for half plots
require(ggbeeswarm) # for ggbeeswarm
require(ggthemes)

# ----------------------------------------- #
## Facilitate detecting when model finished:

require(beepr)

# ============================================================================ #
#### General settings: #####

cat("Set scipen to 20\n")
options(scipen = 20)

cat("Set contrasts to sum-to-zero coding\n")
options(contrasts = c("contr.sum", "contr.poly"))

# ============================================================================ #
#### Set seed: ####

mySeed <- 70
cat(paste0("Set seed to ", mySeed, "\n"))
set.seed(mySeed)

# ============================================================================ #
#### sessionInfo: ####

# > sessionInfo()
# R version 4.3.0 (2023-04-21 ucrt)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 11 x64 (build 26100)
# 
# Matrix products: default
# 
# 
# locale:
#  [1] LC_COLLATE=English_United Kingdom.utf8  LC_CTYPE=English_United Kingdom.utf8    LC_MONETARY=English_United Kingdom.utf8 LC_NUMERIC=C                           
#  [5] LC_TIME=English_United Kingdom.utf8    
# 
# time zone: Europe/London
# tzcode source: internal
# 
# attached base packages:
#  [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
#  [1] beepr_1.3          ggthemes_4.2.4     ggbeeswarm_0.7.2   gghalves_0.1.4     ggstatsplot_0.11.1 reshape2_1.4.4     Hmisc_5.1-0        tidyr_1.3.0       
#  [9] readr_2.1.4        scales_1.2.1       MetBrewer_0.2.0    RColorBrewer_1.1-3 viridis_0.6.3      viridisLite_0.4.2  sommer_4.3.1       crayon_1.5.2      
# [17] synthesisr_0.3.0   corrplot_0.92      itsadug_2.4.1      plotfunctions_1.4  mgcv_1.9-0         nlme_3.1-162       DescTools_0.99.49  emmeans_1.8.7     
# [25] effects_4.2-2      afex_1.3-0         lme4_1.1-34        Matrix_1.6-0       magrittr_2.0.3     dplyr_1.1.2        ez_4.4-0           data.table_1.14.8 
# [33] rmatio_0.18.0      stringr_1.5.0      effsize_0.8.1      psych_2.3.6        pastecs_1.3.21     ltm_1.2-0          polycor_0.8-1      msm_1.7           
# [41] MASS_7.3-58.4      ggplot2_3.4.4      Rmisc_1.5.1        plyr_1.8.8         lattice_0.21-8     car_3.1-2          carData_3.0-5     
# 
# loaded via a namespace (and not attached):
# [1] audio_0.1-10           rstudioapi_0.15.0      datawizard_0.8.0       correlation_0.8.4      TH.data_1.1-2          estimability_1.4.1     nloptr_2.0.3          
# [8] rmarkdown_2.23         vctrs_0.6.3            minqa_1.2.5            paletteer_1.5.0        base64enc_0.1-3        htmltools_0.5.5        survey_4.2-1          
# [15] cellranger_1.1.0       Formula_1.2-5          htmlwidgets_1.6.2      sandwich_3.0-2         rootSolve_1.8.2.3      zoo_1.8-12             admisc_0.33           
# [22] lifecycle_1.0.3        pkgconfig_2.0.3        R6_2.5.1               fastmap_1.1.1          digest_0.6.33          Exact_3.2              numDeriv_2016.8-1.1   
# [29] colorspace_2.1-0       rematch2_2.1.2         patchwork_1.1.2        fansi_1.0.4            httr_1.4.6             abind_1.4-5            compiler_4.3.0        
# [36] proxy_0.4-27           withr_2.5.0            htmlTable_2.4.1        backports_1.4.1        DBI_1.1.3              gld_2.6.6              tools_4.3.0           
# [43] vipor_0.4.5            foreign_0.8-84         beeswarm_0.4.0         statsExpressions_1.5.1 nnet_7.3-18            glue_1.6.2             grid_4.3.0            
# [50] stringdist_0.9.10      checkmate_2.2.0        cluster_2.1.4          generics_0.1.3         gtable_0.3.3           tzdb_0.4.0             class_7.3-21          
# [57] lmom_2.9               hms_1.1.3              utf8_1.2.3             pillar_1.9.0           mitools_2.4            splines_4.3.0          survival_3.5-5        
# [64] tidyselect_1.2.0       knitr_1.43             gridExtra_2.3          svglite_2.1.1          xfun_0.39              expm_0.999-7           stringi_1.7.12        
# [71] boot_1.3-28.1          evaluate_0.21          codetools_0.2-19       tibble_3.2.1           cli_3.6.1              rpart_4.1.19           xtable_1.8-4          
# [78] parameters_0.21.1      systemfonts_1.0.4      munsell_0.5.0          Rcpp_1.0.11            readxl_1.4.3           zeallot_0.1.0          coda_0.19-4           
# [85] parallel_4.3.0         bayestestR_0.13.1      mvtnorm_1.2-2          lmerTest_3.1-3         e1071_1.7-13           insight_0.19.3         purrr_1.0.1           
# [92] rlang_1.1.1            multcomp_1.4-25        mnormt_2.1.1  

# > loadedNamespaces()
#  [1] "RColorBrewer"     "audio"            "Rmisc"            "rstudioapi"       "datawizard"       "correlation"      "magrittr"         "ggbeeswarm"      
#  [9] "TH.data"          "estimability"     "corrplot"         "nloptr"           "rmarkdown"        "vctrs"            "MetBrewer"        "minqa"           
# [17] "paletteer"        "base64enc"        "htmltools"        "synthesisr"       "survey"           "cellranger"       "Formula"          "htmlwidgets"     
# [25] "plyr"             "sandwich"         "emmeans"          "rootSolve"        "zoo"              "admisc"           "lifecycle"        "pkgconfig"       
# [33] "pastecs"          "Matrix"           "R6"               "fastmap"          "digest"           "Exact"            "numDeriv"         "colorspace"      
# [41] "rematch2"         "patchwork"        "rmatio"           "Hmisc"            "itsadug"          "fansi"            "effects"          "httr"            
# [49] "abind"            "mgcv"             "compiler"         "proxy"            "withr"            "htmlTable"        "backports"        "carData"         
# [57] "viridis"          "DBI"              "psych"            "MASS"             "base"             "stats"            "gld"              "tools"           
# [65] "vipor"            "foreign"          "beeswarm"         "statsExpressions" "nnet"             "glue"             "graphics"         "nlme"            
# [73] "grid"             "stringdist"       "checkmate"        "cluster"          "reshape2"         "generics"         "gtable"           "plotfunctions"   
# [81] "tzdb"             "class"            "tidyr"            "data.table"       "lmom"             "hms"              "sommer"           "car"             
# [89] "utf8"             "pillar"           "stringr"          "mitools"          "splines"          "dplyr"            "gghalves"         "lattice"         
# [97] "survival"         "ggstatsplot"      "tidyselect"       "knitr"            "gridExtra"        "svglite"          "xfun"             "expm"            
# [105] "datasets"         "stringi"          "boot"             "evaluate"         "codetools"        "beepr"            "msm"              "effsize"         
# [113] "tibble"           "cli"              "rpart"            "xtable"           "parameters"       "DescTools"        "systemfonts"      "munsell"         
# [121] "afex"             "Rcpp"             "readxl"           "zeallot"          "polycor"          "utils"            "coda"             "parallel"        
# [129] "ggplot2"          "readr"            "methods"          "bayestestR"       "lme4"             "ggthemes"         "viridisLite"      "mvtnorm"         
# [137] "lmerTest"         "scales"           "grDevices"        "e1071"            "ez"               "insight"          "purrr"            "crayon"          
# [145] "rlang"            "multcomp"         "mnormt"           "ltm" 

# END OF FILE.