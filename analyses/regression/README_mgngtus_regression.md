# README_mgngtus_regression.md

Code for mixed-effects logistic and linear regression models and creating line and bar plots for the project "Ultrasound neuromodulation reveals distinct roles of the dorsal anterior cingulate cortex and anterior insula in learning".

MGNG TUS STUDY, UNIVERSITY OF PLYMOUTH.
Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

# Overview of files in main directory
- *01_mgngtus_regression.R*: Perform mixed-effects logistic regression (on p(Go) and p(Stay)) and linear regression (on RTs), plots results.
- *02_mgngtus_plot.R*: Create bar plots and line plots of behaviour (p(Go), p(Stay), RTs).
- *03_mgngtus_export2cbm.R*: Export (reduced form of) data as .csv files to be read in into MATLAB for computational modelling.

# functions
- 00_mgngtus_functions_regression.R: Range of various custom functions for pre-processing data, plotting data, fitting mixed-effects regression models.

# helpers
- *package_manager.R*: Load packages. Also contains print out of sessionInfo() and loadedNamespaces().
- *set_dirs.R*: Set folder structure (directories relative to root directory) for entire project.