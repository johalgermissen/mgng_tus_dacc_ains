% mgngtus_cbm06b_model_recovery.m

% Perform model recovery for range of selected models by:
% - loading fitted parameter values per subject;
% - fitting multivariate normal distribution to empirical parameter values;
% - sampling nSim new parameter combination from multivariate normal;
% - simulate new data sets given sampled parameter value combinations;
% - fit all models to all simulated data sets.
% 
% Evaluate model recovery via script
% mgngtus_cbm06c_model_recovery_eval.m.
%
% Modelled after:
% https://github.com/johalgermissen/Algermissen2024LM/blob/main/analyses/stan_scripts/model_recovery/run_model_recovery_simulate.R
% https://github.com/johalgermissen/Algermissen2024LM/blob/main/analyses/stan_scripts/model_recovery/run_model_recovery_fit.R
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% 00a) Set directories:

clear all; close all; clc

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));

dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% 00b) Fixed settings:

sonVec          = {'sham', 'dACC', 'aIns'};
nSon            = length(sonVec);

% ----------------------------------------------------------------------- %
%% 00c) Flexible settings:

% Model:
modVec      = [1 2 3 14 15 16 20];
% modVec      = 1:7;

nMod        = length(modVec);
% Fitting type (parameters to load):
parType     = 'lap';

% Number of simulations:
% nSim        = 10;
% nSim        = 100;
nSim        = 1000;

% Fit also HBI or not:
fitType     = 'lap';
% fitType     = 'hbi';

%% 01) Load parameters (for all 3 sessions, stack rows) for each model:

for iModGen = 1:nMod % iModGen = 7;

    % Extract model ID:
    modIDGen        = modVec(iModGen);

    % Prepare loading of models:
    cfg             = [];
    cfg.modID       = modIDGen;
    cfg.parType     = parType; % use only for LAP
    
    sonParamMat     = cell(nSon, 1); % initialise
    
    % Loop over sonication conditions, extract parameters:
    for iSon = 1:nSon
    
        % Extract sonication condition:
        cfg.dataType        = sonVec{iSon};
        % Load parameters:
        cbm                 = mgngtus_cbm_load_model(cfg);
        % Extract parameters:
        sonParamMat{iSon}   = cbm.subParamMat;
    end

    % Stack row-wise:
    empParamMat     = cell2mat(sonParamMat);

    % ------------------------------------------------------------------- %
    %% 02a) Sample new parameters from multivariate normal distribution:
    
    % Compose output file name:
    simParamFile        = sprintf('param_M%02d_nSim%04d.csv', ...
        modIDGen, nSim);
    simParamFullFile    = fullfile(dirs.modRecov, simParamFile);
    % cd(dirs.modRecov);
    
    % Save if sampled parameter file already exists:
    if exist(simParamFullFile, 'file')
        warning('*** File %s already exists; do not recreate', simParamFile);
    else

        fprintf('* ------------------------------------------------------ *\n');
        fprintf('*** Draw %d parameter combinations for model M%02d based on empirical parameters fitted with %s ... ***\n', ...
            nSim, modIDGen, parType);
        
        % Draw from multivariate normal distribution:
        % https://uk.mathworks.com/help/stats/mvnrnd.html
        % Sample 10 x as many parameters as needed:
        rng(70);
        simParamMat     = mvnrnd(mean(empParamMat, 1), cov(empParamMat), nSim * 10);
        
        % Select rows based on constraints:
        simParamMat     = mgngtus_parameter_constraints(simParamMat, modIDGen);
    
        % Select first nSim rows:
        if size(simParamMat, 1) < nSim
            error('*** M%02d: Only %d parameter combinations left, but %d requested ***', ...
                modIDGen, size(simParamMat, 1), nSim);
        else
            simParamMat     = simParamMat(1:nSim, :); % keep first nSim rows
        end
    
        % --------------------------------------------------------------- %
        % 02b) Save parameters:
        
        % Save if not existent:
        if exist(simParamFullFile, 'file')
            warning('*** File %s already exists; do not overwrite', simParamFile);
        else
            % Save:
            fprintf('*** Save file %s ... ***\n', simParamFile);
            writematrix(simParamMat, simParamFullFile);
            fprintf('*** ... finished! :-) ***\n');
        end % end if file already exists   
    end % end if file already exists   
    
    % ------------------------------------------------------------------- %
    % 02c) Load parameters again:
    
    % cd(dirs.modRecov);
    fprintf('*** Load file %s ... ***\n', simParamFile);
    simParamMat = readmatrix(simParamFullFile);
    fprintf('*** ... finished! :-) ***\n');
    
    % ------------------------------------------------------------------- %
    %% 03a) Simulate new data sets:
    % ---check which variables are needed?
    
    % Compose output file name:
    simDataFile     = sprintf('data_simulated_M%02d_nSim%04d.mat', ...
        modIDGen, nSim);
    simDataFullFile = fullfile(dirs.modRecov, simDataFile);
    % cd(dirs.modRecov);

    % Check if simulated data file already exists:
    if exist(simDataFullFile, 'file')
        warning('*** File %s already exists; do not recreate', simDataFile);
    else

        fprintf('* ---------------------------------------------------------- *\n');
        fprintf('*** Simulate data for %d subjects based on model M%02d ... ***\n', ...
            nSim, modIDGen);
        
        % Load scaffold for simulations:
        subj = sim_subj; % contains reqactions and feedback to compute feedback validity
        
        % Initialize:
        simData = cell(nSim, 1);
        
        % Simulate new data sets:
        rng(70);
        for iSim = 1:nSim % iSim = 1;
        
            % Extract parameters:
            parameters  = simParamMat(iSim, :); 
        
            % Simulate:
            out         = eval(sprintf('mgngtus_cbm_mod%02d_modSim(parameters, subj)', modIDGen));
        
            % Save data of simulated subject:
            simData{iSim}           = subj;
            simData{iSim}.response  = out.response;
            simData{iSim}.outcome   = out.outcome;
        
        end % end iSim

        % --------------------------------------------------------------- %
        % 03b) Save simulated data sets:
            
        % Save if not existent:
        if exist(simDataFullFile, 'file')
            warning('*** File %s already exists; do not overwrite', simDataFile);
        else
            % Save:
            fprintf('*** Save file %s ... ***\n', simDataFile);
            save(simDataFullFile , 'simData');
            fprintf('*** ... finished! :-) ***\n');
        end % end if file already exists

    end % end if simulations already exists
        
    % ------------------------------------------------------------------- %
    % 03c) Load simulated data sets back in:
    
    % cd(dirs.modRecov);
    % Load:
    fprintf('*** Load file %s ... ***\n', simDataFile);
    load(simDataFullFile);
    fprintf('*** ... finished! :-) ***\n');    

    % ------------------------------------------------------------------- %
    %% 04) Fit all possible model to simulated data set:
    
    fprintf('* ----------------------------------------------------------- *\n');
    fprintf('*** Prepare for fitting models %s to data set from M%02d, %d simulations ... ***\n', ...
        strjoin(string(modVec), ', '), modIDGen, nSim);
    
    priors = mgngtus_get_priors(); % retrieve priors

    % ------------------------------------ %
    % Loop over models:
    for iModFit = 1:nMod

        fprintf('* ====================================================================================================== *\n');

        % -------------------------------- %
        % Extract model ID:
        modIDFit        = modVec(iModFit);

        % -------------------------------- %
        % Compose output file name:
        modLapFile          = sprintf('param_fitted_genM%02d_fitM%02d_nSim%04d_lap.mat', ...
            modIDGen, modIDFit, nSim);
        fprintf('*** Model output file name will be %s ***\n', modLapFile);
        modLapFullFile      = fullfile(dirs.modRecov, modLapFile);
        % cd(dirs.modRecov);

        % -------------------------------- %
        % Fit model if not existent:
        if exist(modLapFullFile, 'file')
            warning('*** File %s already exists; do not overwrite', modLapFile);
        else
            % Fit model with LaPlace approximation:
            t1 = datetime("now");
            fprintf('*** Start time: %s\n', string(t1, 'HH:mm:ss'));
            fprintf('*** Fit model M%02d for file %s ... ***\n', modIDFit, modLapFile);
            cbm_lap(simData, eval(sprintf('@mgngtus_cbm_mod%02d', modIDFit)), priors{modIDFit}, modLapFullFile);
            fprintf('*** ... finished! :-) ***\n');
            t2 = datetime("now");
            fprintf('*** Stop time: %s ***\n', string(t2, 'HH:mm:ss'));
            elapsed_time = seconds(t2 - t1);
            fprintf('*** Elapsed time: %d minutes, %.03f seconds ***\n', floor(elapsed_time/60), mod(elapsed_time, 60));
        end % end if not fitted yet

    end % end iModFit
    
end % end iModGen

fprintf('*** Finished all simulations for model recovery! :-) ***\n');
beep;

% END OF FILE.