% mgngtus_figureS4.m
%
% Code to reproduce empirical data figures in Fig. S4A-E in the
% Supplementary Information.
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
%% Fig. S4A: Bar plot p(repeat) ~ last response x last outcome, empirical.

cfg.dataType    = 'sham';

% Load data:
fprintf('*** Load %s data ***\n', cfg.dataType);
inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
fdata           = load(inputFile); % only contains .data
rawData         = fdata.data; % extract .data
nSub            = length(rawData);

% Aggregate data:
aggrData        = mgngtus_aggregate_empirical_data(rawData);

% Title and handle for all plots:
cfg.plotTitle   = sprintf('Empirical data (%s)', cfg.dataType);
cfg.plotHandle  = sprintf('empirical_%s', cfg.dataType);

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:nSub, invalidSubs);
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
plotCfg.addLines   = false;

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
fullFileName = fullfile(dirs.source, sprintf('FigS4A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pStayRespValOut(validSubs, condOrder)));

% ----------------------------------------------------------------------- %
%% Fig. S4B-E: Bar plot p(repeat) ~ last response x last outcome, simulated.

cfg.dataType    = 'sham';
modVec          = [1 3 5 7]; 
panelIdxVec     = {'B', 'C', 'D', 'E'}; % panel index
nMod            = length(modVec);

for iMod = 1:nMod

    cfg.iMod        = modVec(iMod);
    
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
    validSubs       = setdiff(1:nSub, invalidSubs);
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
    plotCfg.addLines   = false;
    
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
    fullFileName = fullfile(dirs.source, sprintf('FigS4%s.csv', panelIdxVec{iMod}));
    csvwrite(fullFileName, squeeze(aggrData.pStayRespValOut(validSubs, condOrder)));

end

% END OF SCRIPT.