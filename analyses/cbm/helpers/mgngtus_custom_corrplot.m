function mgngtus_custom_corrplot(cfg, corrMat)

% Plot correlation matrix with imagesc.
%
% INPUTS:
% cfg           = structure with the following fields:
% .tickNames    = nTick x 1 vector of strings, names of rows/columns
% (optional).
% .isNewFig     = scalar Boolean, open new window for figure or not
% (default: true).
% .colMap       = scalar string, colour map (default: 'rdBu').
% .cLim         = 1 x 2 vector of colour axis range (default: [-1 1]).
% .cLabel       = scalar string, colour axis labels (default: 'Correlation
% value').
% .FTS          = scalar numeric, font size (optional; default adaptively
% determined based on number of axis ticks).
% .LWD          = scalar numeric, line width (optional; default: 1).
% .xLabel       = scalar string, x-axis label (optional).
% .yLabel       = scalar string, y-axis label (optional).
% .title        = scalar string, title (optional).
% corrMat       = square 2D matrix of correlations.
% 
% OUTPUTS:
% none, just plotting; no saving functionality included.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% Check inputs:
if ~ismatrix(corrMat); error('*** Input corMat must be 2D matrix ***'); end
if size(corrMat, 1) ~= size(corrMat, 2); error('*** Input corMat not a square ***'); end

% Extract dimensions:
nTick   = size(corrMat, 1); % number rows/ columns
tickVec = 1:nTick; % tick vector

fprintf('*** Plot %d x %d matrix with imagesc ***\n', nTick, nTick);

if ~isfield(cfg, 'tickNames')
    cfg.tickNames   = tickVec; % if no names provided: use numbers
end

if ~isfield(cfg, 'isNewFig')
    cfg.isNewFig    = true; % start new figure
end

if ~isfield(cfg, 'colMap')
    cfg.colMap      = 'rdBu';
end

if ~isfield(cfg, 'cLim')
    cfg.cLim        = [-1 1];
end

if ~isfield(cfg, 'cLabel')
    cfg.cLabel      = 'Correlation value';
end

% ----------------------------------------------------------------------- %
%% Set general plot settings:

% Font size and line width:
if ~isfield(cfg, 'FTS')
    if nTick < 5
        cfg.FTS = 18; 
    else 
        if cfg.isNewFig % singular plot
            cfg.FTS = 12;
        else % part of subplot
            if nTick > 25
                cfg.FTS = 4;
            elseif nTick > 10
                cfg.FTS = 6;
            else
                % cfg.FTS = 4;
                cfg.FTS = 10;
            end
        end
    end
end

if ~isfield(cfg, 'LWD')
    cfg.LWD = 1; 
end

% ----------------------------------------------------------------------- %
%% Start plot:

if cfg.isNewFig
    % close all
    figure('Position', [100 100 800 800], 'Color', 'white'); hold on
    % figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Color', 'white'); hold on
end

% Plot with corrplot:
if cfg.isNewFig
    imagesc(flipud(corrMat)); % flip columns
    xLabelVec = cfg.tickNames; yLabelVec = flip(cfg.tickNames);
    corMatPrint = corrMat;
else
    imagesc(flipud(corrMat)); % flip columns
    % imagesc(corMat); % flip columns
    xLabelVec = cfg.tickNames; yLabelVec = flip(cfg.tickNames);
    corMatPrint = flipud(corrMat);
end

%% Add correlation values as text to panels:

for iRow = 1:nTick
    for iCol = 1:nTick
        if cfg.isNewFig
            text(iRow, nTick + 1 - iCol, sprintf('%.2f', corMatPrint(iRow, iCol)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'Color', 'k', 'fontsize', cfg.FTS);
        else
            text(nTick + 1 - iRow, nTick + 1 - iCol, sprintf('%.2f', corMatPrint(iRow, iCol)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                'Color', 'k', 'fontsize', cfg.FTS);
        end
    end
end

% ----------------------------------------------------------------------- %
%% Add other image settings:

% Set axis limits:
xlim([min(tickVec) - 0.5 max(tickVec) + 0.5]);
ylim([min(tickVec) - 0.5 max(tickVec) + 0.5]);

axis square;
% axis equal;

% Add tick labels:
set(gca, 'xtick', tickVec, 'XTickLabel', xLabelVec, ...
    'ytick', tickVec, 'YTickLabel', yLabelVec);

% Add axis labels and title:
if isfield(cfg, 'xLabel'); xlabel(cfg.xLabel, 'FontSize', cfg.FTS); end
if isfield(cfg, 'yLabel'); ylabel(cfg.yLabel, 'FontSize', cfg.FTS); end
if isfield(cfg, 'title'); title(cfg.title, 'FontSize', cfg.FTS); end

% Set font size and line width:
set(gca, 'FontSize', cfg.FTS, 'LineWidth', cfg.LWD); %

% ----------------------------------------------------------------------- %
%% Add color map:

% Select color map:
% colormap('jet');
% colormap('parula');
% colormap('turbo');

% Based on Brewermap: 
% https://uk.mathworks.com/matlabcentral/mlc-downloads/downloads/e5a6dcde-4a80-11e4-9553-005056977bd0/a64ed616-e9ce-4b1d-8d18-5118cc03f8d2/images/screenshot.png
if strcmp(cfg.colMap, 'YlOrRd')
    colormap(brewermap(200, 'YlOrRd')); % from yellow to red (like magma)
elseif strcmp(cfg.colMap, 'rdBu')
    colormap(flipud(brewermap(200, 'rdBu'))); % flipped, so from red to blue
elseif strcmp(cfg.colMap, 'YlGnBu')
colormap(flipud(brewermap(200, 'YlGnBu'))); % like viridis, from yellow to blue
    error('Unknown color map %s', cfg.colMap);
end

% Set color axis limits:
clim(cfg.cLim);

% Add color-bar:
cb = colorbar;
xlabel(cb, cfg.cLabel); % add label
set(get(cb, 'xLabel'), 'Rotation', 270, 'FontSize', cfg.FTS); % rotate

% Move to the right:
xh = get(cb, 'xlabel'); % handle to the label object
p = get(xh, 'position'); % get the current position property
p(1) = p(1) + 1.6;      % add 1.6 to distance
set(xh, 'position', p) 

end % END OF FUNCTION.