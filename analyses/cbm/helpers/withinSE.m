function output = withinSE(input)

% output = withinSE(input)
%
% Compute SEs following Cousineau (2005) and Morey (2008) over subjects
% separately for conditions and any other dimensions; correct for number of
% conditions at the end.
% 
% INPUT: 
% input 	= matrix of n (>= 2) dimensions;
%   first dimension assumed to be 'subject';
%   second dimension assumed to be 'condition'.
% For all other dimensions, separate SEs will be given
%
% OUTPUT:
% output    = matrix of n-1 dimensions with corrected standard errors, 
%   first dimension is 'condition';
%   all other dimensions maintained.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Retrieve dimensions:

dim         = size(input);
if length(dim) < 2
    error('Input must be at least two dimensions (subjects x conditions)')
end

nSub        = dim(1);
nCond       = dim(2);
nRest       = prod(dim)/nSub/nCond;

% ----------------------------------------------------------------------- %
%% Reshape into nSub x nCond x nRest:

input       = reshape(input, nSub, nCond, nRest);

% ----------------------------------------------------------------------- %
%% Compute mean per subject (average over conditions, keep rest):

subMean = nanmean(input, 2); % no squeezing

% ----------------------------------------------------------------------- %
%% Compute grand mean per sample (average over subjects, keep rest):

grandMean   = nanmean(subMean, 1); % no squeezing

% ----------------------------------------------------------------------- %
%% Substitute subject mean (per subject over conditions) by grand mean (over subjects and conditions):

output      = input - subMean + grandMean;

% ----------------------------------------------------------------------- %
%% Compute standard-deviation (over subjects):

output      = squeeze(nanstd(output, 1)); % standard deviation across first dimension (subjects)

% ----------------------------------------------------------------------- %
%% Divide by sqrt(N) to get SE:

output      = output / sqrt(nSub);

% ----------------------------------------------------------------------- %
%% Correct for number of conditions (see Morey, 2008):

output      = nCond / (nCond - 1) * output;

end % END OF FUNCTION.