% mgngtus_cbm04b_plot_behaviour.m

% Plot empirical and simulated data as learning curves and bar plots.
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

% we are here:
% cd C:/Users/johan/OneDrive/Documents/AACollaborations/MGNGUltrasoundNomiki/analyses/cbm

clear all; close all; clc

% ----------------------------------------------------------------------- %
%% 00a) Initialize directories:

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));

dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% 00b) Set configuration parameters:

cfg             = mgngtus_cbm_set_config();

% ----------------------------------------------------------------------- %
%% 00c) Settings:

% -------------------------- %
% I) Sonication condition to plot:

cfg.dataType    = 'sham';
% cfg.dataType    = 'dACC';
% cfg.dataType    = 'aIns';

% -------------------------- %
% II) Simulation settings:

% isSim           = false;
isSim           = true;
cfg.iMod        = 19;

% -------------------------- %
% III) Plotting settings:

pauseDur        = 0; % in seconds

% savePNG         = false;
savePNG         = true;

% saveSVG         = false;
saveSVG         = true;

% ----------------------------------------------------------------------- %
% 00d) Option A: Load and extract empirical data:

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

% ----------------------------------------------------------------------- %
% 00e) Option B: Load simulated data:

% isSim = true;
% isSim = false;

if isSim

    % Model from which to load simulations:
    job.iMod        = cfg.iMod; % number of models to fit
    
    job.simType     = 'osap'; % modSim, osap
    % job.simType     = 'modSim'; % modSim, osap
    
    % job.parType     = 'lap'; % lap, hbi
    job.parType     = 'hbi'; % lap, hbi
    
    job.dataType    = cfg.dataType;
    % job.dataType    = 'sham';
    % job.dataType    = 'dACC';
    % job.dataType    = 'aIns';
    
    job.nIter       = 100;
    
    % Load simulations:
    sim             = mgngtus_cbm_wrapper_sim(job);
    
    % Aggregate data:
    aggrData        = mgngtus_aggregate_simulated_data(sim);
    
    % Title and handle for all plots:
    % job.iMod = 3;
    cfg.plotTitle   = sprintf('M%02d %s (%s) simulations (%s)', job.iMod, job.simType, job.parType, cfg.dataType);
    cfg.plotHandle  = sprintf('%s_%s_nIter%04d_%s_M%02d', job.simType, job.parType, job.nIter, cfg.dataType, job.iMod);

end

% ----------------------------------------------------------------------- %
% 00f) Select subjects:

% Run this section to generate 'validSubs' to be used in following sections

fprintf('*** Select subjects ... ***\n');

invalidSubs     = []; % keep all subjects
if ~isempty(invalidSubs); fprintf('Exclude subjects %s\n', num2str(invalidSubs)); end
validSubs       = setdiff(1:nSub, invalidSubs);
nSubValid       = length(validSubs);

% validSubs       = 7; % outliers for dACC and aIns

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 01a) Plot learning curves: (pGo)

plotCfg         = [];
plotCfg.xLab    = 'Trial';
plotCfg.yLab    = 'p(Go)';
plotCfg.title   = cfg.plotTitle;
plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red

custom_lineplot(plotCfg, aggrData.pGoSubCondRep(validSubs, :, :));

% Save:
if savePNG; saveas(gcf, fullfile(dirs.plot, 'lineplot_pGo', sprintf('lineplot_pGo_cond_rep_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pGo_cond_rep_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
% 01b) Plot learning curves: Accuracy

% plotCfg         = [];
% plotCfg.xLab    = 'Trial';
% plotCfg.yLab    = 'p(Correct)';
% plotCfg.title   = cfg.plotTitle;
% plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red
% 
% custom_lineplot(plotCfg, aggrData.pCorrectSubCondRep(validSubs, :, :));
% 
% % Save:
% if savePNG; saveas(gcf, fullfile(dirs.plot, 'lineplot_pCorrect', sprintf('lineplot_pCorrect_cond_rep_%s.png', cfg.plotHandle))); end
% if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('lineplot_pCorrect_cond_rep_%s.png', cfg.plotHandle))); end
% 
% % Close:
% pause(pauseDur);
% close gcf

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% 02a) Plot bar plots: p(Go)

% plotCfg         = [];
% plotCfg.xLab    = 'Condition';
% % plotCf.xTick        = 1:4;
% % plotCfg.xTickLabel  = {'G2W', 'G2A', 'NG2W', 'NG2A'};
% plotCfg.xTick       = [1.5 3.5];
% plotCfg.xTickLabel  = {'Go', 'NoGo'};
% plotCfg.yLab    = 'p(Go)';
% plotCfg.yLim    = [0 1];
% plotCfg.title   = cfg.plotTitle;
% plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red
% 
% plotCfg.addPoints  = true;
% plotCfg.addLines   = false;
% 
% custom_barplot(plotCfg, aggrData.pGoSubCond(validSubs, :));
% 
% % Save:
% if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pGo', sprintf('barplot_pGo_cond_%s.png', cfg.plotHandle))); end
% if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pGo_cond_%s.svg', cfg.plotHandle))); end

% Close:
% pause(pauseDur);
% close gcf

% ----------------------------------------------------------------------- %
% 02b) Plot bar plots: p(Correct)

% plotCfg         = [];
% plotCfg.xLab    = 'Condition';
% % plotCf.xTick        = 1:4;
% % plotCfg.xTickLabel  = {'G2W', 'G2A', 'NG2W', 'NG2A'};
% plotCfg.xTick       = [1.5 3.5];
% plotCfg.xTickLabel  = {'Go', 'NoGo'};
% plotCfg.yLab    = 'p(Correct)';
% plotCfg.yLim    = [0 1];
% plotCfg.title   = cfg.plotTitle;
% plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red
% 
% plotCfg.addPoints  = true;
% plotCfg.addLines   = false;
% 
% custom_barplot(plotCfg, aggrData.pCorrectSubCond(validSubs, :));
% 
% % Save:
% if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pCorrect', sprintf('barplot_pCorrect_cond_%s.png', cfg.plotHandle))); end
% if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pCorrect_cond_%s.svg', cfg.plotHandle))); end
% 
% % Close:
% pause(pauseDur);
% close gcf

% ----------------------------------------------------------------------- %
%% 02c) Plot bar plots: p(Stay) ~ response x valence x outcome:

outColMat       = [0 113 116; 87 196 173; 240 174 102; 201 61 33] ./ 255; % Var 1: dark green, light green, orange, red
outColMat       = repmat(outColMat, 2, 1); % duplicate;

plotCfg         = [];
plotCfg.xLab    = 'Performed action';
plotCfg.xTick       = [1.5 3.5 5.5 7.5];
plotCfg.xTickLabel  = {'Go', 'NoGo', 'Go', 'NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

% Reorder conditions:
% Original order: GoRew GoNoRew GoNoPun GoPun NoGoRew NoGoNoRew NoGoNoPun NoGoPun 
% Desired  order: GoRew GoPun NoGoRew NoGoPun GoNoPun GoNoRew NoGoNoPun NoGoNoRew
condOrder       = [1 4 5 8 3 2 7 6]; % GoRew GoPun NoGoRew NoGoPun GoNoPun GoNoRew NoGoNoPun NoGoNoRew
plotCfg.colMat  = outColMat(condOrder, :); % overwrite colour map

plotCfg.addPoints  = true;
plotCfg.addLines   = false;

custom_barplot(plotCfg, aggrData.pStayRespValOut(validSubs, condOrder));

% Save:
if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_resp_out_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_out_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------- %
%% Only valenced outcomes:

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

condOrder       = [1 4 5 8]; % GoRew GoPun NoGoRew NoGoPun GoNoPun GoNoRew NoGoNoPun NoGoNoRew
plotCfg.colMat  = outColMat(condOrder, :); % overwrite colour map
custom_barplot(plotCfg, aggrData.pStayRespValOut(validSubs, condOrder));
if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_resp_out_valenced_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_out_valenced_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------- %
%% Only neutral outcomes:

plotCfg         = [];
plotCfg.xLab    = 'Performed action';
plotCfg.xTick       = [1.5 3.5 5.5 7.5];
plotCfg.xTickLabel  = {'Go', 'NoGo', 'Go', 'NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

condOrder       = [3 2 7 6]; % GoRew GoPun NoGoRew NoGoPun GoNoPun GoNoRew NoGoNoPun NoGoNoRew
plotCfg.colMat  = outColMat(condOrder, :); % overwrite colour map

plotCfg.addPoints  = true;
plotCfg.addLines   = false;

custom_barplot(plotCfg, aggrData.pStayRespValOut(validSubs, condOrder));
if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_resp_out_neutral_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_out_neutral_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 02d) Plot bar plots: p(Stay) ~ outcome:

outColMat       = [0 113 116; 87 196 173; 240 174 102; 201 61 33] ./ 255; % Var 1: dark green, light green, orange, red

plotCfg         = [];
plotCfg.xLab    = 'Performed action';
plotCfg.xTick       = [1.5 3.5 5.5 7.5];
plotCfg.xTickLabel  = {'Go', 'NoGo', 'Go', 'NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;

% Reorder conditions:
% Original order: Rew NoRew NoPun Pun
condOrder       = 1:4;
plotCfg.colMat  = outColMat(condOrder, :); % overwrite colour map

plotCfg.addPoints  = true;
plotCfg.addLines   = false;

custom_barplot(plotCfg, aggrData.pStayValOut(validSubs, condOrder));

% Save:
if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_out_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_out_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 02e) Plot bar plots: p(Stay) ~ cue valence:

plotCfg         = [];
plotCfg.xLab    = 'Cue valence';
plotCfg.xTick       = [1 2];
plotCfg.xTickLabel  = {'Win', 'Avoid'};
plotCfg.yLab    = 'p(Stay)';
% plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;
% plotCfg.colMat  = [0 113 116; 201 61 33] ./ 255; % dark green, red

plotCfg.addPoints  = true;
plotCfg.addLines   = false;

custom_barplot(plotCfg, aggrData.pStayVal(validSubs, :));

% Save:
if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_val_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_val_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 02f) Plot bar plots: p(Stay) ~ response x cue valence:

plotCfg         = [];
plotCfg.xLab    = 'Performed action';
plotCfg.xTick       = [1.5 3.5];
plotCfg.xTickLabel  = {'Go', 'NoGo'};
plotCfg.yLab    = 'p(Stay)';
plotCfg.yLim    = [0 1];
plotCfg.title   = cfg.plotTitle;
plotCfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, red, dark green, red

plotCfg.addPoints  = true;
plotCfg.addLines   = false;

custom_barplot(plotCfg, aggrData.pStayRespVal(validSubs, :));

% Save:
if savePNG; saveas(gcf, fullfile(dirs.plot, 'barplot_pStay', sprintf('barplot_pStay_resp_val_%s.png', cfg.plotHandle))); end
if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_pStay_resp_val_%s.svg', cfg.plotHandle))); end

% Close:
pause(pauseDur);
close gcf

% ----------------------------------------------------------------------- %
%% 03) Plot bar plots: RTs

if ~isSim % no RTs available from simulations

    plotCfg         = [];
    plotCfg.xLab    = 'Condition';
    plotCfg.xTickLabel  = {'G2W', 'G2A', 'NG2W', 'NG2A'};
    plotCfg.yLab    = 'RT (in sec.)';
    plotCfg.yLim    = [0.4 1];
    plotCfg.title   = cfg.plotTitle;
    cfg.colMat      = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % dark green, light green, orange, red
    
    custom_barplot(plotCfg, aggrData.RTSubCond(validSubs, :));
    
    % Save:
    saveas(gcf, fullfile(dirs.plot, 'barplot_RT', sprintf('barplot_RT_cond_%s.png', cfg.plotHandle)));
    if saveSVG; saveas(gcf, fullfile(dirs.final, sprintf('barplot_RT_cond_%s.svg', cfg.plotHandle))); end
    
    % Close:
    pause(pauseDur);
    close gcf

end

fprintf('*** Finished all plots! :-) ***\n');

% END OF FILE.