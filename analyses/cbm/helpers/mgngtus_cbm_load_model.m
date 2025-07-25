function output = mgngtus_cbm_load_model(cfg)

% Transform parameters according to external specification.
%
% INPUTS:
% cfg               = structure with the following fields:
% .dataType         = scalar string, stimulation condition ('amyg',
% 'insula', 'sham'; optional).
% .parType          = scalar string, parameter type ('lap', 'hbi';
% optional).
% .suffix           = scalar string, suffix append to file name (optional).
%
% OUTPUTS:
% output            = structure with the following fields:
% .groupParamMat    = nParam x 1 vector with group-level parameter values
% (for 'hbi' only).
% .errorbar         = nParam x 1 vector with group-level standard errors
% (for 'hbi' only).
% .subParamMat      = nSub x nParam matrix with untransformed subject-level
% parameter values.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

if ~isfield(cfg, 'dataType')
    cfg.dataType        = 'sham'; % set to sham
    fprintf('No cfg.dataType set, use %s by default\n', cfg.dataType);
end

if ~isfield(cfg, 'parType')
    cfg.parType         = 'lap'; % use only for LAP
    fprintf('No cfg.parType set, use %s by default\n', cfg.parType);
end

if ~isfield(cfg, 'suffix')
    cfg.suffix          = '';
end

% ----------------------------------------------------------------------- %
%% Get directories:

dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% Directory to load from:

if strcmp(cfg.parType, 'lap')
    loadDir     = dirs.lap;
elseif strcmp(cfg.parType, 'hbi')
    loadDir     = dirs.hbi;
else
    error('Unknown cfg.parType')
end

% ----------------------------------------------------------------------- %
%% Load model:

% Load:
fileName    = sprintf('%s_%s_mod%02d%s.mat', ...
        cfg.parType, cfg.dataType, cfg.modID, cfg.suffix);
fprintf(' * --------------------------------------------------------- *\n')
fprintf('Load model M%02d fit with %s for %s data: %s\n', ...
    cfg.modID, cfg.parType, cfg.dataType, fileName);
fname       = load(fullfile(loadDir, fileName));
cbm         = fname.cbm;

output      = []; % delete output object

% Extract group-level and subject-level parameters:
if strcmp(cfg.parType, 'hbi')
    output.groupParamMat    = cbm.output.group_mean;
    output.errorbar         = cbm.output.group_hierarchical_errorbar;
    output.subParamMat      = cbm.output.parameters{:};
else
    output.subParamMat      = cbm.output.parameters;
end

% Print detected subjects and parameters to console:
nSub        = size(output.subParamMat, 1);
nParam      = size(output.subParamMat, 2);
fprintf('Found %02d parameters from %02d subjects\n', nParam, nSub);

end % END OF FUNCTION.