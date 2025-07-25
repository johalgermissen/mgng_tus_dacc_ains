% mgngtus_cbm02_fit.m
%
% This is an interactive script---execute it step-by-step.
% It fits a series of computational reinforcement learning models using the
% CBM toolbox and evaluates them. The following fitting steps are
% implemented:
% - LAP: Fitting each subjects' data individually using Laplace
% approximation (LAP) of the log model evidence.
% - HBI SINGLE: Fit the data of all subjects for a given model in one
% single, hierarchical fit using Hierarchical Bayesian Inference (HBI).
% - HBI ACROSS: Fit several models for all subjects in one single,
% hierarchical fit using Hierarchical Bayesian Inference (HBI); relevant
% for Bayesian model selection (BMS) model frequency and (protected)
% exceedance probability.
%   - Involves refitting the model once more at the end to include the null
%   hypothesis of no model being more frequent than any other.
%
% INPUTS:
% none.
%
% OUTPUTS:
% no outputs, just plots.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% 00a) Initialize directories:

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));

dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% 00b) Set configuration parameters:

cfg             = mgngtus_cbm_set_config();

% ----------------------------------------------------------------------- %
%% 00c) Settings:

% Select sonication condition:
cfg.dataType    = 'sham';
% cfg.dataType    = 'dACC';
% cfg.dataType    = 'aIns';

% Select models:
nMod            = 9; % number of models to fit

% modVec          = 1:nMod;
modVec          = 1:7;
% modVec          = 7:9;

% ----------------------------------------------------------------------- %
%% 00d) Load and extract data, priors, output name:

% Load data:
fprintf('*** Load %s data ***\n', cfg.dataType);
inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
fdata           = load(inputFile); % only contains .data
data            = fdata.data; % extract .data
nSub            = length(data);

% Set priors:
priors          = mgngtus_get_priors(); % retrieve priors

% Set output names for LAP fit:
fprintf('*** Initialize output file names ***\n');
fname_mod = struct([]);
for iMod = 1:nMod
    fname_mod{iMod} = fullfile(dirs.lap, sprintf('lap_%s_mod%02d.mat', cfg.dataType, iMod));
end

% ----------------------------------------------------------------------- %
%% 00e) Check models in dry run:

fprintf('*** Test models (dry run) ***\n');
for iSub = 1:nSub
    
    fprintf('>>> Start subject %02d ...\n', iSub);
    subj    = data{iSub};
    
    % a) Random parameter values:
    for iMod = modVec % 1:nMod
        parameters = randn(1, 8);
        F1 = eval(sprintf('mgngtus_cbm_mod%02d(parameters, subj)', iMod));
        fprintf('*** Model %02d: loglik = %f\n', iMod, F1);
    end

    % b) Extreme parameter values:
    % for iMod = modVec % 1:nMod
    %     parameters = [-10 10 -10 10 10 10 10];
    %     F1 = eval(sprintf('EEGfMRIPav_cbm_mod%02d(parameters, subj)', iMod));
    %     fprintf('*** Model %02d: loglik = %f\n', iMod,F1);
    % end

end

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 01a) Fit LaPlace approximation (cbm_lap):

% All models are fit non-hierarchically.

% Fit for each model separately:
for iMod = modVec % 1:nMod
    fprintf('* --------------------------------------------------------- *\n');
    fprintf('*** Fit model %02d with LaPlace approximation ***\n', iMod)
    % Format data, model, prior, output file
    if ~exist(fname_mod{iMod}, 'file')
        fprintf('*** Start fitting %s ... ***\n', fname_mod{iMod});
        cbm_lap(data, eval(sprintf('@mgngtus_cbm_mod%02d', iMod)), priors{iMod}, fname_mod{iMod});
        fprintf('*** ... finished fitting %s ***\n', fname_mod{iMod});
    else
        warning('*** %s already exists, skipping ... ***\n', fname_mod{iMod});
    end
end
beep;

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 02a) Fit Hierarchical Bayesian inference (cbm_hbi) per SINGLE model:

% modVec        = 1:nMod;

% 1st input: data for all subjects:
fprintf('*** Load %s data ***\n', cfg.dataType);
inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
fdata           = load(inputFile); % only contains .data
data            = fdata.data; % extract .data

% 2nd input: priors--see above

% Other inputs: set within loop:
for iMod = modVec % 1:nMod
    fprintf('* --------------------------------------------------------- *\n');
    fprintf('*** Fit model %02d with HBI (singular model)\n', iMod)
    % 3rd input: models fit with LAP
    models          = {eval(sprintf('@mgngtus_cbm_mod%02d', iMod))};
    fname_lap_full  = {fullfile(dirs.lap, sprintf('lap_%s_mod%02d.mat', cfg.dataType, iMod))};
    % 4th input: HBI output file
    fname_hbi       = sprintf('hbi_%s_mod%02d.mat', cfg.dataType, iMod);
    fname_hbi_full  = {fullfile(dirs.hbi, fname_hbi)};
    % Fit:
    if ~exist(fname_hbi_full{:}, 'file')
        fprintf('*** Start fitting %s ... ***\n', fname_hbi);
        cbm_hbi(data, models, fname_lap_full, fname_hbi_full);
        fprintf('*** .. finished fitting %s! :-) ***\n', fname_hbi);
    else
        fprintf('*** %s already exists, skipping ... ***\n', fname_hbi);
    end
end
beep;

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 03a) Fit Hierarchical Bayesian inference (cbm_hbi) across models:

cfg.dataType = 'sham';
% cfg.dataType = 'dACC';
% cfg.dataType = 'aIns';

% 1st input: data for all subjects:
fprintf('* --------------------------------------------------------- *\n');
fprintf('*** Load %s data ***\n', cfg.dataType);
inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
fdata           = load(inputFile); % only contains .data
data            = fdata.data; % extract .data
nSub            = length(data);

fprintf('*** Select subjects ***\n');

% Select subjects:
invalidSubs     = []; % outliers in TAfT and fMRI
% invalidSubs     = [11 12 15 23 25 26 30]; % outliers in TAfT and fMRI
fprintf('*** Exclude subjects %s\n', num2str(invalidSubs));
validSubs       = setdiff(1:nSub, invalidSubs);
nSubValid       = length(validSubs);
if ~isempty(invalidSubs)
    data = data(validSubs); 
end

% 2nd input: a cell input containing function handle to models
% 3rd input: another cell input containing file-address to files saved by cbm_lap

% All models:
% modVec          = 1:nMod;
modVec          = 1:7;
% modVec          = 7:9;

fprintf('*** Prepare HBI for comparing models %s\n', strjoin({num2str(modVec)}, ', '));

% Create names of input files:
iCount      = 0;
models      = cell(length(modVec), 1);
fcbm_maps   = cell(length(modVec), 1);
for iMod = modVec
    iCount = iCount + 1;
    models{iCount} = eval(sprintf('@mgngtus_cbm_mod%02d', iMod));
    fcbm_maps{iCount} = fullfile(dirs.lap, sprintf('lap_%s_mod%02d.mat', cfg.dataType, iMod));
end

% 4th input: a file address for saving the output
% All models named explicitly:
fname_hbi_mod = fullfile(dirs.hbi, sprintf('hbi_%s_mod%s', cfg.dataType, num2str(modVec, '_%02d'))); % single model
fprintf('*** Output file will be %s\n', fname_hbi_mod);

fname_hbi_mod = sprintf('hbi_%s_mod%s', cfg.dataType, num2str(modVec, '_%02d')); % single model
if ~isempty(invalidSubs); fname_hbi_mod = [fname_hbi_mod '_without' length(invalidSubs)]; end
fname_hbi       = [fname_hbi_mod '.mat'];
fname_hbi_null  = [fname_hbi_mod '_null.mat'];

fname_hbi_full      = fullfile(dirs.hbi, fname_hbi);
fname_hbi_null_full = fullfile(dirs.hbi, fname_hbi_null);

% Fit:
fprintf('*** Fit models %s with HBI \n', strjoin(string(modVec), ', '));
if ~exist(fname_hbi_full, 'file')
    fprintf('*** Fit models %s ... \n', fname_hbi);
    cbm_hbi(data, models, fcbm_maps, fname_hbi_full);
    fprintf('*** ... finished fitting models %s! :-) \n', fname_hbi);
else
    fprintf('*** %s already exists, skipping ... ***\n', fname_hbi);
end
fprintf('*** Finished fitting :-) ***\n');

% ----------------------------------------------------------------------- %
% 03b) Additionally run protected exceedance probability (including null model):

fprintf('*** Re-run models %s with HBI including null model\n', strjoin(string(modVec), ', '));
if ~exist(fname_hbi_null_full, 'file')
    fprintf('*** Fit models %s ... \n', fname_hbi_null);
    cbm_hbi_null(data, fname_hbi_full);
    fprintf('*** ... finished fitting models %s! :-) \n', fname_hbi_null);
else
    fprintf('*** %s already exists, skipping ... ***\n', fname_hbi_null);
end

fprintf('*** Finished fitting including null model:-) ***\n');

% Evaluate:
f_hbi   = load(fname_hbi_full);
cbm     = f_hbi.cbm;
mf      = cbm.output.model_frequency;
xp      = cbm.output.exceedance_prob;
pxp     = cbm.output.protected_exceedance_prob;
xp_dif  = xp - pxp; % difference
fprintf('*** Model frequency                 : %s\n', num2str(mf, '%.02f '));
fprintf('*** Exceedance probability          : %s\n', num2str(xp, '%.02f '));
fprintf('*** Protected Exceedance probability: %s\n', num2str(pxp, '%.02f '));
% fprintf('*** Difference                      : %s\n', num2str(xp_dif, '%.02f '));
fprintf('*** Finished :-) ***\n');
beep;
pause(2);
beep;

% ----------------------------------------------------------------------- %
%% 03c) Evaluate HBI fit:

% Create output name:
modVec      = 1:8;
fname_hbi   = fullfile(dirs.hbi, sprintf('hbi_%s_mod%s.mat', ...
    cfg.dataType, num2str(modVec, '_%02d'))); % all models

% ----------------------------- %
% Load model:
f_hbi       = load(fname_hbi);
cbm         = f_hbi.cbm;
nSub        = size(cbm.output.parameters{1}, 1);

% ----------------------------- %
% Model frequency:
fprintf('*** Model frequency ***\n');
cbm.output.model_frequency

% ----------------------------- %
% Responsibility per subject:
fprintf('*** Maximal model responsibility ***\n');
responsibility  = cbm.output.responsibility;

% Per subject:
subResp     = nan(nSub, 1);
for iSub = 1:nSub
    subMax          = max(responsibility(iSub, :));
    subResp(iSub)   = find(responsibility(iSub, :) == subMax);
end
tabulate(subResp)

% Per model:
for iMod = 1:length(modVec)
    idx     = find(subResp == iMod);
    fprintf('*** Model M%02d is most responsible for %02d subjects: %s\n', ...
        modVec(iMod), length(idx), mat2str(idx));
end

% ----------------------------- %
% Exceedance probability:
fprintf('*** Exceedance probability: ***\n');
cbm.output.exceedance_prob

% ----------------------------- %
% Protected exceedance probability:
fprintf('*** Protected exceedance probability: ***\n');
cbm.output.protected_exceedance_prob

% END OF FILE.