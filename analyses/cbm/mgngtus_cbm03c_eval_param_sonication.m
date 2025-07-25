% mgngtus_cbm03b_eval_param_sonication.m
%
% Load model output, extract parameters, transform as necessary, 
% plot given parameter from given model across sonication conditions,
% t-test, RM-ANOVA.
% 
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% 00a) Initialize directories:

% clear all; close all; clc

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));

dirs            = mgngtus_cbm_set_dirs();
dirs.param      = fullfile(dirs.plot, 'parameters');
if ~exist(dirs.param, 'dir'); mkdir(dirs.param); end

% ----------------------------------------------------------------------- %
%% 00b) Set configuration parameters:

cfg             = mgngtus_cbm_set_config();

% ----------------------------------------------------------------------- %
%% 00c) Settings:

% Select model to plot:
cfg.modID       = 7; % Phi Int and Dif

% Fitting method:
% cfg.parType     = 'lap'; % use only for LAP
cfg.parType     = 'hbi'; % use only for hbi

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
% fname_mod       = cell(1, 1);

pauseDur        = 1;

% ----------------------------------------------------------------------- %
%% 01) Load parameters from all sonication conditions:

% Load parameters fit with LAP from all sonication sessions:
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
%% 02) Loop over parameters, plot:

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
% plotCfg.colMat      = [255 0 0; 65 105 255; 190 190 190] /255; % red, blue, grey
plotCfg.colMat      = [229 229 229; 211 67 110; 254 186 128] /255; % grey, red, orange
plotCfg.modID       = cfg.modID;

plotCfg.addPoints   = true;

plotCfg.addLines    = false;
% plotCfg.addLines    = true;

% Loop over parameters:
for iParam = 1:nParam % iParam = 1;

    plotCfg.yLabel      = paramNamesLaTeX{iParam};
    fprintf('Model M%02d: Plot parameter #%d (%s) ...***\n', ...
        cfg.modID, iParam, paramNames{iParam});

    % Extract values for this parameter:
    plotMat             = squeeze(sonParamMat(:, iParam, :));
    
    mgngtus_plot_param(plotCfg, plotMat);
    
    % % Save:
    figName     = sprintf('param_per_son_%s_mod%02d_%d_%s', ...
        cfg.parType, cfg.modID, iParam, paramNames{iParam});
    % Save:
    if plotCfg.addLines; figName = [figName '_lines']; end
    saveas(gcf, fullfile(dirs.param, [figName '.png']));
    saveas(gcf, fullfile(dirs.elsa, [figName '.svg']));
    pause(pauseDur); close gcf
    
    % fprintf('Wait for button press to start next plot ...\n');
    % waitforbuttonpress; close gcf
end

% ----------------------------------------------------------------------- %
%% 03) T-test on difference:

% a) Select parameter:
iParam  = 6; 

% b) Select conditions: see sonVec
% iCond1  = 2; % dACC
% iCond1  = 3; % aIns

iCond2  = 1; % sham

% Compute t-test and Cohen's d:
diffVec = (sonParamMat(:, iParam, iCond1) - sonParamMat(:, iParam, iCond2));
[~, P, ~, STATS] = ttest(diffVec);
fprintf('Compare parameter %s for %s - %s:\n', paramNames{iParam}, sonVec{iCond1}, sonVec{iCond2});
fprintf('t(%d) = %.03f, p = %.03f, d = %.03f\n', ...
    STATS.df, STATS.tstat, P, mean(diffVec)/std(diffVec));

% ----------------------------------------------------------------------- %
%% 04) Loop over parameters, RM-ANOVA (ranova from Statistics & Machine Learning Toolbox):

% Select parameter, compute RM-ANOVA across all 3 conditions:
iParam          = 7;

fprintf('*** Test differences between sonication conditions for M%02d, parameters #%d out of %d (%s) ... ***\n', ...
    cfg.modID, iParam, length(paramNames), paramNames{iParam});

% % Dynamically create condition factor labels:
condNames       = arrayfun(@(x) sprintf('Cond%d', x), 1:nSon, 'UniformOutput', false)';

% Create a table as input for the ANOVA:
testMat         = squeeze(sonParamMat(:, iParam, :));
fprintf('*** Conditions are %s ***\n', strjoin(sonVec, ',    '));
fprintf('*** Means      are %s ***\n', strjoin(string(nanmean(testMat, 1)), ', '));
fprintf('*** SDs        are %s ***\n', strjoin(string(nanstd(testMat, 1)), ', '));
T               = array2table(testMat, 'VariableNames', sonVec); % Adjust 'CondX' names accordingly

% Define the within-subjects design:
withinDesign    = table(sonVec', 'VariableNames', {'Sonication'});
% 
% % Fit the repeated-measures model:
rm              = fitrm(T, 'sham-aIns~1', 'WithinDesign', withinDesign);
% rm              = fitrm(T, sprintf('Cond1-Cond%d~1', nPE), 'WithinDesign', withinDesign);

% Run the repeated-measures ANOVA
ranovaResults   = ranova(rm);

% Display the results
disp(ranovaResults);

% END OF FILE.