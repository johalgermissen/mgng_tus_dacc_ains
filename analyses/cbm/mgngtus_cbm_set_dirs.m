function dirs = mgngtus_cbm_set_dirs()

% Set directories for mgngtus_cbm.
% 
% Replace dirs.root with root directories for code and
% data within your own folder structure.
% Also add paths to CBM and Brewermap toolboxes at the end.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% Initialize output object:

% Initialize:
dirs            = [];

% Root directories:
dirs.root       = '...\mgng_tus_dacc_ains'; % adjust to local folder structure

% ----------------------------------------------------------------------- %
%% Scripts:

% Scripts:
dirs.scripts    = fullfile(dirs.git, 'analyses', 'cbm'); % adjust to local folder structure
if ~contains(lower(path), lower(fullfile(dirs.scripts))); addpath(dirs.scripts); end

dirs.helpers    = fullfile(dirs.scripts, 'helpers');
if ~contains(lower(path), lower(fullfile(dirs.helpers))); addpath(dirs.helpers); end

dirs.models     = fullfile(dirs.scripts, 'models');
if ~contains(lower(path), lower(fullfile(dirs.models))); addpath(dirs.models); end

dirs.osaps      = fullfile(dirs.scripts, 'osaps');
if ~contains(lower(path), lower(fullfile(dirs.osaps))); addpath(dirs.osaps); end

dirs.modSims    = fullfile(dirs.scripts, 'modSims');
if ~contains(lower(path), lower(fullfile(dirs.modSims))); addpath(dirs.modSims); end

% ----------------------------------------------------------------------- %
%% Data:

% Input data:
dirs.data       = fullfile(dirs.root, 'data');
dirs.input      = fullfile(dirs.data, 'processedData', 'cbm');

% ----------------------------------------------------------------------- %
%% Results:

% Results:
dirs.results    = fullfile(dirs.root, 'results', 'cbm');
if ~exist(dirs.results, 'dir'); mkdir(dirs.results); end

dirs.lap        = fullfile(dirs.results, 'lap');
if ~exist(dirs.lap, 'dir'); mkdir(dirs.lap); end

dirs.hbi        = fullfile(dirs.results, 'hbi');
if ~exist(dirs.hbi, 'dir'); mkdir(dirs.hbi); end

dirs.plot       = fullfile(dirs.results, 'plots');
if ~exist(dirs.plot, 'dir'); mkdir(dirs.plot); end

dirs.final      = fullfile(dirs.plot, 'final');
if ~exist(dirs.final, 'dir'); mkdir(dirs.final); end

dirs.sims       = fullfile(dirs.results, 'simulations');
if ~exist(dirs.sims, 'dir'); mkdir(dirs.sims); end

dirs.params     = fullfile(dirs.results, 'parameters');
if ~exist(dirs.params, 'dir'); mkdir(dirs.params); end

dirs.paramRecov = fullfile(dirs.results, 'parameter_recovery');
if ~exist(dirs.paramRecov, 'dir'); mkdir(dirs.paramRecov); end

dirs.modRecov   = fullfile(dirs.results, 'model_recovery');
if ~exist(dirs.modRecov, 'dir'); mkdir(dirs.modRecov); end

% ----------------------------------------------------------------------- %
%% Add CBM functions:

% https://github.com/payampiray/cbm

dirs.cbm        = '.../cbm/codes';
if ~contains(lower(path), lower(fullfile(dirs.cbm))); addpath(dirs.cbm); end

% ----------------------------------------------------------------------- %
%% Add Brewermap:

% https://uk.mathworks.com/matlabcentral/fileexchange/45208-colorbrewer-attractive-and-distinctive-colormaps

% Color map for plots:
dirs.brewermap  = '.../BrewerMap';
if ~contains(lower(path), lower(fullfile(dirs.brewermap))); addpath(dirs.brewermap); end

end % END OF FUNCTION