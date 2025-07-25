% mgngtus_cbm04c_plot_pStay_out_sonication.m

% Plot empirical and simulated data as learning curves and bar plots
% directly comparing sonication conditions.
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

% Fixed settings:
cfg             = mgngtus_cbm_set_config();

sonVec          = {'sham', 'dACC', 'aIns'};
nSon            = length(sonVec);

isSim           = false;
isSim           = true;
cfg.iMod        = 20;
pauseDur        = 0; % in seconds

% isElsa          = false;
isElsa          = true;

% ----------------------------------------------------------------------- %
%% 00c) Load empirical data:

% Initialize:
rawData         = cell(nSon, 1);
aggrData        = cell(nSon, 1);

% Loop over sonication conditions:
for iSon = 1:nSon

    cfg.dataType    = sonVec{iSon};

    inputFile       = fullfile(dirs.input, sprintf('mgngtus_%s.mat', cfg.dataType));    
    fdata           = load(inputFile); % only contains .data
    rawData{iSon}   = fdata.data; % extract .data
    nSub            = length(rawData{iSon});
    
    % Aggregate data:
    aggrData{iSon}  = mgngtus_aggregate_empirical_data(rawData{iSon});
end

% Title and handle for all plots:
cfg.plotTitle   = sprintf('Empirical data');
cfg.plotHandle  = sprintf('empirical');

% ----------------------------------------------------------------------- %
%% 00d) Load simulations:

if isSim

    % Initialize:
    aggrData     = cell(nSon, 1);
    
    % Loop over sonication conditions:
    for iSon = 1:nSon
    
        cfg.dataType    = sonVec{iSon};
        job.dataType    = cfg.dataType;
        % job.dataType    = 'sham';
        % job.dataType    = 'dACC';
        % job.dataType    = 'aIns';
    
        % Model from which to load simulations:
        job.iMod        = cfg.iMod; % number of models to fit
        
        job.simType     = 'osap'; % modSim, osap
        % job.simType     = 'modSim'; % modSim, osap
        
        % job.parType     = 'lap'; % lap, hbi
        job.parType     = 'hbi'; % lap, hbi
            
        job.nIter       = 100;
        
        % Load simulations:
        sim                 = mgngtus_cbm_wrapper_sim(job);
        
        % Aggregate data:
        aggrData{iSon}   = mgngtus_aggregate_simulated_data(sim);
        
    end
    
    % Title and handle for all plots:
    cfg.plotTitle   = sprintf('M%02d %s (%s) simulations', job.iMod, job.simType, job.parType);
    cfg.plotHandle  = sprintf('%s_%s_nIter%04d_M%02d', job.simType, job.parType, job.nIter,job.iMod);

end

% ----------------------------------------------------------------------- %
%% 00e) Sort correct categories:

fprintf('*** Sort categories into new matrices ...***\n');

% Initialize:
pStayValencedSon        = nan(nSub, 6);
pStayRewGoPunNoGoSon    = nan(nSub, 6);
pStayNeutralSon         = nan(nSub, 6);
pStayValencedRespSon    = nan(nSub, 12);
pStayNeutralRespSon     = nan(nSub, 12);
pStayValenceSon         = nan(nSub, 6);

% Original order: GoRew NoRew NoPun Pun
% Original order: GoRew GoNoRew GoNoPun GoPun NoGoRew NoGoNoRew NoGoNoPun NoGoPun 

% Loop over sonication conditions:
for iSon = 1:nSon

    % Valenced conditions:
    pStayValencedSon(:, iSon)               = aggrData{iSon}.pStayValOut(:, 1); % Rew
    pStayValencedSon(:, iSon + nSon)        = aggrData{iSon}.pStayValOut(:, 4); % Pun
    % Valenced conditions x response:
    pStayValencedRespSon(:, iSon)           = aggrData{iSon}.pStayRespValOut(:, 1); % GoRew
    pStayValencedRespSon(:, iSon + 1 * nSon)= aggrData{iSon}.pStayRespValOut(:, 4); % GoPun
    pStayValencedRespSon(:, iSon + 2 * nSon)= aggrData{iSon}.pStayRespValOut(:, 5); % NoGoRew
    pStayValencedRespSon(:, iSon + 3 * nSon)= aggrData{iSon}.pStayRespValOut(:, 8); % NoGoPun
    % Rewarded Go and punished NoGo conditions:
    pStayRewGoPunNoGoSon(:, iSon)           = aggrData{iSon}.pStayRespValOut(:, 1); % GoRew
    pStayRewGoPunNoGoSon(:, iSon + nSon)    = aggrData{iSon}.pStayRespValOut(:, 8); % NoGoPun
    % Neutral conditions:
    pStayNeutralSon(:, iSon)                = aggrData{iSon}.pStayValOut(:, 2); % NoRew
    pStayNeutralSon(:, iSon + nSon)         = aggrData{iSon}.pStayValOut(:, 3); % NoPun
    % Neutral conditions x response:
    pStayNeutralRespSon(:, iSon)            = aggrData{iSon}.pStayRespValOut(:, 2); % GoNoRew
    pStayNeutralRespSon(:, iSon + 1 * nSon) = aggrData{iSon}.pStayRespValOut(:, 3); % GoNoPun
    pStayNeutralRespSon(:, iSon + 2 * nSon) = aggrData{iSon}.pStayRespValOut(:, 6); % NoGoNoRew
    pStayNeutralRespSon(:, iSon + 3 * nSon) = aggrData{iSon}.pStayRespValOut(:, 7); % NoGoNoPun
    % Cue valence conditions:
    pStayValenceSon(:, iSon)                = aggrData{iSon}.pStayVal(:, 1); % Win
    pStayValenceSon(:, iSon + nSon)         = aggrData{iSon}.pStayVal(:, 2); % Avoid

end

% ----------------------------------------------------------------------- %
%% 00f) Select subjects:

% Run this section to generate 'validSubs' to be used in following sections

fprintf('*** Select subjects ... ***\n');

invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:nSub, invalidSubs);
nSubValid       = length(validSubs);

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 01) Plot p(Stay) ~ valenced outcomes:

sonColMat       = [229 229 229; 211 67 110; 254 186 128] /255; % grey, red, orange
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg         = [];
plotCfg.xLab    = 'Previous outcome';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'Rew', 'Pun'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
% plotCfg.addLines   = true;

plotCfg.colMat  = sonColMat; % overwrite colour map
custom_barplot(plotCfg, pStayValencedSon(validSubs, :));
saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_valenced_son_%s.png', cfg.plotHandle)));
if isElsa; saveas(gcf, fullfile(dirs.elsa, sprintf('barplot_pStay_valenced_son_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 02) Plot p(Stay) ~ valenced outcomes x response:

sonColMat       = [229 229 229; 211 67 110; 254 186 128] /255; % grey, red, orange
sonColMat       = repmat(sonColMat, 4, 1); % duplicate;

plotCfg         = [];
plotCfg.xLab    = 'Previous outcome x previous response';
plotCfg.xTick       = [2 5 8 11];
plotCfg.xTickLabel  = {'rew. Go',  'pun. Go', 'rew. NoGo', 'pun. NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
% plotCfg.addLines   = true;

plotCfg.colMat  = sonColMat; % overwrite colour map
custom_barplot(plotCfg, pStayValencedRespSon(validSubs, :));
saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_valenced_resp_son_%s.png', cfg.plotHandle)));
if isElsa; saveas(gcf, fullfile(dirs.elsa, sprintf('barplot_pStay_valenced_resp_son_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 03) p(Stay) ~ rewarded Go vs. punished NoGo:

sonColMat       = [229 229 229; 211 67 110; 254 186 128] /255; % grey, red, orange
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg         = [];
plotCfg.xLab    = '';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'Rew. Go', 'Pun. NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
% plotCfg.addLines   = true;

plotCfg.colMat  = sonColMat; % overwrite colour map
custom_barplot(plotCfg, pStayRewGoPunNoGoSon(validSubs, :));
saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_rewgo_punnogo_son_%s.png', cfg.plotHandle)));
if isElsa; saveas(gcf, fullfile(dirs.elsa, sprintf('barplot_pStay_rewgo_punnogo_son_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 04) p(Stay) ~ outcome for only neutral outcomes:

sonColMat       = [229 229 229; 211 67 110; 254 186 128] /255; % grey, red, orange
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg         = [];
plotCfg.xLab    = 'Previous outcome';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'¬Rew', '¬Pun'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
% plotCfg.addLines   = true;

plotCfg.colMat  = sonColMat; % overwrite colour map
custom_barplot(plotCfg, pStayNeutralSon(validSubs, :));
saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_neutral_son_%s.png', cfg.plotHandle)));
if isElsa; saveas(gcf, fullfile(dirs.elsa, sprintf('barplot_pStay_neutral_son_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 05) Plot p(Stay) ~ neutral outcomes x response:

sonColMat       = [229 229 229; 211 67 110; 254 186 128] /255; % grey, red, orange
sonColMat       = repmat(sonColMat, 4, 1); % duplicate;

plotCfg         = [];
plotCfg.xLab    = 'Previous outcome x previous response';
plotCfg.xTick       = [2 5 8 11];
plotCfg.xTickLabel  = {'¬rew. Go',  '¬pun. Go', '¬rew. NoGo', '¬pun. NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
% plotCfg.addLines   = true;

plotCfg.colMat  = sonColMat; % overwrite colour map
custom_barplot(plotCfg, pStayNeutralRespSon(validSubs, :));
saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_neutral_resp_son_%s.png', cfg.plotHandle)));
if isElsa; saveas(gcf, fullfile(dirs.elsa, sprintf('barplot_pStay_neutral_resp_son_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 06) Plot p(Stay) ~ cue valence:

sonColMat       = [229 229 229; 211 67 110; 254 186 128] /255; % grey, red, orange
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg         = [];
plotCfg.xLab    = 'Cue valence';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'Win', 'Avoid'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
% plotCfg.addLines   = true;

plotCfg.colMat  = sonColMat; % overwrite colour map
custom_barplot(plotCfg, pStayValenceSon(validSubs, :));
saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_valence_son_%s.png', cfg.plotHandle)));
if isElsa; saveas(gcf, fullfile(dirs.elsa, sprintf('barplot_pStay_valence_son_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% END OF FILE.