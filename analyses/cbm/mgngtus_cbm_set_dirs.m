function dirs = mgngtus_cbm_set_dirs()

% Set directories for mgngtus_cbm.
% 
% Replace dirs.git and dirs.onedrive with root directories for code and
% data within your own folder structure.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% we are here:
% cd C:/Users/johan/OneDrive/Documents/AACollaborations/MGNGUltrasoundNomiki/analyses/cbm

% clear all; close all; clc


% fprintf('*** Initialize directories ***\n')

% Initialize:
dirs            = [];

% Root directories:
dirs.git        = 'C:/Users/johan/OneDrive/Documents/AACollaborations/MGNGUltrasoundNomiki'; % adjust to local folder structure
dirs.onedrive   = dirs.git;

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
dirs.data       = fullfile(dirs.onedrive, 'data');
dirs.input      = fullfile(dirs.data, 'processedData', 'cbm');

% ----------------------------------------------------------------------- %
%% Results:

% Results:
dirs.results    = fullfile(dirs.onedrive, 'results', 'cbm');
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

% fprintf('*** Add CBM ***\n')
dirs.cbm        = 'C:/Users/johan/OneDrive/Documents/github-repositories/cbm/codes';
if ~contains(lower(path), lower(fullfile(dirs.cbm))); addpath(dirs.cbm); end

% ----------------------------------------------------------------------- %
%% Add Brewermap:

% https://uk.mathworks.com/matlabcentral/fileexchange/45208-colorbrewer-attractive-and-distinctive-colormaps

% Color map for plots:
% fprintf('*** Add brewermap ***\n');
dirs.brewermap  = 'C:/Users/johan/OneDrive/Documents/github-repositories/BrewerMap';
if ~contains(lower(path), lower(fullfile(dirs.brewermap))); addpath(dirs.brewermap); end

end % END OF FUNCTION