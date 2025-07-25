function [aicVec, bicVec, logLikVec] = mgngtus_cbm_compute_loglik(data, allParamMat, modID)

% Compute log-likelihood, AIC, and BIC given data, parameter values, and
% model ID for each subject.
% INPUTS:
% data          = cell with field for data of each subject.
% allParamMat   = nSub x nParam matrix with parameters for each subject
% (untransformed; input to model simulation functions).
% modID         = scalar integer, model ID (used for forward-simulating
% model code to get log-likelihood).
% OUTPUTS:
% aicVec        = nSub x 1 vector of numerics, AIC per subject.
% bicVec        = nSub x 1 vector of numerics, BIC per subject.
% logLikVec     = nSub x 1 vector of numerics, log-likelihood per subject.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Retrieve parameter dimensions:

nSub    = size(allParamMat, 1);
nParam  = size(allParamMat, 2);
if length(data) ~= nSub; error('Number of parameters and data sets don''t match'); end

% ----------------------------------------------------------------------- %
%% Loop over subjects, fit model:

% fprintf('*** Compute log-likelihood of best-fitting parameters ***\n');

% Initialize:
logLikVec       = nan(1, nSub);

% Loop over subjects:
for iSub = 1:nSub
    parameters      = allParamMat(iSub, :); % extract subject parameters
    subj            = data{iSub}; % extract subject data
    logLikVec(iSub) = eval(sprintf('mgngtus_cbm_mod%02d(parameters, subj)', modID));
end

% ----------------------------------------------------------------------- %
%% Compute AIC and BIC:

% fprintf('*** Compute AIC and BIC per subject ***\n');

% Initialize:
aicVec      = nan(size(logLikVec));
bicVec      = nan(size(logLikVec));

% Loop over subjects:
for iSub = 1:nSub % iSub = 1;
    nDataSub        = sum(data{iSub}.response); % count number of data points per subject
    aicVec(iSub)    = -2 * logLikVec(iSub) + 2 * nParam;
    bicVec(iSub)    = -2 * logLikVec(iSub) + log(nDataSub) * nParam;
end % end iSub

end % END OF FUNCTION.