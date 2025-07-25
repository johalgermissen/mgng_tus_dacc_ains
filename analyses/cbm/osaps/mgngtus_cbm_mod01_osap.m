function [out] = mgngtus_cbm_mod01_osap(parameters, subj)

% One-step ahead predictions (learn given empirical responses and outcomes)
% for:
% Standard Q-learning model with delta learning rule.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% ----------------------------------------------------------------------- %
%% Retrieve parameters:

% 1) Feedback sensitivity:
nd_rho      = parameters(1); % normally-distributed rho
rho         = exp(nd_rho);

% 2) Learning rate:
nd_epsilon  = parameters(2);
epsilon     = 1 / (1 + exp(-nd_epsilon)); % epsilon (transformed to be between zero and one)

% ----------------------------------------------------------------------- %
%% Unpack data:

% Extract task features:
stimuli     = subj.stimuli; % 1-16
response    = 2 - subj.response; % 1, 2, 3
outcome     = subj.outcome; % 1, 0, -1

% Data dimensions:
nTrial      = length(stimuli); % number trials
nStim       = length(unique(stimuli(~isnan(stimuli)))); % number stimuli
nResp       = length(unique(response(~isnan(response)))); % number responses

% To save outcome objects:
p           = nan(nTrial, nResp);
Lik         = nan(nTrial, 1);
PE          = nan(nTrial, 1);
EV          = nan(nTrial, nStim, nResp);

% Index whether valence of cue detected or not:
valenced    = zeros(nStim, 1);

% Initialize Q-values:
q0          = repmat([1 -1 1 -1]'/2, nStim/4, nResp);
q   	    = q0*rho; % multiply with feedback sensitivity

% ----------------------------------------------------------------------- %
%% Loop over trials:

for t = 1:nTrial    

    % Read info for the current trial:
    s   = stimuli(t); % stimulus on this trial
    c 	= response(t); % action on this trial
    r   = outcome(t); % outcome on this trial

    if ~isnan(s)

        % Retrieve Q-values of stimulus:
        w   = q(s, :) * valenced(s);
    
        % Add biases: none
        
        % Softmax (turn Q-values into probabilities):
        pt      = exp(w) ./ sum(exp(w));
           
        % Update Q-values:
        delta   = (rho*r) - q(s, c); % prediction error
        q(s, c) = q(s, c) + (epsilon*delta);    
            
        % Check if valence detected:
        if r ~= 0; valenced(s) = 1; end
        
        % Save objects for output:
        p(t, :)     = pt;
        Lik(t)      = pt(c);
        PE(t)       = delta;
        EV(t, :, :) = q;

    end % if not isnan s
end % end iTrial

% ----------------------------------------------------------------------- %
%% Save as output object:

out.p       = p;
out.lik     = Lik;
out.PE      = PE;
out.EV      = EV;

end % END OF FUNCTION.