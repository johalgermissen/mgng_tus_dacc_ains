function custom_barplot(cfg, data)

% custom_barplot(cfg, data)
%
% Plot bar plot with one independent variable.
% 
% INPUTS:
% cfg           = structure with the following fields:
% .colMat       = nCond x 3 matrix of RGB colours.
% .CPS          = scalar numeric, cap size (error whiskers; optional; default: 12).
% .FTS          = scalar numeric, font size (optional; default 28).
% .fontType     = scalar string, font type (optional; default: Arial).
% .LWD          = scalar numeric, line width (optional; default: 4).
% .MKS          = scalar numeric, marker size (for individual data points; optional; default: 4).
% .xWidth       = scalar integer, width of plot in pixels (optional; default: 800).
% .xTick        = vector of numerics, location of x-axis ticks (optional).
% .xTickLabel   = cell with vector of strings, x-axis tick labels (optional).
% .addPoints    = scalar Boolean, add individual data points per subject or not (optional; default: false).
% .addLines     = scalar Boolean, connect individual data points per subject or not (optional; default: false).
% .yLim         = 1 x 2 vector of numerics, y-axis limits (optional).
% .xLab         = scalar string, x-axis label (optional).
% .yLab         = scalar string, y-axis label (optional).
% .title        = scalar string, title (optional).
% data          = nSub x nCond matrix with numerical values.
%
% OUTPUTS:
% none, just plotting; no saving functionality included.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Data dimensions:

dim         = size(data);
if length(dim) ~= 2
    error('***Input must be three dimensions (subjects x conditions x repetitions) ***');
end

nSub        = dim(1);
nCond       = dim(2);

xLoc        = 1:nCond;

% ----------------------------------------------------------------------- %
%% Aggregate data across subjects:

condMean        = squeeze(nanmean(data, 1));
condSE          = withinSE(data);

% ----------------------------------------------------------------------- %
%% Complete plotting settings:

% https://www.visualisingdata.com/2019/08/five-ways-to-design-for-red-green-colour-blindness/
if ~isfield(cfg, 'colMat')
    cfg.colMat  = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; % Var 1: dark green, light green, orange, red
    cfg.colMat  = repmat(cfg.colMat, nCond/4, 1); % fill up to number of conditions
end
if ~isfield(cfg, 'CPS'); cfg.CPS     = 12; end
if ~isfield(cfg, 'FTS'); cfg.FTS     = 28; end
if ~isfield(cfg, 'fontType'); cfg.fontType  = 'Arial'; end
if ~isfield(cfg, 'LWD'); cfg.LWD     = 4; end
if ~isfield(cfg, 'MKS'); cfg.MKS     = 4; end
if ~isfield(cfg, 'xWidth'); cfg.xWidth  = 800; end
if ~isfield(cfg, 'xTick'); cfg.xTick = xLoc; end % reuse locations as axis ticks
if ~isfield(cfg, 'xTickLabel'); cfg.xTickLabel= cfg.xTick; end % reuse locations as axis ticks

if ~isfield(cfg, 'addPoints'); cfg.addPoints    = false; end
if ~isfield(cfg, 'addLines'); cfg.addLines      = false; end

% ----------------------------------------------------------------------- %
%% Start figure:

% p = cell(nCond, 1);

close all
% Make figure:
figure('Position', [100 100 cfg.xWidth 800], 'Color', 'white'); hold on
% figure('Position', [100 100 1200 700], 'Color', 'white'); hold on
% figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Color', 'white'); hold on

% Bars:
for iCond = 1:nCond
    bar(xLoc(iCond), condMean(iCond), ...
        0.75, 'FaceColor', cfg.colMat(iCond, :));
end

% Whiskers:
errorbar(xLoc, condMean, condSE, ...
    'k', 'linestyle', 'none', 'linewidth', cfg.LWD, 'Capsize', cfg.CPS);

% Points per subject:
if cfg.addPoints && ~cfg.addLines
    for iCond = 1:nCond
        s = scatter(repmat(xLoc(iCond), 1, nSub), data(:, iCond) , [], ...
            'k', 'jitter', 'on', 'jitterAmount', 0.10); hold on % was 0.05
        set(s, 'MarkerEdgeColor', [0.4 0.4 0.4], 'linewidth', 2); % was 1 
    %     plot(repelem(xLoc(iParam), nSub), subParamMat(:, iParam), 'k*')
    end
end

% Lines per subject:
if cfg.addLines
    for iSub = 1:nSub % loop over subjects
        plot(xLoc + rand(1)*0.1, data(iSub, :), '-o', 'Color', [0.3 0.3 0.3], 'linewidth', 1, 'MarkerSize', cfg.MKS);
    end
end

% Add plot features:
set(gca,'xtick', cfg.xTick, 'xticklabel', cfg.xTickLabel,...
    'Linewidth', cfg.LWD, 'FontSize', cfg.FTS);
box off

% Axis limits:
xlim([min(xLoc) - 0.5 max(xLoc) + 0.5]);
if isfield(cfg, 'yLim'); ylim(cfg.yLim); end

% Axis labels:
if isfield(cfg, 'xLab'); xlabel(cfg.xLab, 'FontSize', cfg.FTS, 'FontName', cfg.fontType); end
if isfield(cfg, 'yLab'); ylabel(cfg.yLab, 'FontSize', cfg.FTS, 'FontName', cfg.fontType); end

% Title:
if isfield(cfg, 'title'); title(cfg.title, 'FontSize', cfg.FTS, 'FontWeight', 'bold', 'FontName', cfg.fontType); end

end % END OF FUNCTION.