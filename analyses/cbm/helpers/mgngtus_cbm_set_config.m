function cfg = mgngtus_cbm_set_config()

% cfg = mgngtus_cbm_set_config()
%
% Set task configuration parameters.
%
% INPUTS:
% none
% 
% OUTPUTS:
% cfg           = structure with several fields (see below).
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% fprintf('*** Initialize settings ***\n')

% Fixed input settings:
cfg.nCond       = 4; % number cue conditions, here 4: Go2Win, Go2Avoid, NoGo2Win, NoGo2Avoid
cfg.nBlock      = 4; % number of blocks
cfg.nRep        = 20; % number presentations of each cue, here 20

% Downstream settings:
cfg.nStim       = cfg.nCond * cfg.nBlock; % total number of used cues, here 16
cfg.nTrial      = cfg.nStim * cfg.nRep; % number trials per session, should be 320

% Feedback validity:
cfg.fbProb      = 13/16; % 0.8125

% Condition of each cue:
cfg.valenceVec  = mod((1:cfg.nStim), 2); % 1 = Win, 0 = Avoid
cfg.reqActVec   = mod(ceil((1:cfg.nStim)/2), 2); % 1 = Go, 0 = NoGo
cfg.condVec     = mod((1:cfg.nStim) - 1, cfg.nCond) + 1; % 1 = G2W, 2 = G2A, 3 = NG2W, 4 = NG2A

end % END OF FUNCTION.