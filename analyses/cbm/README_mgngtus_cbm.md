# README_mgngtus_cbm.md

Code for reinforcement learning models for the project "Ultrasound neuromodulation reveals distinct roles of the dorsal anterior cingulate cortex and anterior insula in learning".

Code for computational reinforcement learning models fitted to behavioural data (Go/NoGo choices) using the CBM toolbox written by Payam Piray implemented in MATLAB (https://github.com/payampiray/cbm).

MGNG TUS STUDY, UNIVERSITY OF PLYMOUTH.
Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.

# Overview of files in main directory
- *mgngtus_cbm_set_dirs.m*: Set folder structure (directories) for entire project relative to root directory.
    - Replace *dirs.git* for code root directory and *dirs.onedrive* for data root directory.
    - Also include path to local copy of CBM toolbox (download from https://github.com/payampiray/cbm).
    - Also include path to local copy of BrewerMap toolbox for colour maps (download from https://www.mathworks.com/matlabcentral/fileexchange/45208-colorbrewer-attractive-and-distinctive-colormaps).
- *mgngtus_cbm01_prepareData.m*: Run once to create .mat files of data based on the .csv files created earlier in R.
- *mgngtus_cbm02_fit.m*: Fit selected model in three steps: (1) flat (separately per subject) using Laplace approximation (LAP); (2) hierarchically across subjects using Hierarchical Bayesian inference (HBI); (3) hierarchically across subjects and all selected models using Hierarchical Bayesian inference (HBI). Results saved to disk. Run once.
- *mgngtus_cbm03_eval_fit.m*: Load range of model output files; extract log-model evidence & plot as bar plots; extract model frequency and protected exceedance probability and plot as bar plots.
- *mgngtus_cbm03b_eval_param.m*: Load fitted parameter values; plot as bar plots with parameters next to each other (separately per sonication condition).
- *mgngtus_cbm03c_eval_param_sonication.m*: Load fitted parameter values; plot as bar plots with sonication conditions next to each other (separately per parameter type).
- *mgngtus_cbm04a_loop_sim.m*: Simulate behaviour for given model given fitted parameter values.
- *mgngtus_cbm04b_plot_behaviour.m*: Load in empirical or simulated data; plot behaviour (p(Go), p(Stay), RTs) as bar plots and line plots per task condition (required action, valence; past response, past outcome).
- *mgngtus_cbm04c_plot_pStay_out_sonication.m*: Load in empirical or simulated data; plot behaviour (p(Stay)) as bar plots with sonication conditions next to each other; perform paired t-tests and RM-ANOVAs.
- *mgngtus_cbm05_save_param.m*: Save parameter values per model as .csv files. 
- *mgngtus_cbm06a_parameter_recovery.m*: Perform and evaluate parameter recovery for selected model.
- *mgngtus_cbm06b_model_recovery_fit.m*: Perform model recovery for selected models.
- *mgngtus_cbm06c_model_recovery_eval.m*: Evaluate model recovery for selected models.
- *04_mgngtus_params.R*: Load in .csv files with parameter values previously saved from MATLAB; plot in R, perform t-tests and repeated-measures ANOVAs, correlate parameter changes under TUS with simulated peak pressure/intensity.

# helpers
- *boundedline.m*: Make line plot with error shade (function by (C) Kelly Kearney).
- *custom_barplot.m*: Make bar plot based on configurations and nSub x nCond matrix (designed for behavioural data).
- *custom_lineplot.m*: Make bar plot based on configurations and nSub x nCond x nRep matrix (designed for behavioural data).
- *format_paramNames.m*: Retrieve (Greek) names of parameters for given mode as well as LaTeX formatting.
- *log1p_exp.m*: Transform by exponentiating, adding +1, taking logarithm (y = x for large numbers, smoothly approaching zero for small numbers).
- *mgngtus_aggregate_empirical_data.m*: Aggregate raw data into various matrices.
- *mgngtus_aggregate_simulated_data.m*: Aggregate simulated data into various matrices.
- *mgngtus_cbm_compute_loglik.m*: Compute log-likelihood, AIC, BIC given model parameters.
- *mgngtus_cbm_init_paramNames.m*: Retrieve cell with all (Greek) parameter names for all models; retrieve transform per parameter name; retrieve strings corresponding to Greek letters.
- *mgngtus_cbm_load_model.m*: Load .mat file of fitted model into MATLAB; extract (group-level and ) subject-level parameters into matrices.
- *mgngtus_cbm_save_param.m*: Save nSub x nParam matrices of parameter values as .csv files. 
- *mgngtus_cbm_set_config.m*: Set task configurations for simulating data.
- *mgngtus_cbm_wrapper_sim.m*: Wrapper for simulating data for given model given fitted parameter values (or loading previously simulated data). 
- *mgngtus_custom_corrplot.m*: Make heat map plot of (correlation) matrix using MATLAB's imagesc() function.
- *mgngtus_get_priors.m*: Retrieve cell with prior settings (mean and variance) for each parameter for each model.
- *mgngtus_parameter_constraints.m*: Filter nSub x nParam matrix based on numerical constraints on parameter values (given parameter name); only return rows that fulfill all criteria. 
- *mgngtus_plot_param.m*: Make bar plot based on configurations and nSub x nCond matrix  (designed for parameter values).
- *none.m*: Return input (placeholder if no transformation applied).
- *sigmoid.m*: Perform sigmoid (inverse logit/softmax) transform on input data.
- *sim_subj.m*: Set up scaffold for data for single subject to be simulated (stimuli and stimulus conditions per trial).
- *transform_parameters.m*: Transform raw parameters given parameter name.
- *visualise_priors.m*: Plot densities of prior distributions (given mean and variance and transformation).
- *visualise_transformations.m*: Plot densities after non-linear transformation.
- *withinSE.m*: Compute within-subject across-conditions standard errors while removing between-subject variance using the Cousineau-Morey method.

# models
- *mgngtus_cbm_mod01.m*: Standard Q-learning model with delta learning rule.
- *mgngtus_cbm_mod02.m*: Standard Q-learning model with delta learning rule and with Go bias.
- *mgngtus_cbm_mod03.m*: Standard Q-learning model with delta learning rule and with Go bias and Pavlovian response bias.
- *mgngtus_cbm_mod04.m*: Standard Q-learning model with delta learning rule and with Go bias and instrumental learning bias.
- *mgngtus_cbm_mod05.m*: Standard Q-learning model with delta learning rule and with Go bias, Pavlovian response bias, and with instrumental learning bias.
- *mgngtus_cbm_mod06.m*: Standard Q-learning model with delta learning rule and with Go bias, Pavlovian response bias, instrumental learning bias, and single choice perseveration parameter.
- *mgngtus_cbm_mod07.m*: Standard Q-learning model with delta learning rule and with Go bias,  Pavlovian response bias, instrumental learning bias, intercept perseveration parameter for Avoid cues, difference parameter for Win cues.
- *mgngtus_cbm_mod08.m*: Standard Q-learning model with delta learning rule and with Go bias, Pavlovian response bias, instrumental learning bias, cue-valence based prediction error boost, perseveration parameter. All outcomes receive cue valence-based boost.
- *mgngtus_cbm_mod09.m*: Standard Q-learning model with delta learning rule and with Go bias, Pavlovian response bias, instrumental learning bias, neutral outcome reinterpretation parameter, perseveration parameter. Only neutral outcomes can be reinterpreted.

# modSims
Model simulation files for all models. Samples new responses given action probabilities (action values/weights transformed by softmax). Samples new outcomes given response and feedback validity on given trial. Sampled behaviour is thus probabilistic; run multiple iterations.

# osaps
One-step-ahead predictions for all modesl. Uses the actual empirically observed responses and outcomes to estimates action values/weights and action probabilities. No sampling, thus deterministic; run only once.

END OF FILE.