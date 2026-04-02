# mgng_tus_dacc_ains

Analysis code for the scientific article:

Koutsoumpari, N., Algermissen, J., Yaakub, S., den Ouden, H. E., Bault, N., & Fouragnan, E. (2026). 
Ultrasound neuromodulation reveals distinct roles of the dorsal anterior cingulate cortex and anterior insula in learning.
PLOS Biology.

MGNG TUS STUDY, UNIVERSITY OF PLYMOUTH.
Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
Distributed under the MIT licence.

All **analysis** scripts are in the folder "analyses".

*Mixed-effects regression models* were performed in R; see the sub-folder "regression". Please adjust the folder structure within *set_dirs.R* in the "helpers" subfolder.

*Computational reinforcement learning models* were fitted in MATLAB using the CBM toolbox; see the sub-folder "cbm". Please adjust he folder structure within *magngtus_cbm_set_dirs.m* (add set the path to your local copy of the CBM and the Brewermap toolbox).

Code to reproduce all the *figures* in the manuscript and supplementary information (and re-generate the underlying source data files) is located in the sub-folder "figures". 

All folders contain *their own README files* (README_mgngtus_cbm.md, README_mgngtus_figures.md, README_mgngtus_regression.md) with more detailed descriptions of the available scripts.

All the **data** to reproduce the reported findings as well as the **task** code can be found on OSF under https://doi.org/10.17605/OSF.IO/PUX6S.

END OF FILE.
