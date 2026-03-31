function output = format_paramNames(iMod)

% output = format_paramNames(iMod)
%
% Retrieve (Greek) parameter names for given model, format into LaTeX
% version.
%
% INPUTS:
% iMod              = scalar integer, model index.
%
% OUTPUTS:
% output            = structure with two fields:
% .paramNames       = parameter names for given model.
% .paramNamesLaTeX  = parameter names for given model in LaTeX formatin.g
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% 01) Retrieve parameter names for this model:

% Retrieve all possible parameter names, all possible Greek letters:
tmp                 = mgngtus_cbm_init_paramNames();

% Extract parameter names for this model:
paramNamesPlot      = tmp.paramNamesAll{iMod};
output.paramNames   = paramNamesPlot; % save raw version in output

fprintf('*** Parameter names for M%02d are:***\n*** %s ***\n', iMod, strjoin(string(paramNamesPlot(:)), ', '));

% ----------------------------------------------------------------------- %
%% 02) Loop over parameters, turn Greek letters into LaTeX format, turn
% subscripts into LaTeX scheme:

nParam                  = length(paramNamesPlot);

% Loop over parameters:
for iParam = 1:nParam % iParam = 6;
    addDollar = false; % set to false
    % a) Greek letters:
    if contains(paramNamesPlot(iParam), tmp.greekLetters) % turn Greek letters into LaTeX scheme
        addDollar = 1;  % set to true
        for iLetter = tmp.greekLetters
            if contains(paramNamesPlot(iParam), iLetter)
                oldName = char(iLetter);
            end % end if loop
        end % end for loop
        newName     = ['\', oldName]; % add backslash
        paramNamesPlot{iParam} = strrep(paramNamesPlot{iParam}, oldName, newName);
    end
    % b) Underscores:
    if contains(paramNamesPlot(iParam), '_') % turn subscripts into latex scheme
        addDollar   = 1;  % set to true
        tmp         = split(paramNamesPlot{iParam}, '_');
        paramNamesPlot{iParam} = [tmp{1} '_{' tmp{2} '}']; % add braces
    end
    % c) Add dollar signs:
    if addDollar
        paramNamesPlot{iParam} = ['$', paramNamesPlot{iParam}, '$']; % add dollars
    end
end
fprintf('*** Parameter names for M%02d for plotting are:***\n*** %s ***\n', iMod, strjoin(string(paramNamesPlot(:)), ', '));

output.paramNamesLaTeX  = paramNamesPlot; % save LaTeX version

end % END OF FUNCTION.