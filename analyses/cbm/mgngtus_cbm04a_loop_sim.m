% mgngtus_cbm04_loop_sim.m
%
% Wrapper to call mgngtus_cbm_wrapper_sim for model simulations and one-step-ahead predictions.
%
% INPUTS:
% None, set settings for simulations interactively.
%
% OUTPUTS:
% None, mgngtus_cbm04_loop_sim saves to disk.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% Initialize root directory, add path:

% Change directory to location of this file:
cd(fileparts(matlab.desktop.editor.getActiveFilename));

dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% Select models:

nMod            = 9;
modVec          = 1:nMod;
% modVec          = 1:7;

% ----------------------------------------------------------------------- %
%% Initialize job settings:

job             = []; % initialize empty job

% a) Simulation type:
job.simType     = 'osap'; % modSim, osap
% job.simType     = 'modSim'; % modSim, osap

% b) Parameter type:
job.parType     = 'lap'; % lap, hbi
% job.parType     = 'hbi'; % lap, hbi

% c) Sonication condition:
job.dataType    = 'sham';
% job.dataType    = 'dACC';
% job.dataType    = 'aIns';

% d) Number of iterations:
job.nIter       = 100;

% ----------------------------------------------------------------------- %
%% Loop over models:

% Loop over models:
% for iMod = 1:nMod % iMod = 1;
for iMod = modVec % iMod = 1;
    	
    job.iMod    = iMod;
    fprintf('\n* --------------------------------------------------------------------------------- *\n');
    fprintf('*** Start simulating model %02d ***\n', job.iMod);
    mgngtus_cbm_wrapper_sim(job);

end % end iMod
beep;

% END OF FILE.