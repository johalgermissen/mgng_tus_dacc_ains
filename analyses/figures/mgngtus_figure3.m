% mgngtus_figure3.m
%
% Code to reproduce empirical data figures in Fig. 3A-H in the main
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
%% Fig. 3A: Learning curves responses ~ req. action x valence, dACC, empirical.

cfg.dataType    = 'dACC';

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

% Plot:
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
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('lineplot_pGo_cond_rep_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3A_G2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 1, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3A_G2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 2, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3A_NG2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 3, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3A_NG2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 4, :)));

% ----------------------------------------------------------------------- %
%% Fig. 3B: Learning curves responses ~ req. action x valence, aIns, empirical.

cfg.dataType    = 'aIns';

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
plotCfg.xLab    = 'Trial';
plotCfg.yLab    = 'p(Go)';
plotCfg.title   = cfg.plotTitle;
plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red

% Plot:
close gcf
custom_lineplot(plotCfg, aggrData.pGoSubCondRep(validSubs, :, :));

% Save:
savePNG         = true;
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('lineplot_pGo_cond_rep_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3B_G2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 1, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3B_G2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 2, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3B_NG2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 3, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3B_NG2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 4, :)));

% ----------------------------------------------------------------------- %
%% Fig. 3C: Bar plots p(repeat) ~ prev. outcome x sonication, empirical.

sonVec          = {'sham', 'dACC', 'aIns'};
nSon            = length(sonVec);

% Load empirical data:
rawData         = cell(nSon, 1); % initialize
aggrData        = cell(nSon, 1); % initialize

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
cfg.plotTitle       = sprintf('Empirical data');
cfg.plotHandle      = sprintf('empirical');

% Sort into categories:
pStayRewGoPunNoGoSon    = nan(nSub, 6); % initialize
pStayValenceSon         = nan(nSub, 6); % initialize

% Loop over sonication conditions:
for iSon = 1:nSon

    % Rewarded Go and punished NoGo conditions:
    pStayRewGoPunNoGoSon(:, iSon)           = aggrData{iSon}.pStayRespValOut(:, 1); % GoRew
    pStayRewGoPunNoGoSon(:, iSon + nSon)    = aggrData{iSon}.pStayRespValOut(:, 8); % NoGoPun
    % Cue valence conditions:
    pStayValenceSon(:, iSon)                = aggrData{iSon}.pStayVal(:, 1); % Win
    pStayValenceSon(:, iSon + nSon)         = aggrData{iSon}.pStayVal(:, 2); % Avoid

end

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:nSub, invalidSubs);
nSubValid       = length(validSubs);

sonColMat       = [226 226 226; 138 140 157; 228 213 155] /255; % grey, blue, yellow
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg             = [];
plotCfg.xLab        = '';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'Rew. Go', 'Pun. NoGo'};
plotCfg.yLab        = 'p(Stay)';
plotCfg.yLim        = [0.3 1];
plotCfg.title       = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
plotCfg.colMat  = sonColMat; % overwrite colour map

% Plot:
close gcf
custom_barplot(plotCfg, pStayRewGoPunNoGoSon(validSubs, :));

% Save plot:
savePNG         = true;
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('barplot_pStay_rewgo_punnogo_son_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_rewgo_punnogo_son_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3C.csv'));
csvwrite(fullFileName, squeeze(pStayRewGoPunNoGoSon(validSubs, :)));

% ----------------------------------------------------------------------- %
%% Fig. 3D: Bar plots p(repeat) ~ cue valence x sonication, empirical.

sonVec          = {'sham', 'dACC', 'aIns'};
nSon            = length(sonVec);

% Load empirical data:
rawData         = cell(nSon, 1); % initialize
aggrData        = cell(nSon, 1); % initialize

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
cfg.plotTitle       = sprintf('Empirical data');
cfg.plotHandle      = sprintf('empirical');

% Sort into categories:
pStayRewGoPunNoGoSon    = nan(nSub, 6); % initialize
pStayValenceSon         = nan(nSub, 6); % initialize

% Loop over sonication conditions:
for iSon = 1:nSon

    % Rewarded Go and punished NoGo conditions:
    pStayRewGoPunNoGoSon(:, iSon)           = aggrData{iSon}.pStayRespValOut(:, 1); % GoRew
    pStayRewGoPunNoGoSon(:, iSon + nSon)    = aggrData{iSon}.pStayRespValOut(:, 8); % NoGoPun
    % Cue valence conditions:
    pStayValenceSon(:, iSon)                = aggrData{iSon}.pStayVal(:, 1); % Win
    pStayValenceSon(:, iSon + nSon)         = aggrData{iSon}.pStayVal(:, 2); % Avoid

end

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:nSub, invalidSubs);

sonColMat       = [226 226 226; 138 140 157; 228 213 155] /255; % grey, blue, yellow
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg             = [];
plotCfg.xLab        = 'Cue valence';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'Win', 'Avoid'};
plotCfg.yLab        = 'p(Stay)';
plotCfg.yLim        = [0.5 1];
plotCfg.title       = cfg.plotTitle;

plotCfg.addPoints   = true;
plotCfg.addLines    = false;
plotCfg.colMat      = sonColMat; % overwrite colour map

% Plot:
close gcf
custom_barplot(plotCfg, pStayValenceSon(validSubs, :));

% Save plot:
savePNG         = true;
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('barplot_pStay_rewgo_punnogo_son_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_rewgo_punnogo_son_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3D.csv'));
csvwrite(fullFileName, squeeze(pStayValenceSon(validSubs, :)));

% ----------------------------------------------------------------------- %
%% Fig. 3E: Learning curves responses ~ req. action x valence, dACC, simulated.

cfg.dataType    = 'dACC';
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
validSubs       = setdiff(1:nSub, invalidSubs);
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
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('lineplot_pGo_cond_rep_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3E_G2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 1, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3E_G2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 2, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3E_NG2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 3, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3E_NG2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 4, :)));

% ----------------------------------------------------------------------- %
%% Fig. 3F: Learning curves responses ~ req. action x valence, aIns, simulated.

cfg.dataType    = 'aIns';
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
validSubs       = setdiff(1:nSub, invalidSubs);
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
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('lineplot_pGo_cond_rep_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3F_G2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 1, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3F_G2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 2, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3F_NG2W.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 3, :)));
fullFileName = fullfile(dirs.source, sprintf('Fig3F_NG2A.csv'));
csvwrite(fullFileName, squeeze(aggrData.pGoSubCondRep(validSubs, 4, :)));

% ----------------------------------------------------------------------- %
%% Fig. 3G: Bar plots p(repeat) ~ prev. outcome x sonication, simulated.

sonVec          = {'sham', 'dACC', 'aIns'};
nSon            = length(sonVec);
cfg.iMod        = 7;

% Initialize:
aggrData     = cell(nSon, 1);

% Loop over sonication conditions:
for iSon = 1:nSon

    cfg.dataType    = sonVec{iSon};
    job.dataType    = cfg.dataType;

    % Model from which to load simulations:
    job.iMod        = cfg.iMod; % number of models to fit
    
    job.simType     = 'osap'; % modSim, osap
    job.parType     = 'hbi'; % lap, hbi
        
    job.nIter       = 100;
    
    % Load simulations:
    sim             = mgngtus_cbm_wrapper_sim(job);
    
    % Aggregate data:
    aggrData{iSon}  = mgngtus_aggregate_simulated_data(sim);
    
end

% Title and handle for all plots:
cfg.plotTitle   = sprintf('M%02d %s (%s) simulations', job.iMod, job.simType, job.parType);
cfg.plotHandle  = sprintf('%s_%s_nIter%04d_M%02d', job.simType, job.parType, job.nIter,job.iMod);

% Sort into categories:
pStayRewGoPunNoGoSon    = nan(nSub, 6); % initialize
pStayValenceSon         = nan(nSub, 6); % initialize

% Loop over sonication conditions:
for iSon = 1:nSon

    % Rewarded Go and punished NoGo conditions:
    pStayRewGoPunNoGoSon(:, iSon)           = aggrData{iSon}.pStayRespValOut(:, 1); % GoRew
    pStayRewGoPunNoGoSon(:, iSon + nSon)    = aggrData{iSon}.pStayRespValOut(:, 8); % NoGoPun
    % Cue valence conditions:
    pStayValenceSon(:, iSon)                = aggrData{iSon}.pStayVal(:, 1); % Win
    pStayValenceSon(:, iSon + nSon)         = aggrData{iSon}.pStayVal(:, 2); % Avoid

end

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:nSub, invalidSubs);
nSubValid       = length(validSubs);

sonColMat       = [226 226 226; 138 140 157; 228 213 155] /255; % grey, blue, yellow
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg             = [];
plotCfg.xLab        = '';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'Rew. Go', 'Pun. NoGo'};
plotCfg.yLab        = 'p(Stay)';
plotCfg.yLim        = [0.3 1];
plotCfg.title       = cfg.plotTitle;

plotCfg.addPoints  = true;
plotCfg.addLines   = false;
plotCfg.colMat  = sonColMat; % overwrite colour map

% Plot:
close gcf
custom_barplot(plotCfg, pStayRewGoPunNoGoSon(validSubs, :));

% Save plot:
savePNG         = true;
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('barplot_pStay_rewgo_punnogo_son_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_rewgo_punnogo_son_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3G.csv'));
csvwrite(fullFileName, squeeze(pStayRewGoPunNoGoSon(validSubs, :)));

% ----------------------------------------------------------------------- %
%% Fig. 3H: Bar plots p(repeat) ~ cue valence x sonication, simulated.

sonVec          = {'sham', 'dACC', 'aIns'};
nSon            = length(sonVec);
cfg.iMod        = 7;

% Initialize:
aggrData     = cell(nSon, 1);

% Loop over sonication conditions:
for iSon = 1:nSon

    cfg.dataType    = sonVec{iSon};
    job.dataType    = cfg.dataType;

    % Model from which to load simulations:
    job.iMod        = cfg.iMod; % number of models to fit
    
    job.simType     = 'osap'; % modSim, osap
    job.parType     = 'hbi'; % lap, hbi
        
    job.nIter       = 100;
    
    % Load simulations:
    sim             = mgngtus_cbm_wrapper_sim(job);
    
    % Aggregate data:
    aggrData{iSon}  = mgngtus_aggregate_simulated_data(sim);
    
end

% Title and handle for all plots:
cfg.plotTitle   = sprintf('M%02d %s (%s) simulations', job.iMod, job.simType, job.parType);
cfg.plotHandle  = sprintf('%s_%s_nIter%04d_M%02d', job.simType, job.parType, job.nIter,job.iMod);

% Sort into categories:
pStayRewGoPunNoGoSon    = nan(nSub, 6); % initialize
pStayValenceSon         = nan(nSub, 6); % initialize

% Loop over sonication conditions:
for iSon = 1:nSon

    % Rewarded Go and punished NoGo conditions:
    pStayRewGoPunNoGoSon(:, iSon)           = aggrData{iSon}.pStayRespValOut(:, 1); % GoRew
    pStayRewGoPunNoGoSon(:, iSon + nSon)    = aggrData{iSon}.pStayRespValOut(:, 8); % NoGoPun
    % Cue valence conditions:
    pStayValenceSon(:, iSon)                = aggrData{iSon}.pStayVal(:, 1); % Win
    pStayValenceSon(:, iSon + nSon)         = aggrData{iSon}.pStayVal(:, 2); % Avoid

end

% Select subjects:
invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:nSub, invalidSubs);

sonColMat       = [226 226 226; 138 140 157; 228 213 155] /255; % grey, blue, yellow
sonColMat       = repmat(sonColMat, 2, 1); % duplicate;

plotCfg             = [];
plotCfg.xLab        = 'Cue valence';
plotCfg.xTick       = [2 5];
plotCfg.xTickLabel  = {'Win', 'Avoid'};
plotCfg.yLab        = 'p(Stay)';
plotCfg.yLim        = [0.5 1];
plotCfg.title       = cfg.plotTitle;

plotCfg.addPoints   = true;
plotCfg.addLines    = false;
plotCfg.colMat      = sonColMat; % overwrite colour map

% Plot:
close gcf
custom_barplot(plotCfg, pStayValenceSon(validSubs, :));

% Save plot:
savePNG         = true;
saveSVG         = true;
if savePNG; saveas(gcf, fullfile(dirs.plot, sprintf('barplot_pStay_rewgo_punnogo_son_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_rewgo_punnogo_son_%s.svg', cfg.plotHandle))); end

% Save source data:
fullFileName = fullfile(dirs.source, sprintf('Fig3H.csv'));
csvwrite(fullFileName, squeeze(pStayValenceSon(validSubs, :)));

% END OF FILE.