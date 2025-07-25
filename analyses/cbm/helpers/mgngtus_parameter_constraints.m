function outputMat = mgngtus_parameter_constraints(inputMat, modID)

% Put constraints on parameters for model recovery.
% Given an nSub x nParam input matrix inputMat, only return those rows
% that fullfile all criteria.
%
% INPUTS:
% inputMat          = nSub x nParam matrix of numerical values.
% modID             = scalar integer, model index.
%
% OUTPUTS:
% outputMat         = nSub x nParam matrix with onlys those rows/subjects
% retained that fullfile all criteria.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Retrieve parameter names:

tmp                         = format_tmp.paramNames(modID);

% ----------------------------------------------------------------------- %
%% Filter rows by constraints:

% Initialize:
validMat  = ones(size(inputMat)); % initialise all to valid (1)

% Loop over parameters:
for iParam = 1:size(inputMat, 2) % iParam = 1;

    % Feedback sensitivity rho:
    if strcmp(tmp.paramNames{iParam}, 'rho')
        % plot(inputMat(:, 1))
        % histfit(inputMat(:, 1))
        % plot(exp(inputMat(:, 1)))
        % histfit(exp(inputMat(:, 1)))
        % x = 400; log(x) % 6 % exp(6) % accept maximum effective rho of 400 (otherwise infinite Q-values)
        validMat(:, iParam) = inputMat(:, iParam) < 6; % must be < 6 
    end

    % Learning rate rho:
    if strcmp(tmp.paramNames{iParam}, 'epsilon')
        % plot(inputMat(:, 2))
        % histfit(inputMat(:, 2))
        % plot(1 ./ (1 + exp(-1*inputMat(:, 2))))
        % histfit(1 ./ (1 + exp(-1*inputMat(:, 2))))
        % x = 0.05; log(x / (1 - x)) % 1 / (1 + exp(-(-3))) % accept minimum effective epsilon of 0.05 (otherwise no learning)
        validMat(:, iParam) = inputMat(:, iParam) > -3; % must be > -3 
    end

    % Go bias b:
    if strcmp(tmp.paramNames{iParam}, 'b')
        % plot(inputMat(:, 3))
        % histfit(inputMat(:, 3))
        % histfit(abs(inputMat(:, 3)))
        % prctile(abs(inputMat(:, 3)), 10) % check 10th percentile; crop lowest 10% of absolute bias size
        % mean(abs(inputMat(:, 3)) > 0.10) % confirm
        validMat(:, iParam) = abs(inputMat(:, iParam)) > 0.10; % must be > 0.10 
    end

    % Pavlovian response bias pi:
    if strcmp(tmp.paramNames{iParam}, 'pi')
        % plot(inputMat(:, 4))
        % histfit(inputMat(:, 4))
        % histfit(abs(inputMat(:, 4)))
        % prctile(abs(inputMat(:, 4)), 10) % check 10th percentile; crop lowest 10% of absolute bias size
        % mean(abs(inputMat(:, 4)) > 0.23) % confirm
        validMat(:, iParam) = abs(inputMat(:, iParam)) > 0.23; % must be > 0.23
    end

    % Learning bias kappa:
    if strcmp(tmp.paramNames{iParam}, 'kappa')
        % plot(inputMat(:, 5))
        % histfit(inputMat(:, 5))
        % prctile(inputMat(:, 5), 10) % check 10th percentile; crop lowest 10% of bias size
        % mean(inputMat(:, 5) > -0.95) % confirm
        % nd_epsilon = -2; kappa_bias = log1p_exp(-0.95);
        % biaseps(2)  = 1 / (1 + exp(-(nd_epsilon - kappa_bias))); biaseps(2)   % negative bias 
        % epsilon     = 1 / (1 + exp(-nd_epsilon))                              % standard learning rate
        % biaseps(1)  = 2 * epsilon - biaseps(2); biaseps(1)                    % positive bias
        validMat(:, iParam) = inputMat(:, iParam) > -0.95; % must be > -0.95
    end

    % Intercept persistence phi_Int:
    if strcmp(tmp.paramNames{iParam}, 'phi_Int')
        % plot(inputMat(:, 6))
        % histfit(inputMat(:, 6))
        % prctile(inputMat(:, 6), 10) % check 10th percentile; crop lowest 10% of absolute bias size
        % mean(inputMat(:, 6) > -1.10) % confirm
        % plot(log1p_exp(inputMat(:, 6)))
        % histfit(log1p_exp(inputMat(:, 6)))
        % log1p_exp(-1.10)
        validMat(:, iParam) = inputMat(:, iParam) > -1.10; % must be > -1.10
    end

    % Persistence difference Win - Avoid phi_Dif:
    if strcmp(tmp.paramNames{iParam}, 'phi_Dif')
        % plot(inputMat(:, 7))
        % histfit(inputMat(:, 7))
        % prctile(abs(inputMat(:, 7)), 10) % check 10th percentile; crop lowest 10% of absolute bias size
        % mean(abs(inputMat(:, 7)) > 0.17) % confirm
        validMat(:, iParam) = abs(inputMat(:, iParam)) > 0.17; % must be > 0.17
    end

end

% Count number of valid parameter combinations:
validIdx    = all(validMat, 2);
fprintf('*** Found %d valid parameter combinations ***\n', sum(validIdx));
outputMat   = inputMat(validIdx, :);

end % END OF FUNCTION.