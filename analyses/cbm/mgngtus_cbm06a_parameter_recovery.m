% mgngtus_cbm06a_parameter_recovery.m

% Perform & evaluate parameter recovery for selected model by:
% - loading fitted parameter values per subject;
% - fitting multivariate normal distribution to empirical parameter values;
% - sampling nSim new parameter combination from multivariate normal;
% - simulate new data sets given sampled parameter value combinations;
% - fit model to all simulated data sets.
% - Correlate ground-truth against fitted parameters;
% - create permutation null distribution of on-diagonal correlations.
%
% Modelled after:
% https://github.com/johalgermissen/Algermissen2024NatComms/blob/main/Analyses/CBM_Scripts/EEGfMRIPav_cbm_parameter_recovery.m
% https://github.com/johalgermissen/Algermissen2024LM/tree/main/analyses/stan_scripts/parameter_recovery
% 
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% 00a) Set directories:

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
modID       = 7; % winning model: M7

% Fitting type (parameters to load):
parType     = 'lap';

% Number of simulations:
nSim        = 1000;

% Fit also HBI or not:
fitType     = 'lap';
% fitType     = 'hbi';

% Plotting settings:
savePNG     = false;
saveSVG     = false;

% ----------------------------------------------------------------------- %
%% 01) Load parameters (for all 3 sessions, stack rows):

cfg             = [];
cfg.modID       = modID;
cfg.parType     = parType; % use only for LAP

sonParamMat     = cell(nSon, 1);

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

% ----------------------------------------------------------------------- %
%% 02a) Sample new parameters from multivariate normal distribution:

fprintf('* ------------------------------------------------------ *\n');
fprintf('*** Draw %d parameter combinations for model M%02d based on empirical parameters fitted with %s ***\n', ...
    nSim, modID, parType);

% Draw from multivariate normal distribution:
% https://uk.mathworks.com/help/stats/mvnrnd.html
rng(70);            
groundTruthParamMat     = mvnrnd(mean(empParamMat, 1), cov(empParamMat), nSim);

% Constrain parameters to prevent infinite values:
groundTruthParamMat(groundTruthParamMat(:, 1) > 6, 1) = 6; % constrain maximum rho to 6

% ----------------------------------------------------------------------- %
% 02b) Save parameters:

% Compose file name:
groundTruthParamFile        = sprintf('param_ground_truth_M%02d_nSim%04d.csv', ...
    modID, nSim);
groundTruthParamFullFile    = fullfile(dirs.paramRecov, groundTruthParamFile);
% cd(dirs.paramRecov);

% Save if not existent:
if exist(groundTruthParamFullFile, 'file')
    warning('*** File %s already exists; do not overwrite', groundTruthParamFile);
else
    % Save:
    fprintf('*** Save file %s ... ***\n', groundTruthParamFile);
    writematrix(groundTruthParamMat, groundTruthParamFullFile);
    fprintf('*** ... finished! :-) ***\n');
end % end if file already exists

% ----------------------------------------------------------------------- %
% 02c) Load parameters again:

% cd(dirs.paramRecov);
fprintf('*** Load file %s ... ***\n', groundTruthParamFile);
groundTruthParamMat = readmatrix(groundTruthParamFullFile);
fprintf('*** ... finished! :-) ***\n');

% ----------------------------------------------------------------------- %
%% 03a) Simulate new data sets:
% ---check which variables are needed?

fprintf('* ---------------------------------------------------------- *\n');
fprintf('*** Simulate data for %d subjects based on model M%02d ... ***\n', ...
    nSim, modID);

% Load scaffold for simulations:
subj = sim_subj; % contains reqactions and feedback to compute feedback validity

% Initialize:
simData = cell(nSim, 1);

% Simulate new data sets:
rng(70);
for iSim = 1:nSim % iSim = 1;

    % Extract parameters:
    parameters  = groundTruthParamMat(iSim, :); 
    if(parameters(1)) > 6; parameters(1) = 6; end % set to maximum of 6

    % Simulate:
    out         = eval(sprintf('mgngtus_cbm_mod%02d_modSim(parameters, subj)', modID));

    % Save data of simulated subject:
    simData{iSim}           = subj;
    simData{iSim}.response  = out.response;
    simData{iSim}.outcome   = out.outcome;

end % end iSim

% ----------------------------------------------------------------------- %
% 03b) Save simulated data sets:

% Compose file name:
simDataFile     = sprintf('data_simulated_M%02d_nSim%04d.mat', ...
    modID, nSim);
simDataFullFile = fullfile(dirs.paramRecov, simDataFile);
% cd(dirs.paramRecov);

% Save if not existent:
if exist(simDataFullFile, 'file')
    warning('*** File %s already exists; do not overwrite', simDataFile);
else
    % Save:
    fprintf('*** Save file %s ... ***\n', simDataFile);
    save(simDataFullFile , 'simData');
    fprintf('*** ... finished! :-) ***\n');
end % end if file already exists

% ----------------------------------------------------------------------- %
% 03c) Load simulated data sets back in:

% cd(dirs.paramRecov);
% Load:
fprintf('*** Load file %s ... ***\n', simDataFile);
load(simDataFullFile);
fprintf('*** ... finished! :-) ***\n');

% ----------------------------------------------------------------------- %
%% 04a) Fit model to simulated data sets:

fprintf('* ----------------------------------------------------------- *\n');
fprintf('*** Prepare for fitting model M%02d with LAP, %d simulations ... ***\n', ...
    modID, nSim);

priors = mgngtus_get_priors(); % retrieve priors

% -------------------------------- %
% Compose output file name:
modLapFile          = sprintf('param_fitted_M%02d_nSim%04d_lap.mat', ...
    modID, nSim);
fprintf('*** Model output file name will be %s ***\n', modLapFile);
modLapFullFile      = fullfile(dirs.paramRecov, modLapFile);
modLapFullFileCell  = {modLapFullFile};

% -------------------------------- %
% Fit model if not existent:
if exist(modLapFullFile, 'file')
    warning('*** File %s already exists; do not overwrite', modLapFile);
else
    % Fit model with LaPlace approximation:
    t1 = datetime("now");
    fprintf('*** Start time: %s\n', string(t1, 'HH:mm:ss'));
    fprintf('*** Fit model %02d with LAP (%s) ... ***\n', modID, modLapFile);
    rng(70);
    cbm_lap(simData, eval(sprintf('@mgngtus_cbm_mod%02d', modID)), priors{modID}, modLapFullFile);
    fprintf('*** ... finished! :-) ***\n');
    t2 = datetime("now");
    fprintf('*** Stop time: %s ***\n', string(t2, 'HH:mm:ss'));
    elapsed_time = seconds(t2 - t1);
    fprintf('*** Elapsed time: %d minutes, %.03f seconds ***\n', floor(elapsed_time/60), mod(elapsed_time, 60));
end % end if file already exists

% ----------------------------------------------------------------------- %
%% 04b) Fit with HBI:

if strcmp(fitType, 'hbi')
    fprintf('* ----------------------------------------------------------- *\n');
    fprintf('*** Prepare for fitting model M%02d with HBI, %d simulations ... ***\n', ...
        modID, nSim);
    
    % -------------------------------- %
    % Compose output file name:
    modHbiFile      = sprintf('param_fitted_M%02d_nSim%04d_hbi.mat', ...
        modID, nSim);
    fprintf('*** Model output file name will be %s ***\n', modHbiFile);
    modHbiFullFile      = fullfile(dirs.paramRecov, modHbiFile);
    modHbiFullFileCell  = {modHbiFullFile};
    
    % -------------------------------- %
    % Fit model if not existent:
    if exist(modHbiFullFile, 'file')
        warning('*** File %s already exists; do not overwrite', modHbiFile);
    else
        % Fit model with LaPlace approximation:
        t1 = datetime("now");
        fprintf('*** Start time: %s\n', string(t1, 'HH:mm:ss'));
        fprintf('*** Fit model %02d with HBI (singular model) (%s) ... ***\n', modID, modHbiFile);
        modelCode       = {eval(sprintf('@mgngtus_cbm_mod%02d', modID))};
        rng(70);
        cbm_hbi(simData, modelCode, modLapFullFileCell, modHbiFullFileCell);
        fprintf('*** ... finished! :-) ***\n');
        t2 = datetime("now");
        fprintf('*** Stop time: %s ***\n', string(t2, 'HH:mm:ss'));
        elapsed_time = seconds(t2 - t1);
        fprintf('*** Elapsed time: %d hours, %d minutes, %.03f seconds ***\n', ...
            floor(elapsed_time/3600), floor(elapsed_time/60), mod(elapsed_time, 60));
    end % end if file already exists
end % end isHBI

% ----------------------------------------------------------------------- %
%% 05) Load fitted model output, extract fitted parameters:

% Load model output:
if strcmp(fitType, 'lap')
    fprintf('*** Load fitted parameters from model %s ... ***\n', modLapFile);
    tmp         = load(modLapFullFile);
    % Extract parameters:
    fitParamMat = tmp.cbm.output.parameters;
elseif strcmp(fitType, 'hbi')
    fprintf('*** Load fitted parameters from model %s ... ***\n', modHbiFile);
    tmp         = load(modHbiFullFile);
    % Extract parameters:
    fitParamMat = tmp.cbm.output.parameters{:};
else
    error('Unknown fit type %s', fitType);
end

% ----------------------------------------------------------------------- %
%% 06a) Plot histogram of fitted parameters, detect outliers:

% Transform parameters:
groundTruthParamMatTransf   = transform_parameters(groundTruthParamMat, modID);
fitParamMatTransf           = transform_parameters(fitParamMat, modID);

% Determine parameter names:
tmp             = format_paramNames(modID);
paramNames      = tmp.paramNames;
paramNamesPlot  = tmp.paramNamesLaTeX;

% Plotting settings:
FTS             = 24; % font size
LWD             = 5; % line width

% ----------------------------------------- %
% Loop over parameters:
nParam = size(fitParamMat, 2);
for iParam = 1:nParam

    % Select parameter:
    % y = fitParamMat(:, iParam);        
    y = fitParamMatTransf(:, iParam);        
    
    % Plot:
    close gcf;
    figure('Position', [100 100 800 800], 'Color', 'white'); hold on
    histfit(y); box off
    % Other plotting settings:
    set(gca, 'Linewidth', LWD, 'FontSize', FTS, 'TickLabelInterpreter', 'latex');
    % Labels and title:
    xlabel([paramNamesPlot{iParam}, ', fitted'], 'interpreter', 'latex');
    title(sprintf('Model %02d: Parameter %s', ...
        cfg.modID, paramNamesPlot{iParam}), ...
        'interpreter','latex');

    % Print descriptives to console:
    fprintf('*** Model %02d: Parameter %d (%s), mean %0.2f, std %.02f, range %.02f - %.02f ***\n', ...
    cfg.modID, iParam, paramNames{iParam}, nanmean(y), nanstd(y), nanmin(y), nanmax(y));

    waitforbuttonpress;
    close gcf

end

% ----------------------------------------------------------------------- %
%% 06b) Bivariate correlations ground-truth parameters against fitted parameters:

close all;
fprintf('* --------------------------------------------------------- *\n');

% Create target directory:
dirs.tmp = fullfile(dirs.plot, 'parameter_recovery');
if ~exist(dirs.tmp, 'dir'); mkdir(dirs.tmp); end

cd(dirs.paramRecov);

% Determine parameter names:
tmp             = format_paramNames(modID);
paramNames      = tmp.paramNames;
paramNamesPlot  = tmp.paramNamesLaTeX;

% Transform parameters:
groundTruthParamMatTransf   = transform_parameters(groundTruthParamMat, modID);
fitParamMatTransf           = transform_parameters(fitParamMat, modID);

% ----------------------------------------- %
% Plot settings:
CPS             = 12; % cap size for whiskers
FTS             = 24; % font size
FTT             = 'Arial'; % font type
LWD             = 5; % line width
% MKS             = 25; % marker size for dots (.)
MKS             = 8; % marker size for asterisks (*)

% Plotting settings:
% savePNG   = true;
% savePNG   = false;
% saveSVG   = true;
% saveSVG   = false;

% ----------------------------------------- %
% Loop over parameters:
nParam = size(fitParamMat, 2);
for iParam = 1:nParam

    % Extract untransformed parameter vectors:
    % x = groundTruthParamMat(:, iParam);
    % y = fitParamMat(:, iParam);         

    % Extract transformed parameter vectors:
    x = groundTruthParamMatTransf(:, iParam);
    y = fitParamMatTransf(:, iParam);

    % Exclude outliers:
    % validIdx = ones(size(y)) == 1;
    % if strcmp(paramNames{iParam}, 'rho'); validIdx = y < 200; end
    % if strcmp(paramNames{iParam}, 'kappa'); validIdx = y < 4; end
    validIdx = fitParamMatTransf(:, 1) < 200;
    x = x(validIdx);
    y = y(validIdx);
    
    % Regression and predicted values:
    p       = polyfit(x', y', 1);
    yhat    = polyval(p, x);
    corVal  = corr(x, y); % correlation
                
    % Plot:
    % close all
    figure('Position', [100 100 700 700], 'Color', 'white'); hold on

    % Points:
    plot(x, y, '*', 'Color', [0.7 0.7 0.7], LineWidth = LWD, MarkerSize = MKS); % points (. or *)
    % Regression line:
    plot(x, yhat, 'r-', LineWidth = LWD); % regression line
    % Identiy line:
    minLim = min([x; y]); 
    maxLim = max([x; y]); 
    % Axis settings:
    plot([minLim maxLim], [minLim maxLim], 'k--', LineWidth = 1); % regression line
    axis([minLim maxLim minLim maxLim]); % scale axes
    axis equal;
    % Other plotting settings:
    set(gca, 'Linewidth', LWD, 'FontSize', FTS, 'TickLabelInterpreter', 'latex');
    % Labels and title:
    xlabel([paramNamesPlot{iParam}, ', ground truth'], 'interpreter', 'latex');
    ylabel([paramNamesPlot{iParam}, ', fitted'], 'interpreter', 'latex');
    title(sprintf('Model %02d: Parameter %s, cor = %0.2f', ...
        modID, paramNamesPlot{iParam}, corVal), ...
        'interpreter','latex');
    fprintf('*** Model %02d: Parameter %d (%s), cor = %0.2f ***\n', ...
        modID, iParam, paramNames{iParam}, corVal);
    
    % Save:
    figName = sprintf(sprintf('parameter_recovery_mod%02d_nSim%04d_%s_param%02d', ...
        modID, nSim, fitType, iParam));
    % savePNG = 0; saveSVG = 0;
    savePNG = 1; saveSVG = 1;
    if savePNG; saveas(gcf, fullfile(dirs.plot, 'parameter_recovery', [figName '.png'])); end
    if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

    % Advance with button press:
    % waitforbuttonpress;
    % pause(2)
    close gcf
end
fprintf('Finished :-)\n')

% cd(dirs.paramRecov);

% ----------------------------------------------------------------------- %
%% 06c) Correlation matrix ground-truth parameters against fitted parameters:

% Determine parameter names:
tmp                         = format_paramNames(modID);
paramNames                  = tmp.paramNames;
paramNamesPlot              = tmp.paramNamesLaTeX;

% Transform parameters:
groundTruthParamMatTransf   = transform_parameters(groundTruthParamMat, modID);
fitParamMatTransf           = transform_parameters(fitParamMat, modID);

% Exclude outliers:
validIdx = ones(size(y)) == 1;
validIdx = fitParamMatTransf(:, 1) < 200;

% Compute correlation matrix:
% corrMat                     = corr(groundTruthParamMat(validIdx, :), fitParamMat(validIdx, :));
corrMat                     = corr(groundTruthParamMatTransf(validIdx, :), fitParamMatTransf(validIdx, :));

% Set config file;
cfg             = [];
cfg.tickNames   = cellfun(@(x) strrep(x, '$', ''), paramNamesPlot, 'UniformOutput', false);
cfg.xLabel      = 'Ground truth parameters';
cfg.yLabel      = 'Fitted parameters';
cfg.title       = sprintf('M%02d: Ground truth vs. fitted parameters', modID);
cfg.isNewFig    = true;
cfg.FTS         = 18; 

% Plot:
mgngtus_custom_corrplot(cfg, corrMat);
% 
% Save:
figName = sprintf(sprintf('parameter_recovery_mod%02d_nSim%04d_%s_intercorrelations', ...
    modID, nSim, fitType));
% savePNG = 0; saveSVG = 0;
% savePNG = 1; saveSVG = 1;
if savePNG; saveas(gcf, fullfile(dirs.plot, 'parameter_recovery', [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

waitforbuttonpress;
close gcf;

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 07a) Create permutation null distribution:

% Determine parameter names:
tmp                         = format_paramNames(modID);
paramNames                  = tmp.paramNames;
paramNamesPlot              = tmp.paramNamesLaTeX;

% ------------------------------------------- %
% Transform parameters:
groundTruthParamMatTransf   = transform_parameters(groundTruthParamMat, modID);
fitParamMatTransf           = transform_parameters(fitParamMat, modID);

% ------------------------------------------- %
% Exclude outliers:
validIdx = ones(size(y)) == 1;
validIdx = fitParamMatTransf(:, 1) < 200;

groundTruthParamMatTransf   = groundTruthParamMatTransf(validIdx, :);    
fitParamMatTransf           = fitParamMatTransf(validIdx, :);    

% Empirical correlations:
corrMat                     = corr(groundTruthParamMatTransf, fitParamMatTransf);
diagCorrVec                 = diag(corrMat);

% Dimensions:
nSim                        = size(groundTruthParamMatTransf, 1);
nParam                      = size(groundTruthParamMatTransf, 2);

% ------------------------------------------- %
% Initialize:
nPerm           = 1000; % number of permutations
diagPermMat     = nan(nPerm, nParam);

% ------------------------------------------- %
% Loop over permutations:

fprintf('* -------------------------------------------------------- * \n');
fprintf('*** Create permutation null distribution ... ***\n');

rng(70);
fprintf('*** Start permutation %04d/%04d', 0, nPerm);
for iPerm = 1:nPerm

    fprintf('\b\b\b\b\b\b\b\b\b%04d/%04d', iPerm, nPerm);
    
    % Permute order randomly:
    rowIdxPerm              = randperm(nSim);

    % Compute correlation with fitted parameters permuted:
    permMat                 = corr(groundTruthParamMatTransf, fitParamMatTransf(rowIdxPerm, :));

    % Save maximum on-diagonal element:
    diagPermMat(iPerm, :)   = max(diag(permMat));

end % end iPerm
fprintf('\n*** .... finished! :-) ***\n');

diagPermVec = diagPermMat(:); % to vector

% ----------------------------------------------------------------------- %
%% 04b) Evaluate permutation null distribution:

% Plot histogram:
close gcf
% figure; plot(diagPermVec);
% figure; histogram(diagPermVec, 0.02:0.02:0.95);
% figure; histogram(diagPermVec, 0.02:0.02:0.40);
figure; histfit(diagPermVec);

% Plot percentiles:
fprintf('*** 95th percentile of permutation null distribution with %04d simulations: %.03f ***\n', nSim, prctile(diagPermVec, 95));
% *** 95th percentile of permutation null distribution with 1000 simulations: 0.171 ***
% prctile(diagPermVec, [0:5:100])

% Assuming diagPermVec, forwConfMat, and invConfMat are already defined

% ----------------------------------------------------------------------- %
%% 04c) Plot permutation null distribution as histogram:

% Plotting settings:
FTS         = 16;
LWD         = 3;

% Start figure:
figure('Position', [100 100 800 800], 'Color', 'white'); hold on

% Plot the histogram:
histogram(diagPermVec, 'FaceColor', 'k'); hold on % histogram in black
hold on;

% Add vertical red lines for forward confusion matrix diagonal:
for i = 1:length(diagCorrVec)
    xline(diagCorrVec(i), 'r--', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2);
end

% Add labels and title:
xlabel('Correlation');
ylabel('Frequency');
title('On-diagonal correlations against permutation null distribution');
set(gca, 'Linewidth', LWD, 'FontSize', FTS);

% Save:
figName = sprintf(sprintf('permutation_null_distribution_M%0s_nSim%04d_parameter_recovery', ...
    strjoin(string(modVec), '_'), nSim));
% savePNG = 0; saveSVG = 0;
savePNG = 1; saveSVG = 1;
if savePNG; saveas(gcf, fullfile(dirs.plot, 'parameter_recovery', [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

% END OF FILE.