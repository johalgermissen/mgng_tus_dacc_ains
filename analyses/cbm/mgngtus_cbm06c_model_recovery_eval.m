% mgngtus_cbm06c_model_recovery_eval.m

% Evaluate model recovery results after running script
% mgngtus_cbm06b_model_recovery_fit.m.
%
% Specifically,
% - find best fitting model per simulated data set (based on log-model
% evidence or AIC or BIC).
% - compute and plot forward confusion matrix;
% - compute and plot inverse confusion matrix;
% - create permutation null distribution of on-diagonal probabilities.
%
% Modelled after:
% https://github.com/johalgermissen/Algermissen2024LM/blob/main/analyses/stan_scripts/model_recovery/eval_model_recovery.R
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
%% 00b) Flexible settings:

% ----------------- %
% a) Model:
modVec      = [1 2 3 14 15 16 20];

nMod        = length(modVec);

% ----------------- %
% b) Number of simulations:
% nSim        = 10;
% nSim        = 100;
nSim        = 1000;

% ----------------- %
% c) Fit also HBI or not:
fitType     = 'lap';
% fitType     = 'hbi';

% ------------------------------------ %
% d) Plotting settings:

% savePNG     = true;
savePNG     = false;
% saveSVG     = true;
saveSVG     = false;

pauseDuration = 3;

fprintf('*** Evaluate model recovery for models %s based on %d simulations ... ***\n', ...
    strjoin(string(modVec), ', '), nSim);

% ----------------------------------------------------------------------- %
%% 01a) Load all fitted models, extract log model evidence:

% Load fitted model output, extract log-model evidence:
% cd(dirs.modRecov)

fprintf('* -------------------------------------------------------- *\n');

% Initialize:
% modGen, modFit, iSim, logModEvi, logLik, AIC, BIC
modGenIdx = 1; modFitIdx = 2; simIdx = 3; logEviIdx = 4; logLikIdx = 5; aicIdx = 6; bicIdx = 7;
nRecov                   = nMod * nMod * nSim;
recovMat                = nan(nRecov, 7);
recovMat(:, modGenIdx)  = repelem(modVec, nMod * nSim); % modIDGen
recovMat(:, modFitIdx)  = repmat(repelem(modVec', nSim), nMod, 1); % modIDFit
recovMat(:, simIdx)     = repmat((1:nSim)', nMod^2, 1); % iSim

% Loop over models used to generate data:
for iModGen = 1:nMod % iModGen = 1;

    modIDGen = modVec(iModGen);

    % Load simulated data:
    simDataFile     = sprintf('data_simulated_M%02d_nSim%04d.mat', ...
    modIDGen, nSim);
    simDataFullFile = fullfile(dirs.modRecov, simDataFile);
    fprintf('* --------------------------------- *\n');
    fprintf('*** Load data imulated for M%02d ...***\n', modIDGen);
    load(simDataFullFile);

    % Loop over models used to fit data:
    for iModFit = 1:nMod % iModFit = 1;

        modIDFit = modVec(iModFit);

        % Identify rows:
        rowIdx              = recovMat(:, modGenIdx) == modIDGen & recovMat(:, modFitIdx) == modIDFit;

        % Compose input file name:
        modLapFile          = sprintf('param_fitted_genM%02d_fitM%02d_nSim%04d_lap.mat', ...
            modIDGen, modIDFit, nSim);
        fprintf('*** Load %s fit for data M%02d fit with M%02d ... ***\n', fitType, modIDGen, modIDFit);
        % Load model fit:
        modLapFullFile              = fullfile(dirs.modRecov, modLapFile);
        tmp                         = load(modLapFullFile);
        % Extract log model evidence:
        recovMat(rowIdx, logEviIdx) = tmp.cbm.output.log_evidence;
        allParamMat                 = tmp.cbm.output.parameters;
        % Compute AIC/BIC:
        [aicVec, bicVec, logLikVec] = mgngtus_cbm_compute_loglik(simData, allParamMat, modIDFit);
        recovMat(rowIdx, logLikIdx) = logLikVec;
        recovMat(rowIdx, aicIdx)    = aicVec;
        recovMat(rowIdx, bicIdx)    = bicVec;

    end % end iFitGen
end % end iModGen
fprintf('*** .... finished! :-) ***\n');

% ----------------------------------------------------------------------- %
%% 01b) Save fit indices:

% Compose file name:
recovFile           = sprintf('recov_fit_indices_M%s_nSim%04d_lap.mat', ...
    strjoin(string(modVec),  '_'), nSim);
recovFullFile       = fullfile(dirs.modRecov, recovFile);

% Save if not existent:
if exist(recovFullFile, 'file')
    warning('*** File %s already exists; do not overwrite', recovFile);
else
    fprintf('*** Save file %s ... ***\n', recovFile);
    save(recovFullFile , 'recovMat');
    fprintf('*** ... finished! :-) ***\n');
end

% ----------------------------------------------------------------------- %
%% 01c) Load fit indices:

% Compose file name:
recovFile           = sprintf('recov_fit_indices_M%s_nSim%04d_lap.mat', ...
    strjoin(string(modVec),  '_'), nSim);
recovFullFile       = fullfile(dirs.modRecov, recovFile);

% Load file if existent:
if ~exist(recovFullFile, 'file')
    error('*** File %s does not exist; cannot load it', recovFile);
else
    fprintf('*** Load file %s ... ***\n', recovFile);
    load(recovFullFile);
    fprintf('*** ... finished! :-) ***\n');    
end

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 02a) Compute forward confusion matrix:

fprintf('* -------------------------------------------------------- * \n');
fprintf('*** Compute forward confusion matrix ... ***\n');
forwConfMat     = nan(nMod, nMod); % initialize

for iModGen = 1:nMod % iModGen = 1;

    modIDGen = modVec(iModGen);

    % Winning model for data generated with modIDGen:
    winModVec = zeros(1, nSim);

    % Loop over data sets:
    for iSim = 1:nSim % iSim = 1;

        % Identify rows:
        rowIdx              = recovMat(:, modGenIdx) == modIDGen & recovMat(:, simIdx) == iSim;
        % find(rowIdx)
        % sum(rowIdx)
        % recovMat(rowIdx, :)

        % Determine winning model for this data set:
        [~, winIdx]         = max(recovMat(rowIdx, logEviIdx)); metricName = 'logmodevi';
        % [~, winIdx]         = max(recovMat(rowIdx, logLikIdx)); metricName = 'loglik';
        % [~, winIdx]         = min(recovMat(rowIdx, aicIdx)); metricName = 'aic';
        % [~, winIdx]         = min(recovMat(rowIdx, bicIdx)); metricName = 'bic';

        winModVec(iSim)     = modVec(winIdx); % save index of winning model

    end % end iSim

    % Count for each fitted model ID how many data sets it wins:
    for iModFit = 1:nMod % iModFit =  1
        modIDFit = modVec(iModFit);
        forwConfMat(iModGen, iModFit) = sum(winModVec == modIDFit)/nSim;
    end

end % end iModGen

if any(round(sum(forwConfMat, 2), 3) ~= 1); error('Columns of forward confusion matrix do not sum up to 1'); end

% Inspect:
% diag(forwConfMat) % inspect diagonal
% median(diag(forwConfMat))
% min(diag(forwConfMat))
% max(diag(forwConfMat))

% ----------------------------------------------------------------------- %
%% 02b) Plot forward confusion matrix:

% Rows are generative model, columns are fitted model

% Set config file:
cfg             = [];
% cfg.tickNames   = modVec;
cfg.tickNames   = 1:nMod;
cfg.xLabel      = 'Generative model'; % generative model in columns in plot
cfg.yLabel      = 'Fitted model'; % fitted model in rows in plot
cfg.cLabel      = 'Conditional probability'; 
cfg.title       = 'Forward confusion matrix';
cfg.isNewFig    = true;
cfg.FTS         = 18; 
cfg.cLim        = [0 1];
cfg.colMap      = 'YlOrRd';

% Plot:
mgngtus_custom_corrplot(cfg, forwConfMat);

% Save:
figName = sprintf(sprintf('forward_confusion_matrix_M%0s_nSim%04d_%s', ...
    strjoin(string(modVec), '_'), nSim, metricName));
savePNG = 0; saveSVG = 0;
% savePNG = 1; saveSVG = 1;
if savePNG; saveas(gcf, fullfile(dirs.plot, 'model_recovery', [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

% pause(pauseDuration);
% close gcf;

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 03a) Compute inverse confusion matrix:

fprintf('* -------------------------------------------------------- * \n');
fprintf('*** Compute inverse confusion matrix ... ***\n');
forwCountMat    = forwConfMat * nSim; % convert back into absolute frequencies
invConfMat      = nan(nMod, nMod); % initialize

for iModFit = 1:nMod
    % Among all data sets where modIDFit wins: how often was it each generative model?
    invConfMat(:, iModFit) = forwCountMat(:, iModFit)/sum(forwCountMat(:, iModFit));
end

if any(round(sum(invConfMat, 1), 3) ~= 1); error('Rows of inverse confusion matrix do not sum up to 1'); end

% Inspect:
% diag(forwConfMat) % inspect diagonal
median(diag(invConfMat))
min(diag(invConfMat))
max(diag(invConfMat))

% ----------------------------------------------------------------------- %
%% 03b) Plot inverse confusion matrix:

% Rows are generative model, columns are fitted model

% Set config file:
cfg             = [];
% cfg.tickNames   = modVec;
cfg.tickNames   = 1:nMod;
cfg.xLabel      = 'Generative model'; % generative model in columns of plot
cfg.yLabel      = 'Fitted model'; % fitted model in rows of plot
cfg.cLabel      = 'Conditional probability'; 
cfg.title       = 'Inverse confusion matrix';
cfg.isNewFig    = true;
cfg.FTS         = 18; 
cfg.cLim        = [0 1];
cfg.colMap      = 'YlOrRd';

% Plot:
mgngtus_custom_corrplot(cfg, invConfMat);

% Save:
figName = sprintf(sprintf('inverse_confusion_matrix_M%0s_nSim%04d_%s', ...
    strjoin(string(modVec), '_'), nSim, metricName));
savePNG = 0; saveSVG = 0;
% savePNG = 1; saveSVG = 1;
if savePNG; saveas(gcf, fullfile(dirs.plot, 'model_recovery', [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

% pause(pauseDuration);
% close gcf;

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 04a) Create permutation null distribution on on-diagonal elements of matrices:

% Initialize:
nPerm           = 1000; % number of permutations
maxDiagPermVec  = nan(1, nPerm);
diagPermMat     = nan(nPerm, nMod);


fprintf('* -------------------------------------------------------- * \n');
fprintf('*** Create permutation null distribution with %d permutations ... ***\n', nPerm);

% Loop over permutations:
rng(70);
fprintf('*** Start permutation %04d/%04d', 0, nPerm);
for iPerm = 1:nPerm

    fprintf('\b\b\b\b\b\b\b\b\b%04d/%04d', iPerm, nPerm);
    permMat     = nan(nMod, nMod); % initialize

    for iModGen = 1:nMod % iModGen = 1;
        modIDGen = modVec(iModGen);

            % Winning model for data generated with modIDGen:
            winModVec = zeros(1, nSim);
                
        % Loop over data sets:
        for iSim = 1:nSim % iSim = 1;
    
            % Identify rows:
            rowIdx              = find(recovMat(:, modGenIdx) == modIDGen & recovMat(:, simIdx) == iSim);
            % sum(rowIdx)
            % find(rowIdx)
            % recovMat(rowIdx, :)    
    
            % Permute order randomly:
            rowIdxPerm          = rowIdx(randperm(length(rowIdx)));

            % Find winning index:
            [~, winIdx]         = max(recovMat(rowIdxPerm, logEviIdx));
            % [~, winIdx]         = max(recovMat(rowIdxPerm, logLikIdx));
            % [~, winIdx]         = min(recovMat(rowIdxPerm, aicIdx));
            % [~, winIdx]         = min(recovMat(rowIdxPerm, bicIdx));

            winModVec(iSim)     = modVec(winIdx); % save index of winning model

        end % end iSim
    
        % Count for each fitted model ID how many data sets it wins:
        for iModFit = 1:nMod % iModFit =  1
            modIDFit = modVec(iModFit);
            permMat(iModGen, iModFit) = sum(winModVec == modIDFit)/nSim;
        end % end iModGen
    end % end iModGen

    % Save maximum on-diagonal element:
    maxDiagPermVec(iPerm)   = max(diag(permMat));
    diagPermMat(iPerm, :)   = diag(permMat);

end % end iPerm
fprintf('\n*** .... finished! :-) ***\n');

% ----------------------------------------------------------------------- %
%% 04b) Evaluate permutation null distribution:

% Plot histogram:
close gcf
% figure; plot(maxDiagPermVec);
% figure; histogram(maxDiagPermVec, 0.02:0.02:0.95);
% figure; histogram(maxDiagPermVec, 0.02:0.02:0.40);
figure; histfit(maxDiagPermVec);

% Plot percentiles:
fprintf('*** 95th percentile of permutation null distribution with %04d simulations: %.03f ***\n', nSim, prctile(maxDiagPermVec, 95));
% *** 95th percentile of permutation null distribution with 1000 simulations: 0.171 ***
% prctile(maxDiagPermVec, [0:5:100])
% Columns 1 through 17
% 
%   0.1410    0.1470    0.1490    0.1510    0.1520    0.1530    0.1540    0.1550    0.1560    0.1570    0.1580    0.1580    0.1590    0.1600    0.1610    0.1620    0.1635
% 
% Columns 18 through 21
% 
%   0.1650    0.1670    0.1705    0.1890

% Assuming maxDiagPermVec, forwConfMat, and invConfMat are already defined

% ----------------------------------------------------------------------- %
%% 04c) Plot permutation null distribution as histogram:

% Plotting settings:
FTS         = 18;
LWD         = 3;

% Start figure:
figure('Position', [100 100 800 800], 'Color', 'white'); hold on

% Plot the histogram:
histogram(maxDiagPermVec, 'FaceColor', 'k'); hold on % histogram in black
hold on;

% Extract diagonal elements from confusion matrices:
diagForw    = diag(forwConfMat);
diagInv     = diag(invConfMat);

% Add vertical red lines for forward confusion matrix diagonal:
for i = 1:length(diagForw)
    xline(diagForw(i), 'k--', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2);
end
% Add vertical blue lines for inverse confusion matrix diagonal:
for i = 1:length(diagInv)
    xline(diagInv(i), 'k--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2);
end

% Add labels and title:
xlabel('Conditional probability');
ylabel('Frequency');
title('Diagonal probabilities against permutation null distribution');
set(gca, 'Linewidth', LWD, 'FontSize', FTS);

% Save:
figName = sprintf(sprintf('permutation_null_distribution_M%0s_nSim%04d_%s', ...
    strjoin(string(modVec), '_'), nSim, metricName));
savePNG = 0; saveSVG = 0;
% savePNG = 1; saveSVG = 1;
if savePNG; saveas(gcf, fullfile(dirs.plot, 'model_recovery', [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

% END OF FILE.