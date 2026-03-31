% mgngtus_cbm03a_eval_fit.m

% Plot fitting parameters (log model evidence, model frequency, protected exceedance probability).
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

clear all; close all; clc

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));

dirs            = mgngtus_cbm_set_dirs();

% Add new directories for LME and BMS:
dirs.LME        = fullfile(dirs.plot, 'LME');
if ~exist(dirs.LME, 'dir'); mkdir(dirs.LME); end
dirs.BMS        = fullfile(dirs.plot, 'BMS');
% if ~exist(dirs.BMS, 'dir'); mkdir(dirs.BMS); end

% ----------------------------------------------------------------------- %
%% 00b) Set configuration parameters:

cfg             = mgngtus_cbm_set_config();

pauseDur        = 1; % in seconds

% savePNG         = 0;
savePNG         = 1;

% saveSVG         = 0;
saveSVG         = 1;

% General plotting settings:
MKS             = 10;
FTS             = 20;
LWD             = 3;

% ----------------------------------------------------------------------- %
%% 00c) Settings:

% Sonication condition to plot:
cfg.dataType    = 'sham';
% cfg.dataType    = 'dACC';
% cfg.dataType    = 'aIns';

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 01a) Load LAP fit (log-likelihoods):

% Specify number of models to load:

modRange   = 1:7; % 7 main models
% modRange   = 7:9; % winning model against two control models

nMod        = max(modRange); % must be maximum model ID

cfg.nSub     = 29; % just for initializing

% Output names:
fprintf('Initialize output file names\n')
fname_mod = struct([]);
for iMod = 1:nMod
    fname_mod{iMod} = fullfile(dirs.lap, sprintf('lap_%s_mod%02d.mat', cfg.dataType, iMod));
end

% ----------------------------------------------------------------------- %
% Load log-model evidence per model per subject:

logEvi = nan(cfg.nSub, nMod);
for iMod = modRange % nMod = 5;
    fprintf('Load log-model evidence for model %02d\n', iMod);
    fname = load(fname_mod{iMod});
    cbm   = fname.cbm;
    logEvi(:, iMod) = cbm.output.log_evidence;
end
fprintf('Finished! :-)\n');

% ----------------------------------------------------------------------- %
%% 01b) Plot log model evidence with bar plots:

addLines    = false; % connect individual data points from same subject or not
addLines    = true; % connect individual data points from same subject or not

clear suffix

% Select models in correct order (name can differ from model IDs):
modVec      = modRange;

% Select subjects:
validSubs   = 1:cfg.nSub;
cfg.nSubValid   = length(validSubs);

% ----------------------------------------------------------------------- %
% Downstream settings:

% Select subjects and models to plot:
selLogEvi   = logEvi(validSubs, modVec);

% Create model names for x-axis:
nModPlot    = length(modVec);
% modNames = modVec; % original models
modNames    = 1:nModPlot; fprintf('Rename model names to 1-n\n'); % just 1-nMod

assert(length(modVec) == length(modNames));
modLabels   = strcat('M', string(modNames)); % true labels according to names given modNames
modFile     = strcat('M', string(modVec));

% ----------------------------------------------------------------------- %
% Aggregate & correct SEs for between-subjects variability:

subMean    = mean(selLogEvi, 2); % average across models
grandMean  = mean(subMean); % average across subjects
condMean   = mean(selLogEvi, 1); % average across subjects
condSE     = withinSE(selLogEvi); % compute SE per model

% ----------------------------------------------------------------------- %
% General plot settings:

% X-axis:
xLoc        = 1:nModPlot;
xTickLabel  = modLabels;

% Colour map:
colMat     = repmat([87 196 173] ./ 255, nModPlot, 1); % light green

% Highlight best fitting model:
[~, bestIdx]        = max(condMean);
colMat(bestIdx, :)  = [153 112 171] ./ 255; % purple

% Overwrite plotting settings:
CPS         = 12; 
FTS         = 28; % 36
LWD         = 4; 
fontType    = 'Arial';

% ----------------------------------------------------------------------- %
% Start plot:

figure('Color', 'white', 'Position', [0 0 800 800]); hold on % for PuG

% ----------------------------------------------------------------------- %
% a) Plot bars with errorbars:

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

% ----------------------------------------------------------------------- %
% Name for saving:
% figName = sprintf('logmodelevidence/logmodevidence_barplot_models_%s', ...
figName = sprintf('lme_barplot_%s_mod%s', ...
    cfg.dataType, num2str(modVec, '_%02d'));
if addLines; figName = [figName '_lines']; end
if exist('suffix', 'var'); figName = [figName suffix]; end

% Save:
fprintf('Save figure as %s ...\n', figName);
if savePNG; saveas(gcf, fullfile(dirs.LME, [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end
fprintf('... finished! :-)\n');
pause(pauseDur)
close gcf

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 02a) Load HBI, print evaluation matrix to console:

cfg.dataType = 'sham';
% cfg.dataType = 'dACC';
% cfg.dataType = 'aIns';

modVec          = 1:7;
% modVec          = 1:nMod;
% modVec          = 7:9;

% Create output name:
fname_hbi   = fullfile(dirs.hbi, ...
    sprintf('hbi_%s_mod%s.mat', cfg.dataType, num2str(sort(modVec), '_%02d'))); % all models

% ----------------------------------------------------------------------- %
% Load complete HBI object including selected models:

f_hbi       = load(fname_hbi);
cbm         = f_hbi.cbm;
cfg.nSub        = size(cbm.output.parameters{1}, 1);

% ----------------------------------------------------------------------- %
% Model IDs:
fprintf('Models IDs are                  :   %s\n', ...
    num2str(sort(modVec), '   %02d'));

% ----------------------------------------------------------------------- %
% Model frequency:

fprintf('Model frequency                 : %s\n', ...
    num2str(cbm.output.model_frequency, '%.02f '));
% cbm.output.model_frequency

% ----------------------------------------------------------------------- %
% Exceedance probability:

fprintf('Exceedance probability          : %s\n', ...
    num2str(cbm.output.exceedance_prob, '%.02f '));
% cbm.output.exceedance_prob

% ----------------------------------------------------------------------- %
% Protected exceedance probability:

fprintf('Protected exceedance probability: %s\n', ...
    num2str(cbm.output.protected_exceedance_prob, '%.02f '));
% cbm.output.protected_exceedance_prob

% ----------------------------------------------------------------------- %
%% 02b) Plot model frequency and exceedance probability:

% Select model names and their order:
nModPlot    = length(modVec);
modNames    = 1:nModPlot; fprintf('Rename model names to 1-n\n'); % just 1-nMod

% Select order of models:
modIdx      = 1:nModPlot;

% Downstream settings:
nModPlot    = length(modVec);
modVecSort  = sort(modVec); % identifying correct order of models

% ----------------------------------------------------------------------- %
% Extract data to plot:
modFreq     = cbm.output.model_frequency(modIdx); % already normalized
PXP         = cbm.output.protected_exceedance_prob(modIdx);

% Relative model frequency (normalized, divided by N) in red (blue),
% Protected exceedance probability in red (right)
% Small gap between
% No SEs

% ----------------------------------------------------------------------- %
% Plot settings:

LWD         = 4; 
FTS         = 32; % 25
% CPS         = 12; 
fontType    = 'Arial';
xLoc        = 1:nModPlot;
xTickLabel  = strcat('M', string(modNames)); % actual names in given order
% xTickLabel  = strcat('M', string(1:nMod)); % consecutive

% ----------------------------------------------------------------------- %
% Plot:
close all
p           = [];
figure('Color', 'white', 'Position', [100 100 800 800]); hold on

% Model frequency:
p           = cell(1, nModPlot*2); % initialize
for iMod = 1:nModPlot % iMod = 2;
    modID   = modVec(iMod); % model ID
    modIdx  = find(modVecSort == modID); % index of this model in data
    p{iMod} = bar(xLoc(iMod) - 0.20, modFreq(modIdx), .30, 'FaceColor', [0.1294 0.4000 0.6745]); % model frequency in blue
end

% Protected exceedance probability:
for iMod = 1:nModPlot
    modID   = modVec(iMod); % model ID
    modIdx  = find(modVecSort == modID); % index of this model in data
    p{iMod+nModPlot} = bar(xLoc(iMod) + 0.20, PXP(modIdx), .30, 'FaceColor', [0.6980 0.0941 0.1686]); % PXP in red
end

% Add plot features:
set(gca, 'xlim', [0.5 nModPlot + 0.5] , 'ylim', [0 1], ...
    'xtick', xLoc, 'xticklabel', xTickLabel, ...
    'ytick', 0:.2:1, 'FontSize', FTS, 'FontName', fontType, 'LineWidth', LWD);

% Labels:
xlabel('Model', 'FontSize', FTS, 'FontName', fontType);
% ylabel('Model frequency', 'FontSize', FTS, 'FontName', fontType);
% box off
title(sprintf('Bayesian model selection (%s)', cfg.dataType), ...
    'FontSize', FTS, 'FontWeight', 'bold', 'FontName', fontType);

% ----------------------------------------------------------------------- %
% Save:

modFile     = sprintf('hbi_%s_mod%s', cfg.dataType, num2str(modVec, '_%02d')); % string of all models, using 2 digits respectively
figName     = sprintf('modFreq_PXP_%s', modFile);
fprintf('Save file as %s ... \n', figName);
if savePNG; saveas(gcf, fullfile(dirs.BMS, [figName '.png'])); end
if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end

% Close:
pause(2)
close gcf

% END OF FILE.