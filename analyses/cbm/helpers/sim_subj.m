function subj = sim_subj()

% subj = sim_subj()
% 
% Initialize data for one "standard" subject for model simulations.
%
% INPUTS:
% none.
%
% OUTPUTS:
% subj          = structure with the following fields:
% .stimuli      = vector of integers, stimuli seen (1-16).
% .reqactions   = vector of integers, required action given stimulus (1 = Go, 0 = NoGo).
% .validity 	= vector of integers, validity validity (1 = valid, 0 = invalid). 
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% Retrieve settings:

cfg            = mgngtus_cbm_set_config();

% ----------------------------------------------------------------------- %
%% Create stimulus sequence (vector with all stimuli in consecutive order):

stimSeq         = repelem(1:cfg.nStim, cfg.nRep); % vector with all stimulus presented cfg.nRep times, NOT random!

% ----------------------------------------------------------------------- %
%% Categorize trial type:

% valenceSeq      = ismember(stimSeq, find(cfg.valenceVec)); % Win = 1, Avoid = 0
goSeq           = ismember(stimSeq, find(cfg.reqActVec)); % 1 = Go, 0 = NoGo.
% tabulate(goSeq)

% ----------------------------------------------------------------------- %
%% Sample feedback validity:

rng(70);
validity = nan(1, cfg.nTrial);
for iTrial = 1:cfg.nTrial
    validity(iTrial) = binornd(1, cfg.fbProb);
end

% ----------------------------------------------------------------------- %
%% Save into subj object:

subj.stimuli    = stimSeq';
subj.reqAct     = goSeq';
subj.validity   = validity';

end % END OF FUNCTION.