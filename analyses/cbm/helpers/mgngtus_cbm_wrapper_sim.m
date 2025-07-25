function [sim, job] = mgngtus_cbm_wrapper_sim(job)

% [sim, job] = mgngtus_cbm_wrapper_sim(job)
%
% Perform model simulations or one-step-ahead predictions for given model
% for given type of parameters.
%
% INPUTS:
% job 	        = structure with the following fields:
% .dataType     = scalar string, suffix in data inputs and model outputs,
% either 'sham', 'dACC', or 'aIns'.
% .simType      = scalar string, type of simulation, either 'modSim' (model
% simulations) or 'osap' (one-step-ahead predictions).
% .parType      = scalar string, type of input parameters, either 'lap'
% (LaPlace approximation) or 'hbi' (Hierarchical Bayesian inference).
% .iMod         = scalar integer, model number to be simulated.
%
% OUTPUTS:
% sim           = structure with the following fields:
% .p            = nSub x nIter x nTrial x nResp matrix with action probabilities per subject per iteration per trial per response option.
% .pGo          = nSub x nIter x nTrial matrix with probability of Go
% response per subject per iteration per trial.
% .PE           = nSub x nIter x nTrial matrix with prediction error per
% subject per iteration per trial (divided by feedback sensitivity to bring
% to range [-1, 1].
% .EV           = nSub x nIter x nTrial matrix with expected value of
% chosen response per subject per iteration per trial.
% .lik          = nSub x nIter x nTrial matrix with log-likelihood of
% chosen response per subject per iteration per trial.
% job           = same as input structure and a few new settings.
% Save to disk.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% Complete input fields:

if ~isfield(job, 'dataType')
    job.parType = 'sham'; % sham, dACC, aIns
end

if ~isfield(job, 'simType')
    job.simType = 'modSim'; % modSim, osap
end

if ~isfield(job, 'parType')
    job.parType = 'lap'; % lap, hbi
end

if ~isfield(job, 'iMod')
    job.iMod    = 1;
end

fprintf('*** Simulate for model %02d ***\n', job.iMod);
fprintf('*** Simulate data using simulation method ''%s'' based on parameters fitted with ''%s'' for ''%s'' data ***\n', ...
    job.simType, job.parType, job.dataType);

% ----------------------------------------------------------------------- %
%% Retrieve directories:

dirs            = mgngtus_cbm_set_dirs();

% Add additional paths to simulation scripts:
addpath(fullfile(dirs.scripts, 'osaps'));
addpath(fullfile(dirs.scripts, 'modSims'));

% ----------------------------------------------------------------------- %
%% Complete downstream settings:

% Number of itereations:
if strcmp(job.simType, 'osap')
    job.nIter       = 1; % 1 for osap
elseif strcmp(job.simType, 'modSim')
    if ~isfield(job, 'nIter')
        job.nIter       = 1000; % more for modSim
    end
else
    error('*** Unknown simulation type %s ***', job.simType)
end

% Complete name of file to load:
job.modFileName             = sprintf('%s_%s_mod%02d.mat', job.parType, job.dataType, job.iMod);
if strcmp(job.parType, 'hbi')
    job.modFullFileName     = fullfile(dirs.hbi, job.modFileName); % hbi output object
elseif strcmp(job.parType, 'lap')
    job.modFullFileName     = fullfile(dirs.lap, job.modFileName); % hbi output object
else
    error('*** Unknown parameter type %s ***\n', job.parType);
end

% ----------------------------------------------------------------------- %
%% Define output file name:

outputFile = sprintf('%s_%s_mod%02d_%s_iter%04d.mat', ...
    job.dataType, job.simType, job.iMod, job.parType, job.nIter);
outputFullFile = fullfile(dirs.sims, outputFile);

% ----------------------------------------------------------------------- %
%% Start simulation:

if ~exist(outputFullFile, 'file')

    % ------------------------------------------------------------------- %
    %% Load data:

    % Use original subject data --> original stimulus order
    fprintf('*** Load empirical data ***\n');
    inputFile   = fullfile(dirs.input, sprintf('mgngtus_%s.mat', job.dataType));    
    fdata       = load(inputFile); % only contains .data
    data        = fdata.data; % extract .data
    job.nSub    = length(data);

    % ------------------------------------------------------------------- %
    %% Load parameters:

    fprintf('*** Load parameters for model %02d based on %s ***\n', job.iMod, job.parType)
    fname               = load(job.modFullFileName);
    cbm                 = fname.cbm;
    if strcmp(job.parType, 'lap')
        allParam            = cbm.output.parameters;
    elseif strcmp(job.parType, 'hbi')
        if length(cbm.output.parameters) == 1 % if only 1 model
            allParam            = cbm.output.parameters{:};
        else
            allParam            = cbm.output.parameters{job.iMod}; % all models
        end
    end

    % ------------------------------------------------------------------- %
    %% Simulate new data:

    fprintf('*** Simulate %s based on %s parameters for model %02d with %d iterations ***\n', ...
        job.simType, job.parType, job.iMod, job.nIter)

    for iSub = 1:job.nSub % iSub = 1;

        % Extract subject data:
        fprintf('*** Model M%02d: Start %d ''%s'' simulations of data based on ''%s'' parameters for ''%s'' data of subject %03d ... ***\n', ...
            job.iMod, job.nIter, job.simType, job.parType, job.dataType, iSub);
        if strcmp(job.simType, 'osap') 
            subj = data{iSub}; % retrieve subject data
        elseif strcmp(job.simType, 'modSim') 
            subj = sim_subj; % contains reqactions and feedback to compute feedback validity
        else
            error('*** Unknown simulation type ***')
        end

        % Retrieve parameters:
        parameters = allParam(iSub, :);

        % Regularize parameters for simulations:
        % plot(allParam(:, 1))
        if parameters(1) > 5; parameters(1) = 5; warning('*** Feedback sensitivty too high; regularize to %d ***', parameters(1)); end % regularize feedback sensitivity (exp(5) = 148.4132; high enough)

        % Save parameters and data per subject:
        sim.parameters{iSub}   = parameters; % add parameters
        sim.subj{iSub}         = subj; % add subject data

        % Loop over iterations:
        for iIter = 1:job.nIter % iIter = 1;

            % Progress bar:
            if strcmp(job.simType, 'modSim') && job.nIter >= 100
                fraction_done = iIter/job.nIter;
                waitbar(fraction_done)
            end

            % Simulate:
            out         = eval(sprintf('mgngtus_cbm_mod%02d_%s(parameters, subj)', job.iMod, job.simType));
            nTrialFound = size(out.p, 1);

            % Save results:
            sim.p(iSub, iIter, 1:nTrialFound, :)        = out.p;
            sim.pGo(iSub, iIter, 1:nTrialFound)         = out.p(:, 1); % pGo (first column)
            sim.PE(iSub, iIter, 1:nTrialFound)          = out.PE ./ exp(parameters(1)); % normalize PEs to range [-1 1]
            sim.EV(iSub, iIter, 1:nTrialFound, :, :)    = out.EV;
            sim.lik(iSub, iIter, 1:nTrialFound)         = out.lik;
            if strcmp(job.simType, 'modSim') 
                sim.response(iSub, iIter, :, :) = out.response;
                sim.stay(iSub, iIter, :)        = out.stay;
                sim.outcome(iSub, iIter, :)     = out.outcome;
            end

        end % end iIter

    end % end iSub
    fprintf('*** Finished all simulations :-) ***\n');

    % ------------------------------------------------------------------- %
    %% Save:

    fprintf('*** Save outputs under %s ... ***\n', outputFile);
    
    job.dirs = dirs;
    save(outputFullFile, 'sim', 'job', '-v7.3');

    fprintf('*** ... outputs saved! :-) ***\n');
    % beep;

% ----------------------------------------------------------------------- %
%% Otherwise load:
else

    fprintf('*** File %s already exists; load file ... ***\n', outputFile);
    load(outputFullFile);
    fprintf('*** ... file loaded! :-) ***\n');

end % end of if outputFile exists

end % END OF FUNCTION.