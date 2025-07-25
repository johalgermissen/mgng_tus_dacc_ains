function mgngtus_plot_param(cfg, data)

% mgngtus_plot_param(cfg, data)
% 
% Plot variable Y (parameters) as a function of X (x-axis; sonication
% condition) and Z (individual dots; subjects).
%
% INPUTS:
% cfg       = structure with several optional fields.
% data      = nSub x nCond matrix of numerical variables.
% 
% OUTPUTS:
% none, just plotting; no saving functionality included.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Complete inputs:

if ~isfield(cfg, 'xVec')
    cfg.xVec        = 1:size(data, 2);
end
if ~isfield(cfg, 'xTick')
    cfg.xTick       = cfg.xVec;
end
if ~isfield(cfg, 'zVec')
    cfg.zVec        = 1:size(data, 1);
end
if ~isfield(cfg, 'zTick')
    cfg.zTick       = cfg.zVec;
end
if ~isfield(cfg, 'pauseDir')
    cfg.pauseDir    = 1;
end
if ~isfield(cfg, 'addPoints')
    cfg.addPoints   = false;
end
if ~isfield(cfg, 'addLines')
    cfg.addLines    = false;
end
if ~isfield(cfg, 'addLinesColour')
    cfg.addLinesColour    = false;
end

% ----------------------------------------------------------------------- %
%% Fixed plotting settings:

LWD         = 3;
LWDsubject  = 1;
MKS         = 4;
FTS         = 16; % 18
CPS         = 12;

% ----------------------------------------------------------------------- %
%% Aggregate data:

nX                  = length(cfg.xVec);
nZ                  = length(cfg.zVec);
fprintf('*** Create plot based on %d rows and %d columns ***\n' , nZ, nX);

subMean             = squeeze(nanmean(data(cfg.zVec, cfg.xVec), 2)); % average across conditions
grandMean           = squeeze(nanmean(subMean, 1)); % average across subjects
condMean            = nan(nX, 1);
condSE              = nan(nX, 1);
for iX = 1:nX
    xID                 = cfg.xVec(iX);
    condMean(iX)        = squeeze(nanmean(data(cfg.zVec, xID), 1)); % average over subjects
    condSE(iX)          = nX / (nX - 1) * nanstd(squeeze(data(cfg.zVec, xID)) - ...
        subMean + repmat(grandMean, nZ, 1)) ./ sqrt(nZ);
end

% ----------------------------------------------------------------------- %
%% Initialize variable settings:

% Colour map for bars:
if ~isfield(cfg, 'colMat')
    cfg.colMat      = repmat([175 175 175] ./ 255, nX, 1); % grey for bars
end

% Color map for lines:
% cmap = jet(nZ); % color per z-level (line)
cmap        = turbo(nZ); % color per z-level (line)

% Initialize:
legendVec   = [];
xLoc        = 1:nX;

% ----------------------------------------------------------------------- %
%% Start plot:

close all
figure('Color', 'white', 'Position', [100 100 500 500]); hold on % parameters
% figure('Color', 'white', 'Position', [100 100 900 500]); hold on % log-likelihoods
% figure('Color', 'white', 'Position', [100 100 1200 700]); hold on
% figure('Color', 'white', 'units', 'normalized', 'outerposition', [0 0 1 1]); hold on

% ----------------------------------------------------------------------- %
% Add bars and error bars:

% Loop over conditions:
for iX = 1:nX
    % xID     = cfg.zVec(iX);
    % Bars:
    bar(xLoc(iX), condMean(iX), .75, 'FaceColor', cfg.colMat(iX, :)); % bar plot
    % Error bars:
    errorbar(xLoc(iX), condMean(iX), condSE(iX), ...
        'k', 'linestyle', 'none', 'linewidth', LWD, 'Capsize', CPS); % error bars
    % a) Grey points:
    if cfg.addPoints && ~cfg.addLines && ~cfg.addLinesColour
        s = scatter(repmat(xLoc(iX), 1, nZ), data(cfg.zVec, iX)', ...
            [],'k', 'jitter', 'on', 'jitterAmount', 0.15); hold on % was 0.05
        set(s, 'MarkerEdgeColor', [0.4 0.4 0.4], 'linewidth', LWD); % was 1 
    end
end

% Grey points and lines:
if cfg.addLines && ~cfg.addLinesColour
    p   = cell(1, nZ);
    for iZ = 1:nZ % loop over subjects
        zID     = cfg.zVec(iZ);
        p{iZ}   = plot(xLoc, data(zID, cfg.xVec), '-o', 'Color', [0.4 0.4 0.4], 'linewidth', LWDsubject, 'MarkerSize', MKS);
    end
end

% Plot colourful lines:
if cfg.addLinesColour
    p   = cell(1, nZ);
    for iZ = 1:nZ % loop over subjects
        zID     = cfg.zVec(iZ);
        p{iZ}   = plot(xLoc, data(zID, cfg.xVec), '-*', 'Color', cmap(iZ, :), 'linewidth', LWD, 'MarkerSize', MKS);
        legendVec = [legendVec; sprintf('%s %02d', cfg.zLabel, cfg.zTick(iZ))];
    end
end

% ----------------------------------------------------------------------- %
%% Add plot settings:

% Add axis limits:
if ~isfield(cfg, 'xLim')
    if cfg.addLinesColour
        nCol        = ceil(nZ/ 20);
        cfg.xLim    = [0.5 nX * (1.0 + 0.4 * nCol)];
    else
        cfg.xLim    = [0.5 nX + 0.5];
    end
end
if ~isfield(cfg, 'yLim')
    if cfg.addPoints || cfg.addLines || cfg.addLinesColour
        selData     = data(cfg.zVec, cfg.xVec);
        yMin        = min(selData(:));
        yMax        = max(selData(:));
    else
        yMin        = min(condMean - condSE);
        yMax        = max(condMean + condSE);
    end
    if yMin < 0; yMin = yMin * 1.1; end
    if yMax < 0; yMax = yMax * 0.9; end
    if yMin > 0; yMin = yMin * 0.9; end
    if yMin > 0; yMax = yMax * 1.1; end
    cfg.yLim    = [yMin yMax];
end
fprintf('*** Use xLim %.2f - %.02f, yLim %.02f - %.02f ***\n', ...
    cfg.xLim(1), cfg.xLim(2), cfg.yLim(1), cfg.yLim(2));
xlim(cfg.xLim);
ylim(cfg.yLim);

% Add other settings:
set(gca, 'xtick', 1:nX, 'xticklabel', cfg.xTick, ...
    'Linewidth', LWD, 'FontSize', FTS);

% Add labels:
if contains(cfg.xLabel, '$') || contains(cfg.yLabel, '$')
    xlabel(cfg.xLabel, 'interpreter', 'latex');
    ylabel(cfg.yLabel, 'interpreter', 'latex');
    set(gca, 'TickLabelInterpreter', 'latex');
else
    xlabel(cfg.xLabel);
    ylabel(cfg.yLabel);
end

% Add title:
if cfg.addLinesColour
    if contains(cfg.yLabel, '$') || contains(cfg.xLabel, '$') 
        if isfield(cfg, 'modID')
            title(sprintf('M%02d: %s per %s (x-axis) and %s (line colour)\nfit with %s', ...
                cfg.modID, cfg.yLabel, lower(cfg.xLabel), lower(cfg.zLabel), cfg.fitName), 'interpreter', 'latex');
        else
            title(sprintf('%s per %s (x-axis) and %s (line colour)\nfit with %s', ...
                cfg.yLabel, lower(cfg.xLabel), lower(cfg.zLabel), cfg.fitName), 'interpreter', 'latex');
        end
    else
        if isfield(cfg, 'modID')
            title(sprintf('M%02d: %s per %s (x-axis) and %s (line colour)\nfit with %s', ...
                cfg.modID, cfg.yLabel, lower(cfg.xLabel), lower(cfg.zLabel), cfg.fitName));
        else
            title(sprintf('%s per %s (x-axis) and %s (line colour)\nfit with %s', ...
                cfg.yLabel, lower(cfg.xLabel), lower(cfg.zLabel), cfg.fitName));
        end
    end
else % if no lines (z-axis) added
    if contains(cfg.yLabel, '$') || contains(cfg.xLabel, '$') 
        if isfield(cfg, 'modID')
            title(sprintf('M%02d: %s per %s (x-axis)\nfit with %s', ...
                cfg.modID, cfg.yLabel, lower(cfg.xLabel), cfg.fitName), 'interpreter', 'latex');
        else
            title(sprintf('%s per %s (x-axis)\nfit with %s', ...
                cfg.yLabel, lower(cfg.xLabel), cfg.fitName), 'interpreter', 'latex');
        end
    else
        if isfield(cfg, 'modID')
            title(sprintf('M%02d: %s per %s (x-axis)\nfit with %s', ...
                cfg.modID, cfg.yLabel, lower(cfg.xLabel), cfg.fitName));
        else
            title(sprintf('%s per %s (x-axis)\nfit with %s', ...
                cfg.yLabel, lower(cfg.xLabel), cfg.fitName));
        end
    end
end

if cfg.addLinesColour
    % a) Legend at the side, separate box:
    legend([p{:}], legendVec); legend boxoff
    % b) Legend at the top:
    % legend(legendVec, 'Location', 'north', 'Orientation', 'horizontal'); legend box off
    % Multiple columns:
    lgd             = legend;
    fontsize(lgd, 10, 'points');
    lgd.NumColumns  = nCol;  
end

end % END OF FUNCTION.