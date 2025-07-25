function output = log1p_exp(input)

% output = log1p_exp(input).
%
% Logarithm of 1+exp(x).
% For large numbers, input = output.
% For small numbers, the output smoothly approaches zero.
% See respective function in stan:
% https://mc-stan.org/docs/2_21/functions-reference/composed-functions.html
%
% INPUTs:
% input         = scalar numeric.
% OUTPUTs:
% output        = scalar numeric.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

output = log(1 + exp(input));

end % END OF FUNCTION.