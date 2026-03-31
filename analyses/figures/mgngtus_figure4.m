% mgngtus_figure4.m
%
% Code to reproduce empirical data figures in Fig. 4B, C, E, F in the main
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
%% Load all parameter values for selected model:

% Select model to plot:
cfg.modID       = 7;

% Fitting method:
cfg.parType     = 'hbi';

% Number subjects:
nSub            = 29;

% Number parameters:
output          = format_paramNames(cfg.modID);
paramNames      = output.paramNames;
paramNamesLaTeX = output.paramNamesLaTeX;
nParam          = length(output.paramNames);

% Initialise sonication conditions:
sonVec          = {'sham', 'dACC', 'aIns'};
nSon            = length(sonVec);

% Load parameters for all sonication sessions:
sonParamMat = nan(nSub, nParam, nSon);
for iSon = 1:nSon % iSon = 1;
    fprintf('*** ------------------------------------------------- ***\n');
    fprintf('***Load parameters for model M%02d, %s condition ...***\n', ...
        cfg.modID, sonVec{iSon});
    cfg.dataType            = sonVec{iSon};
    cbm                     = mgngtus_cbm_load_model(cfg);
    subParamMat             = cbm.subParamMat;
    subParamMatRaw          = subParamMat; % backup
    subParamMat             = transform_parameters(subParamMat, cfg.modID); % transform
    sonParamMat(:, :, iSon) = subParamMat;

end
fprintf('***... finished loading all parameters of all conditions of model M%02d! :-) ***\n', cfg.modID);

% ----------------------------------------------------------------------- %
%% Loop over selected parameters, plot:

paramIdxVec         = [5 3 6 7]; % selected parameters
panelIdxVec         = {'B', 'C', 'E', 'F'}; % panel index
nParamSel           = length(paramIdxVec);

plotCfg             = [];

% Select conditions:
plotCfg.xVec        = 1:nSon;

% Select subjects:
plotCfg.zVec        = 1:nSub;

plotCfg.xLabel      = 'Sonication condition';
plotCfg.xTick       = sonVec;
plotCfg.zLabel      = 'Subject';
plotCfg.zTick       = 1:nSub;
plotCfg.fitName     = cfg.parType;
plotCfg.colMat      = [226 226 226; 138 140 157; 228 213 155] /255; % grey, dark blue, yellow
plotCfg.modID       = cfg.modID;

plotCfg.addPoints   = true;
plotCfg.addLines    = true;

% Saving settings:
pauseDur            = 3;
savePNG             = true;
saveSVG             = false;

% Loop over parameters:
for iParam = 1:nParamSel % iParam = 1;

    paramIdx    = paramIdxVec(iParam);

    plotCfg.yLabel      = paramNamesLaTeX{paramIdx};
    fprintf('Model M%02d: Plot parameter #%d (%s) ...***\n', ...
        cfg.modID, paramIdx, paramNames{paramIdx});

    % Extract values for this parameter:
    plotMat             = squeeze(sonParamMat(:, paramIdx, :));
    
    mgngtus_plot_param(plotCfg, plotMat);
    
    % Save:
    figName     = sprintf('param_per_son_%s_mod%02d_%d_%s', ...
        cfg.parType, cfg.modID, paramIdx, paramNames{paramIdx});
    if plotCfg.addLines; figName = [figName '_lines']; end
    if savePNG; saveas(gcf, fullfile(dirs.final, [figName '.png'])); end
    if saveSVG; saveas(gcf, fullfile(dirs.final, [figName '.svg'])); end
    pause(pauseDur); close gcf
    
    % Save source data:
    fullFileName = fullfile(dirs.source, sprintf('Fig4%s.csv', panelIdxVec{iParam}));
    csvwrite(fullFileName, plotMat);

end

% END OF FILE.