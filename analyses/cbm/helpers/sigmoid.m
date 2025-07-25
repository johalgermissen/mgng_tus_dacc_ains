function output = sigmoid(input)

% output = sigmoid(input)
%
% Sigmoid (inverse logit) transform.
%
% INPUTs:
% input         = scalar numeric.
% OUTPUTs:
% output        = scalar numeric.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

output = exp(input) ./ (1 + exp(input));

end