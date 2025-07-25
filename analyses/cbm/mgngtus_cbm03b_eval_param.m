% mgngtus_cbm03a_eval_param.m
%
% Load model output, extract parameters, transform as necessary, 
% print descriptive statistics to console, 
% save as .csv files, 
% plot each parameter as bar in bar plots (save).
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

% Sonication condition:
cfg.dataType    = 'sham';
% cfg.dataType    = 'dACC';
% cfg.dataType    = 'aIns';

% Fitting method:
% cfg.parType     = 'lap'; % use only for LAP
cfg.parType     = 'hbi'; % use only for hbi

% Model to be loaded:
cfg.modID       = 8;

pauseDur        = 1;

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 01a) Load model fitted with LAP or HBI:

% Load model:
cbm             = mgngtus_cbm_load_model(cfg);

% Extract model outputs:
if isfield(cbm, 'groupParamMat'); groupParamMat = cbm.groupParamMat; end
if isfield(cbm, 'errorbar'); groupErrorbar = cbm.errorbar; end
subParamMat     = cbm.subParamMat;
subParamMatRaw  = subParamMat; % backup copy of raw parameter values before transform
nSub            = size(subParamMat, 1);
nParam          = size(subParamMat, 2);

% ----------------------------------------------------------------------- %
% Transform group and subject parameters appropriately:

subParamMat     = transform_parameters(subParamMat, cfg.modID);

% ----------------------------------------------------------------------- %
% Determine parameter names:
tmp             = format_paramNames(cfg.modID);
paramNames      = tmp.paramNames;
paramNamesPlot  = tmp.paramNamesLaTeX;

% ----------------------------------------------------------------------- %
% Print descriptive statistics to console:

for iParam = 1:nParam
    fprintf('M%02d Parameter %s: M = %.02f, SD = %.02f, range = %.2f - %.02f\n', ...
        cfg.modID, paramNames{iParam}, mean(subParamMat(:, iParam)), std(subParamMat(:, iParam)), ...
        min(subParamMat(:, iParam)), max(subParamMat(:, iParam)));
end

% ----------------------------------------------------------------------- %
%% 01b) Save (either LAP or HBI):

if exist('groupParamMat', 'var')
    fprintf('Save transformed group-level parameters under %s, model %02d\n', cfg.parType, cfg.modID);
    fileName = fullfile(eval(sprintf("dirs.%s", cfg.parType)), ...
        sprintf('CBM_%s_M%02d_groupParameters.csv', cfg.parType, cfg.modID));
    csvwrite(fileName, groupParamMat);
end

if exist('subParamMat', 'var')
    fprintf('Save transformed subject-level parameters under %s, model %02d\n', cfg.parType, cfg.modID);
    fileName = fullfile(eval(sprintf("dirs.%s", cfg.parType)), ...
    sprintf('CBM_%s_M%02d_subjectParameters.csv', cfg.parType, cfg.modID));
    csvwrite(fileName, subParamMat);
end

% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%% 02) Bar plots with dots for all parameters in model:

% Figure settings:
CPS             = 12; % cap size for whiskers
FTS             = 32; % font size
FTT             = 'Arial'; % font type
LWD             = 5; % line width

% Select y-axis limit:
for yMax = [1 10 max(subParamMat(:))]
    % yMax = max(subParamMat(:)); % from 0 to any maximum
    % yMax = 1; % from 0 to 1

    fprintf('*** Plot parameters for M%02d (%s) with yMax = %.02f ... ***\n', cfg.modID, cfg.dataType, yMax);
    
    % ------------------------------------------------------------------- %
    % X-axis locations:
    xLoc    = 1:1:(0.5 + nParam); % x-axis positions
    
    % Make figure:
    close all
    figure('color', 'white', 'Position',[100 100 800 800]); hold on
    % figure('color', 'white', 'Position', [100 100 1200 700]); hold on
    % figure('color', 'white', 'units', 'normalized', 'outerposition', [0 0 1 1]); hold on
    
    % Bars:
    % barScatter(ScatterMatrix, [], [], true, true, colMat, posMat);
    bar(xLoc, mean(subParamMat, 1));
    
    % Whiskers:
    errorbar(xLoc, mean(subParamMat, 1), std(subParamMat, 1) ./ sqrt(nSub), ...
        'r', 'linestyle', 'none', 'linewidth', LWD, 'Capsize', CPS);
    
    % Points:
    for iParam = 1:nParam
        paramVec = subParamMat(:, iParam);
        fprintf('Parameter #%d (%s): Mean = %.02f, range %.02f - %.02f\n', ...
            iParam, paramNames{iParam}, mean(paramVec), min(paramVec), max(paramVec));
        s = scatter(repmat(xLoc(iParam), 1, nSub), paramVec, [],...
            'k', 'jitter', 'on', 'jitterAmount', 0.10); hold on % was 0.05
        set(s, 'MarkerEdgeColor', [0.4 0.4 0.4], 'linewidth', 2); % was 1 
    %     plot(repelem(xLoc(iParam), nSub), subParamMat(:, iParam), 'k*')
    end
    
    % Add plot features:
    if min(subParamMat(:)) < 0; yMin = floor(min(subParamMat(:))); else; yMin = 0; end
    % yMax = max(subParamMat(:)); % from 0 to any maximum
    % yMax = 1; % from 0 to 1
    ylim([yMin yMax]);
    set(gca,'xtick', 1:nParam, 'xticklabel', paramNamesPlot,...
        'Linewidth', LWD, 'FontSize', FTS, 'TickLabelInterpreter', 'latex')
    xlabel('Parameter', 'FontSize', FTS, 'FontName', FTT);
    ylabel('Parameter estimates', 'FontSize', FTS, 'FontName', FTT);
    title(sprintf('Model %02d (%s, %s)', cfg.modID, cfg.dataType, cfg.parType), 'FontSize', FTS);
    box off; hold off
    
    % Save:
    figName = sprintf('barplot_param_%s_mod%02d_%s_yMax%02d.png', ...
        cfg.parType, cfg.modID, cfg.dataType, round(yMax));
    saveas(gcf, fullfile(dirs.param, figName));
    pause(pauseDur);
    close gcf
end
fprintf('Finished plotting :-)\n')

% END OF FILE.