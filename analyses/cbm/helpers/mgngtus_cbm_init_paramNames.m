function output = mgngtus_cbm_init_paramNames()

% output = mgngtus_cbm_init_paramNames()
%
% Retrieve cell with names of parameters for each model.
%
% INPUTS:
% none
%
% OUTPUTS:
% output                = cell with the following fields:
% .paramNamesAll        = cell with names of parameters per model.
% .transfNamesAll       = string array with transformation per parameter.
% .greekLetters         = string array of strings that count as greek
% letters.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Names of parameters in models (for plotting):

fprintf('*** Initialize parameter names ... ***\n')

paramNamesAll   = {{'rho', 'epsilon'}, ... % M01
                   {'rho', 'epsilon', 'b'}, ... % M02
                   {'rho', 'epsilon', 'b', 'pi'}, ... % M03
                   {'rho', 'epsilon', 'b', 'kappa'},... % M04
                   {'rho', 'epsilon', 'b', 'pi', 'kappa'}, ... % M05
                   {'rho', 'epsilon', 'b', 'pi', 'kappa', 'phi'}, ... % M06
                   {'rho', 'epsilon', 'b', 'pi', 'kappa', 'phi_Int', 'phi_Dif'}, ... % M07
                   {'rho', 'epsilon', 'b', 'pi', 'kappa', 'eta', 'phi'}, ... % M08
                   {'rho', 'epsilon', 'b', 'pi', 'kappa', 'eta', 'phi'}, ... % M09
                   }; % parameter names per model

% ----------------------------------------------------------------------- %
%% Transformation:

fprintf('*** Initialize transformations for each parameter ... ***\n')

% Transform of each parameter given name (2nd column for modID < 10; 3rd column for modID > 10):
transfNamesAll  = ["rho" "exp"; ...
                   "epsilon"  "sigmoid"; ...
                   "b" "none";
                   "phi" "log1p_exp"; ...
                   "kappa" "log1p_exp"; ...
                   "phi_Int" "log1p_exp"; ...
                   "phi_Dif" "none"; ...
                   "eta" "log1p_exp"]; % transforms

% ----------------------------------------------------------------------- %
%% Greek letters:

fprintf('*** Initialize greek letters ... ***\n');

greekLetters    = ["rho" "epsilon" "pi" "kappa" "phi" "eta"]; % tbc

% ----------------------------------------------------------------------- %
%% Store in output:

output.paramNamesAll    = paramNamesAll;
output.transfNamesAll   = transfNamesAll;
output.greekLetters     = greekLetters;

end % END OF FUNCTION.