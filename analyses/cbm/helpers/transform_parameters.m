function outputMat = transform_parameters(inputMat, iMod)

% Transform parameters according to external specification.
%
% INPUTS:
% inputMat          = nSub x nParam matrix of untransformed parameter
% values.
% iMod              = scalar integer, model index.
%
% OUTPUTS:
% outputMat         = nSub x nParam matrix of transformed parameter values.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
% Retrieve transformations and parameter names:

% Retrieve names of model parameters:
tmp             = format_paramNames(iMod);
paramNamesPlot  = tmp.paramNames;

% Retrieve transformations given parameter names:
tmp             = mgngtus_cbm_init_paramNames();
transfNamesAll  = tmp.transfNamesAll; % extract

% ----------------------------------------------------------------------- %
%% Transform:

outputMat      = nan(size(inputMat)); % initialize output object

for iParam = 1:size(inputMat, 2) % iParam = 4;

    paramName   = paramNamesPlot{iParam}; % extract name of parameter
    transfName  = transfNamesAll(transfNamesAll(:, 1) == paramName, 2); % retrieve respective transform
    fprintf('*** Parameter %02d is %s -- transform with %s transform ***\n', iParam, paramName, transfName);

    % Evaluate transformation (string):
    outputMat(:, iParam) = eval(sprintf('%s(input(:, iParam))', transfName));

end % END OF FUNCTION.