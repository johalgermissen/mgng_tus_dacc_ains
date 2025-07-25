function priors = mgngtus_get_priors()

% priors = mgngtus_get_priors()
%
% Retrieve cell with names of parameters for each model.
%
% INPUTS:
% none
%
% OUTPUTS:
% priors                = 1 x nMod cell of structures for each model with
% the following fields:
% .mean                 = 1 x nParam vector, mean of normally distributed
% prior for each parameter.
% .variance             = 1 x nParam vector, variance of normally
% distributed prior for each parameter.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Set priors:

fprintf('*** Initialize priors ***\n');

priors{1} = struct('mean', [2 0], 'variance', [3 2]); % note dimension of 'mean'
priors{2} = struct('mean', [2 0 0], 'variance', [3 2 3]); % note dimension of 'mean'
priors{3} = struct('mean', [2 0 0 0], 'variance', [3 2 3 3]); % note dimension of 'mean'
priors{4} = struct('mean', [2 0 0 0], 'variance', [3 2 3 2]); % note dimension of 'mean'
priors{5} = struct('mean', [2 0 0 0 0], 'variance', [3 2 3 3 2]); % note dimension of 'mean'
priors{6} = struct('mean', [2 0 0 0 0 0], 'variance', [3 2 3 3 2 3]); % note dimension of 'mean'
priors{7} = struct('mean', [2 0 0 0 0 0 0], 'variance', [3 2 3 3 2 3 3]); % note dimension of 'mean'
priors{8} = struct('mean', [2 0 0 0 0 1 0], 'variance', [3 2 3 3 2 1 3]); % note dimension of 'mean'
priors{9} = struct('mean', [2 0 0 0 0 1 0], 'variance', [3 2 3 3 2 1 3]); % note dimension of 'mean'

end % END OF FUNCTION.