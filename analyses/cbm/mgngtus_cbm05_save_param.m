% mgngtus_cbm04_save_param.m

% Load model output, extract parameters, transform as necessary, 
% print descriptive statistics to console, 
% save as .csv files.
% 
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% 00) Initialize cfg:

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));

% Initialize:
cfg             = [];

% a) Sonication condition:
cfg.dataType    = 'sham';
% cfg.dataType    = 'dACC';
% cfg.dataType    = 'aIns';

% b) Fitting method:
cfg.parType     = 'lap'; % use only for LAP
cfg.parType     = 'hbi'; % use only for hbi

% c) Model to be loaded:
cfg.modID       = 1;

pauseDur        = 1;

% ----------------------------------------------------------------------- %
% 01) Save single model:

mgngtus_cbm_save_param(cfg);

% ----------------------------------------------------------------------- %
%% 02) Loop over models, settings, save:

% modVec  = [1:8 14:18];
modVec  = 20;
cfg     = [];

for iMod = modVec

    cfg.modID = iMod;

    for dataType = {'sham','dACC', 'aIns'}

        cfg.dataType = dataType{:};

        for parType = {'lap', 'hbi'}

            cfg.parType = parType{:};

            mgngtus_cbm_save_param(cfg);
    
        end % end parType
    end % end dataType
end % end iMod


% END OF SCRIPT.