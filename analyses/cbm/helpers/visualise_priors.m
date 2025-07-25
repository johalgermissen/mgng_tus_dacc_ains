% visualise_priors.m
%
% Visualize distribution of prior given mean and variance.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Set parameters (mean and variance:

selMean = -3;
selVar  = 1;

% ----------------------------------------------------------------------- %
%% Sample data:

rawVec      = randn(1, 100000) * sqrt(selVar) + selMean; 

% ----------------------------------------------------------------------- %
%% Transform data:

transfVec   = exp(rawVec) ./ (1 + exp(rawVec)); transformation = 'sigmoid';

% ----------------------------------------------------------------------- %
%% Plotting settings:

CPS             = 12; % cap size for whiskers
FTS             = 24; % font size
FTT             = 'Arial'; % font type
LWD             = 5; % line width

% ----------------------------------------------------------------------- %
%% Start plot:

close all
figure('color', 'white', 'Position',[100 100 800 800]); hold on

histogram(transfVec); 
% histcounts(transfVec); 
% histfit(transfVec); 

% Axis limits:
% xlim([0 1]); box off

% Set settings:
set(gca, 'Linewidth', LWD, 'FontSize', FTS);
xlabel('parameter value', 'FontSize', FTS, 'FontName', FTT);
ylabel('density', 'FontSize', FTS, 'FontName', FTT);
title(sprintf('Mean = %.02f, Var = %.02f, %s transform', ...
    selMean, selVar, transformation), 'FontWeight', 'bold', 'FontSize', FTS, 'FontName', FTT, 'Interpreter', 'none');
box off; hold off

% Save:
figName         = sprintf('density_M%d_Var%d_%s.png', selMean, selVar, transformation);
fprintf('Save as %s ...\n', figName);
saveas(gcf, fullfile(dirs.plot, figName));
fprintf('... finished! :-)\n');
pause(3);
close gcf

% END