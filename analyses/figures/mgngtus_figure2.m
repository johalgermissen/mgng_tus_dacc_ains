% mgngtus_figure2.m
%
% Code to reproduce empirical data figures in Fig. 2D-K in the main
% text.
% 
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% Initialize directories and configurations:

% Add CBM functions:
addpath(fullfile(fileparts(fileparts(matlab.desktop.editor.getActiveFilename)), 'cbm'));

dirs            = mgngtus_cbm_set_dirs();

cfg             = mgngtus_cbm_set_config();

% ----------------------------------------------------------------------- %
%% Fig. 2D: Learning curves responses ~ req. action x valence, empirical.

cfg.dataType    = 'sham';

% Load data:
fprintf('*** Load %s data ***\n', cfg.dataType);
inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
fdata           = load(inputFile); % only contains .data
rawData         = fdata.data; % extract .data
cfg.nSub        = length(rawData);

% Aggregate data:
aggrData        = mgngtus_aggregate_empirical_data(rawData);

% Title and handle for all plots:
cfg.plotTitle   = sprintf('Empirical data (%s)', cfg.dataType);
cfg.plotHandle  = sprintf('empirical_%s', cfg.dataType);

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:cfg.nSub, invalidSubs);
nSubValid       = length(validSubs);

plotCfg         = [];
plotCfg.xLab    = 'Trial';
plotCfg.yLab    = 'p(Go)';
plotCfg.title   = cfg.plotTitle;
plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red

% Plot:
close gcf
custom_lineplot(plotCfg, aggrData.pGoSubCondRep(validSubs, :, :));

% Save:
savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2D_G2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 1, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig2D_G2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 2, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig2D_NG2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 3, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig2D_NG2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 4, :)));

% ----------------------------------------------------------------------- %
%% Fig. 2E: Bar plot p(repeat) ~ last response x last outcome, empirical.

cfg.dataType    = 'sham';

% Load data:
fprintf('*** Load %s data ***\n', cfg.dataType);
inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
fdata           = load(inputFile); % only contains .data
rawData         = fdata.data; % extract .data
cfg.nSub        = length(rawData);

% Aggregate data:
aggrData        = mgngtus_aggregate_empirical_data(rawData);

% Title and handle for all plots:
cfg.plotTitle   = sprintf('Empirical data (%s)', cfg.dataType);
cfg.plotHandle  = sprintf('empirical_%s', cfg.dataType);

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:cfg.nSub, invalidSubs);
nSubValid       = length(validSubs);

plotCfg         = [];
plotCfg.xLab    = 'Performed action';
plotCfg.xTick       = [1.5 3.5 5.5 7.5];
plotCfg.xTickLabel  = {'Go', 'NoGo', 'Go', 'NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

outColMat       = [0 113 116; 87 196 173; 240 174 102; 201 61 33] ./ 255; % dark green, red
outColMat       = repmat(outColMat, 2, 1); % duplicate;

plotCfg.addPoints  = true;
plotCfg.addLines   = true;

condOrder       = [1 4 5 8]; % GoRew GoPun NoGoRew NoGoPun GoNoPun GoNoRew NoGoNoPun NoGoNoRew
plotCfg.colMat  = outColMat(condOrder, :); % overwrite colour map

% Plot:
close gcf
custom_barplot(plotCfg, aggrData.pStayRespValOut(validSubs, condOrder));

% Save:
savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_out_valenced_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_out_valenced_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2E.csv'));
csvwrite(fullFileName, squeeze(aggrData.pStayRespValOut(validSubs, condOrder)));

% ----------------------------------------------------------------------- %
%% Fig. 2F: Bar plot p(repeat) ~ cue valence, empirical.

cfg.dataType    = 'sham';

% Load data:
fprintf('*** Load %s data ***\n', cfg.dataType);
inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
fdata           = load(inputFile); % only contains .data
rawData         = fdata.data; % extract .data
cfg.nSub        = length(rawData);

% Aggregate data:
aggrData        = mgngtus_aggregate_empirical_data(rawData);

% Title and handle for all plots:
cfg.plotTitle   = sprintf('Empirical data (%s)', cfg.dataType);
cfg.plotHandle  = sprintf('empirical_%s', cfg.dataType);

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:cfg.nSub, invalidSubs);
nSubValid       = length(validSubs);

plotCfg         = [];
plotCfg.xLab    = 'Cue valence';
plotCfg.xTick       = [1 2];
plotCfg.xTickLabel  = {'Win', 'Avoid'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.title   = cfg.plotTitle;
plotCfg.colMat  = [137 177 209; 211 160 132] ./ 255; % blue, red

plotCfg.addPoints  = true;
plotCfg.addLines   = false;

% Plot:
close gcf
custom_barplot(plotCfg, aggrData.pStayVal(validSubs, :));

% Save:
savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_val_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_val_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2F.csv'));
csvwrite(fullFileName, squeeze(aggrData.pStayVal(validSubs, :)));

% ----------------------------------------------------------------------- %
%% Fig. 2G: Model evidence per model:

cfg.dataType    = 'sham';
cfg.nSub        = 29; % just for initializing

% General plotting settings:
MKS             = 10;
FTS             = 20;
LWD             = 3;

% Select models to load:
modRange        = 1:7;

nMod            = max(modRange); % must be maximum model ID

% Initialize output names for loading model outputs:
fprintf('Initialize output file names\n')
fname_mod = struct([]);
for iMod = 1:nMod
    fname_mod{iMod} = fullfile(dirs.lap, sprintf('lap_%s_mod%02d.mat', cfg.dataType, iMod));
end

% Load log-model evidence per model per subject:
logEvi = nan(cfg.nSub, nMod);
for iMod = modRange % nMod = 5;
    fprintf('Load log-model evidence for model %02d\n', iMod);
    fname = load(fname_mod{iMod});
    cbm   = fname.cbm;
    logEvi(:, iMod) = cbm.output.log_evidence;
end

% Select models to plot:
modVec          = modRange;

% Select subjects:
validSubs       = 1:cfg.nSub;
cfg.nSubValid   = length(validSubs);

% Select subjects and models to plot:
selLogEvi       = logEvi(validSubs, modVec);

% Create model names for x-axis:
modNames        = modVec;

assert(length(modVec) == length(modNames));
modLabels   = strcat('M', string(modNames)); % true labels according to names given modNames
modFile     = strcat('M', string(modVec));

% Aggregate & correct SEs for between-subjects variability:
subMean     = mean(selLogEvi, 2); % average across models
grandMean   = mean(subMean); % average across subjects
condMean    = mean(selLogEvi, 1); % average across subjects
condSE      = withinSE(selLogEvi); % compute SE per model

% X-axis:
xLoc        = 1:nModPlot;
xTickLabel  = modLabels;

% Colour map for non-winning models:
colMat     = repmat([240 240 240] ./ 255, nModPlot, 1); % gray

% Highlight best fitting model:
[~, bestIdx]        = max(condMean);
colMat(bestIdx, :)  = [179 155 197] ./ 255; % purple

% Plotting settings:
CPS         = 12; 
FTS         = 28; % 36
LWD         = 4; 
fontType    = 'Arial';

addLines    = true; % connect individual data points from same subject or not

% Start plot:
close gcf
figure('Color', 'white', 'Position', [0 0 800 800]); hold on % for PuG

% Plot bars with errorbars:
if addLines; jitterMag = 0; else jitterMag = 0.15; end
for iMod = 1:nModPlot
    % Bars:
    bar(xLoc(iMod), condMean(iMod), .75, 'FaceColor', colMat(iMod, :)); % bar plot
    errorbar(xLoc(iMod), condMean(iMod), condSE(iMod), ...
        'k', 'linestyle', 'none', 'LineWidth', LWD, 'CapSize', CPS); % error bars
    % Points:
    s = scatter(repmat(xLoc(iMod), 1, cfg.nSubValid), selLogEvi(:, iMod)', ...
        [], 'k', 'jitter', 'on', 'jitterAmount', jitterMag); hold on % was 0.05
    set(s, 'MarkerEdgeColor', [0.4 0.4 0.4], 'LineWidth', 3); % was 1 
end

% Lines:
if addLines
    for iSub = 1:cfg.nSubValid
        p = plot(xLoc, selLogEvi(iSub, :), 'k-', 'LineWidth', 1); hold on % was 0.05
        p.Color(4) = 0.20;
    end
end

% Y-axis limits:
leeway = 20;
yLim = [floor(min(selLogEvi(:))) - leeway, ceil(max(selLogEvi(:))) + leeway]; % yLim based on individual data points

% Further features:
set(gca, 'xlim', [0 max(xLoc) + 0.5], 'ylim', yLim,...
    'xtick', xLoc, 'xticklabel', xTickLabel,...
    'FontSize', FTS, 'FontName', fontType, 'FontWeight', 'normal', 'LineWidth', 4);

% Labels:
xlabel('Model', 'FontSize', FTS, 'FontName', fontType);
ylabel('log model evidence', 'FontSize', FTS, 'FontName', fontType);
title(sprintf('Log model evidence per model (%s)', cfg.dataType), ...
    'FontSize', FTS, 'FontWeight', 'bold', 'FontName', fontType);

% Name for saving:
figName = sprintf('lme_barplot_%s_mod%s', ...
    cfg.dataType, num2str(modVec, '_%02d'));
if addLines; figName = [figName '_lines']; end
if exist('suffix', 'var'); figName = [figName suffix]; end

% Save:
fprintf('Save figure as %s ...\n', figName);
savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2G.csv'));
csvwrite(fullFileName, selLogEvi);

% ----------------------------------------------------------------------- %
%% Fig. 2H: Learning curves responses ~ req. action x valence, simulated.

cfg.dataType    = 'sham';
cfg.iMod        = 7;

% Load simulated data:
job.iMod        = cfg.iMod; % number of models to fit
job.simType     = 'osap'; % modSim, osap
job.parType     = 'hbi'; % lap, hbi    
job.dataType    = cfg.dataType;
job.nIter       = 100;

% Load simulations:
sim             = mgngtus_cbm_wrapper_sim(job);

% Aggregate data:
aggrData        = mgngtus_aggregate_simulated_data(sim);

% Title and handle for all plots:
cfg.plotTitle   = sprintf('M%02d %s (%s) simulations (%s)', job.iMod, job.simType, job.parType, cfg.dataType);
cfg.plotHandle  = sprintf('%s_%s_nIter%04d_%s_M%02d', job.simType, job.parType, job.nIter, cfg.dataType, job.iMod);

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:cfg.nSub, invalidSubs);
nSubValid       = length(validSubs);

plotCfg         = [];
plotCfg.xLab    = 'Trial';
plotCfg.yLab    = 'p(Go)';
plotCfg.title   = cfg.plotTitle;
plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red

% Plot:
close gcf
custom_lineplot(plotCfg, aggrData.pGoSubCondRep(validSubs, :, :));

% Save:
savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2H_G2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 1, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig2H_G2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 2, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig2H_NG2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 3, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig2H_NG2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 4, :)));

% ----------------------------------------------------------------------- %
%% Fig. 2I: Bar plot p(repeat) ~ last response x last outcome, simulated.

cfg.dataType    = 'sham';
cfg.iMod        = 7;

% Load simulated data:
job.iMod        = cfg.iMod; % number of models to fit
job.simType     = 'osap'; % modSim, osap
job.parType     = 'hbi'; % lap, hbi    
job.dataType    = cfg.dataType;
job.nIter       = 100;

% Load simulations:
sim             = mgngtus_cbm_wrapper_sim(job);

% Aggregate data:
aggrData        = mgngtus_aggregate_simulated_data(sim);

% Title and handle for all plots:
cfg.plotTitle   = sprintf('M%02d %s (%s) simulations (%s)', job.iMod, job.simType, job.parType, cfg.dataType);
cfg.plotHandle  = sprintf('%s_%s_nIter%04d_%s_M%02d', job.simType, job.parType, job.nIter, cfg.dataType, job.iMod);

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:cfg.nSub, invalidSubs);
nSubValid       = length(validSubs);

plotCfg         = [];
plotCfg.xLab    = 'Performed action';
plotCfg.xTick       = [1.5 3.5 5.5 7.5];
plotCfg.xTickLabel  = {'Go', 'NoGo', 'Go', 'NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

outColMat       = [0 113 116; 87 196 173; 240 174 102; 201 61 33] ./ 255; % Var 1: dark green, light green, orange, red
outColMat       = repmat(outColMat, 2, 1); % duplicate;

plotCfg.addPoints  = true;
plotCfg.addLines   = true;

condOrder       = [1 4 5 8];
plotCfg.colMat  = outColMat(condOrder, :); % overwrite colour map

% Plot:
close gcf
custom_barplot(plotCfg, aggrData.pStayRespValOut(validSubs, condOrder));

% Save:
savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_out_valenced_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_out_valenced_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2I.csv'));
csvwrite(fullFileName, squeeze(aggrData.pStayRespValOut(validSubs, condOrder)));

% ----------------------------------------------------------------------- %
%% Fig. 2J: Bar plot p(repeat) ~ cue valence, simulated.

cfg.dataType    = 'sham';
cfg.iMod        = 7;

% Load simulated data:
job.iMod        = cfg.iMod; % number of models to fit
job.simType     = 'osap'; % modSim, osap
job.parType     = 'hbi'; % lap, hbi    
job.dataType    = cfg.dataType;
job.nIter       = 100;

% Load simulations:
sim             = mgngtus_cbm_wrapper_sim(job);

% Aggregate data:
aggrData        = mgngtus_aggregate_simulated_data(sim);

% Title and handle for all plots:
cfg.plotTitle   = sprintf('M%02d %s (%s) simulations (%s)', job.iMod, job.simType, job.parType, cfg.dataType);
cfg.plotHandle  = sprintf('%s_%s_nIter%04d_%s_M%02d', job.simType, job.parType, job.nIter, cfg.dataType, job.iMod);

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:cfg.nSub, invalidSubs);
nSubValid       = length(validSubs);

plotCfg         = [];
plotCfg.xLab    = 'Cue valence';
plotCfg.xTick       = [1 2];
plotCfg.xTickLabel  = {'Win', 'Avoid'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.title   = cfg.plotTitle;
plotCfg.colMat  = [137 177 209; 211 160 132] ./ 255; % blue, red

plotCfg.addPoints  = true;
plotCfg.addLines   = false;

% Plot:
close gcf
custom_barplot(plotCfg, aggrData.pStayVal(validSubs, :));

% Save:
savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_val_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_val_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2J.csv'));
csvwrite(fullFileName, squeeze(aggrData.pStayVal(validSubs, :)));

% ----------------------------------------------------------------------- %
%% Fig. 2K: Bayesian Model Selection.

cfg.dataType = 'sham';

% Final selection:
modVec      = 1:7;

% Create output name:
fname_hbi   = fullfile(dirs.hbi, ...
    sprintf('hbi_%s_mod%s.mat', cfg.dataType, num2str(sort(modVec), '_%02d'))); % all models

% Load BMS results:
f_hbi       = load(fname_hbi);
cbm         = f_hbi.cbm;
cfg.nSub    = size(cbm.output.parameters{1}, 1);

% Select model names and their order:
modNames    = modVec;

% % Select order of models:
modIdx      = 1:nModPlot;

% Downstream settings:
nModPlot    = length(modVec);
modVecSort  = sort(modVec); % identifying correct order of models

% Extract data to plot:
modFreq     = cbm.output.model_frequency(modIdx); % already normalized
PXP         = cbm.output.protected_exceedance_prob(modIdx);

% Plot settings:
LWD         = 4; 
FTS         = 32;
fontType    = 'Arial';
xLoc        = 1:nModPlot;
xTickLabel  = modNames; % only indices
% xTickLabel  = strcat('M', string(modNames)); % starting with M

% Plot:
close gcf
figure('Color', 'white', 'Position', [100 100 800 800]); hold on

% Model frequency:
p           = cell(1, nModPlot*2); % initialize
for iMod = 1:nModPlot % iMod = 2;
    modID   = modVec(iMod); % model ID
    modIdx  = find(modVecSort == modID); % index of this model in data
    p{iMod} = bar(xLoc(iMod) - 0.20, modFreq(modIdx), .30, 'FaceColor', [180 180 180]/255); % model frequency in blue
end

% Protected exceedance probability:
for iMod = 1:nModPlot
    modID   = modVec(iMod); % model ID
    modIdx  = find(modVecSort == modID); % index of this model in data
    p{iMod+nModPlot} = bar(xLoc(iMod) + 0.20, PXP(modIdx), .30, 'FaceColor', [104 104 104]/255); % PXP in red
end

% Add plot features:
set(gca, 'xlim', [0.5 nModPlot + 0.5] , 'ylim', [0 1], ...
    'xtick', xLoc, 'xticklabel', xTickLabel, ...
    'ytick', 0:.2:1, 'FontSize', FTS, 'FontName', fontType, 'LineWidth', LWD);

% Labels:
xlabel('Model', 'FontSize', FTS, 'FontName', fontType);
title(sprintf('Bayesian model selection (%s)', cfg.dataType), ...
    'FontSize', FTS, 'FontWeight', 'bold', 'FontName', fontType);

% Save:
modFile     = sprintf('hbi_%s_mod%s', cfg.dataType, num2str(modVec, '_%02d')); % string of all models, using 2 digits respectively
figName     = sprintf('modFreq_PXP_%s', modFile);
fprintf('Save file as %s ... \n', figName);

savePNG         = true;
saveSVG         = false;
if savePNG; saveas(gcf, fullfile(dirs.final, [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig2K_MF.csv'));
csvwrite(fullFileName, squeeze(modFreq));
fullFileName = fullfile(dirs.source, sprintf('Fig2K_PXP.csv'));
csvwrite(fullFileName, squeeze(PXP));

% END OF FILE.