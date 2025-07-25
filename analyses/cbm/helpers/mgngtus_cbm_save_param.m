function mgngtus_cbm_save_param(cfg)

% Save (group-level and) subject level parameter values as .csv files to
% disk.
%
% INPUTS:
% cfg               = structure with the following fields (used in
% mgngtus_cbm_load_model):
% .dataType         = scalar string, stimulation condition ('amyg',
% 'insula', 'sham'; optional).
% .parType          = scalar string, parameter type ('lap', 'hbi';
% optional).
% .suffix           = scalar string, suffix append to file name (optional).
%
% OUTPUTS:
% save matrices of (group-level and) subject level parameter values to
% disk.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Load directories:

dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% Load model output file:

cbm             = mgngtus_cbm_load_model(cfg);

% Extract model outputs:
if isfield(cbm, 'groupParamMat'); groupParamMat = cbm.groupParamMat{:}; end
subParamMat     = cbm.subParamMat;
nParam          = size(subParamMat, 2);

% ----------------------------------------------------------------------- %
%% Transform group and subject parameters appropriately:

subParamMat     = transform_parameters(subParamMat, cfg.modID);

if exist('groupParamMat', 'var')
    groupParamMat   = transform_parameters(groupParamMat, cfg.modID);
end

% ----------------------------------------------------------------------- %
%% Retrieve parameter names:

tmp             = format_tmp.paramNames(cfg.modID);

% ----------------------------------------------------------------------- %
%% Print descriptive statistics to console:

for iParam = 1:nParam
    fprintf('*** M%02d Parameter %s: M = %.02f, SD = %.02f, range = %.2f - %.02f ***\n', ...
        cfg.modID, tmp.paramNames{iParam}, mean(subParamMat(:, iParam)), std(subParamMat(:, iParam)), ...
        min(subParamMat(:, iParam)), max(subParamMat(:, iParam)));
end % end iParam

% ----------------------------------------------------------------------- %
%% Convert to tables, save as .csv files (either LAP or HBI):

% Group-level parameters (for 'hbi' only):
if exist('groupParamMat', 'var')
    fileName        = sprintf('cbm_%s_M%02d_%s_group_parameters.csv', cfg.parType, cfg.modID, cfg.dataType);
    fprintf('*** Save transformed group-level parameters for M%02d fitted with %s under %s ... ***\n', cfg.modID, cfg.parType, fileName);
    fullFileName    = fullfile(dirs.params, fileName);
    % csvwrite(fullFileName, groupParamMat);
    groupParamTable = array2table(groupParamMat, 'VariableNames', tmp.paramNames);
    writetable(groupParamTable, fullFileName);
end

% Subject-level parameters:
if exist('subParamMat', 'var')
    fileName        = sprintf('cbm_%s_M%02d_%s_subject_parameters.csv', cfg.parType, cfg.modID, cfg.dataType);
    fprintf('*** Save transformed subject-level parameters for M%02d fitted with %s under %s ... ***\n', cfg.modID, cfg.parType, fileName);
    fullFileName    = fullfile(dirs.params, fileName);
    % csvwrite(fullFileName, subParamMat);
    subParamTable   = array2table(subParamMat, 'VariableNames', tmp.paramNames);
    writetable(subParamTable, fullFileName);
end

fprintf('... finished saving! :-)\n'); % beep();

end % END OF FUNCTION.