function custom_lineplot(cfg, data)

% custom_lineplot(cfg, data)
%
% Plot line plot with time on x-axis and condition as separate lines (with
% error shades).
%
% INPUTS:
% cfg           = structure with the following fields:
% .colMat       = nCond x 3 matrix of RGB colours.
% .FTS          = scalar numeric, font size (optional; default 28).
% .fontType     = scalar string, font type (optional; default: Arial).
% .LWD          = scalar numeric, line width (optional; default: 4).
% .xWidth       = scalar integer, width of plot in pixels (optional; default: 800).
% .xTick        = vector of numerics, location of x-axis ticks (optional).
% .xTickLabel   = cell with vector of strings, x-axis tick labels (optional).
% .addPoints    = scalar Boolean, add individual data points per subject or not (optional; default: false).
% .addLines     = scalar Boolean, connect individual data points per subject or not (optional; default: false).
% .yLim         = 1 x 2 vector of numerics, x-axis limits (optional).
% .yLim         = 1 x 2 vector of numerics, y-axis limits (optional).
% .xLab         = scalar string, x-axis label (optional).
% .yLab         = scalar string, y-axis label (optional).
% .xTick        = vector of numerics, x-axis tick points (optional).
% .yTick        = vector of numerics, y-axis tick points (optional).
% .title        = scalar string, title (optional).
% data          = nSub x nCond x nTime matrix with numerical values.
%
% OUTPUTS:
% none, just plotting; no saving functionality included.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Extract data dimensions:

dim         = size(data);
if length(dim) ~= 3
    error('***Input must be three dimensions (subjects x conditions x repetitions) ***');
end

nSub        = dim(1);
nCond       = dim(2);
nRep        = prod(dim)/nSub/nCond;

% ----------------------------------------------------------------------- %
%% Aggregate data across subjects:

condMean        = squeeze(nanmean(data, 1));
condSE          = withinSE(data);

% ----------------------------------------------------------------------- %
%% Complete plotting settings:

% https://www.visualisingdata.com/2019/08/five-ways-to-design-for-red-green-colour-blindness/
if ~isfield(cfg, 'colMat'); cfg.colMat      = [0 113 116; 201 61 33; 0 113 116; 201 61 33] ./ 255; end % Var 1: dark green, light green, orange, red
if ~isfield(cfg, 'FTS'); cfg.FTS            = 28; end
if ~isfield(cfg, 'fontType'); cfg.fontType  = 'Arial'; end
if ~isfield(cfg, 'LWD'); cfg.LWD            = 4; end
if ~isfield(cfg, 'xWidth'); cfg.xWidth      = 800; end

% ----------------------------------------------------------------------- %
%% Start figure:

p = cell(nCond, 1);  % initialize

% Open figure:
close all
figure('Position', [100 100 cfg.xWidth 800], 'Color', 'white'); 
% figure('Position', [100 100 1200 700], 'Color', 'white'); hold on
% figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Color', 'white'); hold on

% ----------------------------------------------------------------------- %

% Plot line with error shade:
for iCond = 1:nCond
    p{iCond} = boundedline(1:nRep, condMean(iCond, :), condSE(iCond, :), ...
        'cmap', cfg.colMat(iCond, :), 'alpha');
    set(p{iCond}, 'Linewidth', cfg.LWD) % adjust line width

    if iCond > nCond/2  % adjust line style for NoGo cues (second half of conditions)
        set(p{iCond}, 'Linestyle', '--');
    end
    
end % end iCond

% ----------------------------------------------------------------------- %
%% Add plot features:

% Set axis limits:
if ~isfield(cfg, 'xLim'); cfg.xLim = [0 nRep]; end
if ~isfield(cfg, 'yLim'); cfg.yLim = [0 1]; end
set(gca,'xlim', cfg.xLim, 'ylim', cfg.yLim, 'Linewidth', cfg.LWD);

% Set axis ticks:
if ~isfield(cfg, 'xTick'); cfg.xTick = 0:.2:1; end
if ~isfield(cfg, 'yTick'); cfg.yTick = 0:10:nRep; end
set(gca,'xtick', cfg.xTick, 'ytick', cfg.yTick, 'FontSize', cfg.FTS, 'Linewidth', cfg.LWD);
box off

% Axis labels:
if isfield(cfg, 'xLab'); xlabel(cfg.xLab, 'FontSize', cfg.FTS, 'FontName', cfg.fontType); end
if isfield(cfg, 'yLab'); ylabel(cfg.yLab, 'FontSize', cfg.FTS, 'FontName', cfg.fontType); end

% Title:
if isfield(cfg, 'title'); title(cfg.title, 'FontSize', cfg.FTS, 'FontWeight', 'bold', 'FontName', cfg.fontType); end

end % END OF FUNCTION.