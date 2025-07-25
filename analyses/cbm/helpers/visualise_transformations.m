% visualise_transformations.m
%
% Visualize vector before/after selected transformation.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));
cd('..');
dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% Specify transformation:

% transformation = 'exp';
% transformation = 'sigmoid';
% transformation = 'log1p_exp';

% ----------------------------------------------------------------------- %
%% Specify input data:

% x = -10:0.1:10;
x = -5:0.1:5;

% ----------------------------------------------------------------------- %
%% Apply transformation:

y = eval(sprintf('%s(x)', transformation));

% ----------------------------------------------------------------------- %
%% Figure settings:

CPS             = 12; % cap size for whiskers
FTS             = 32; % font size
FTT             = 'Arial'; % font type
LWD             = 5; % line width

% ----------------------------------------------------------------------- %
%% Make figure:

close all
figure('color', 'white', 'Position',[100 100 800 800]); hold on

plot(x, y, 'k-', 'LineWidth', LWD);

set(gca, 'Linewidth', LWD, 'FontSize', FTS);
xlabel('x', 'FontSize', FTS, 'FontName', FTT);
ylabel(sprintf('%s(x)', transformation), 'FontSize', FTS, 'FontName', FTT);
title(sprintf('%s(x)', transformation), 'FontWeight', 'bold', 'FontSize', FTS, 'FontName', FTT, 'Interpreter', 'none');
box off; hold off

% Save:
figName         = sprintf('transformation_%s.png', transformation);
saveas(gcf, fullfile(dirs.plot, figName));
close gcf

% END OF FILE.