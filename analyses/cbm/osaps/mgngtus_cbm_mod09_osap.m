function [out] = mgngtus_cbm_mod09_osap(parameters, subj)

% One-step ahead predictions (learn given empirical responses and outcomes)
% for:
% Standard Q-learning model with delta learning rule and Go bias and
% Pavlovian response bias and Pavlovian learning bias and single
% perseveration parameter and neutral outcomes reinterpretation parameter.
% Constrain kappa and phi and eta to be positive using log1p_exp transform.
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

% 3) Go bias:
go_bias     = parameters(3);

% 4) Pavlovian response bias:
pi_bias     = parameters(4);

% 5) Instrumental learning bias:
kappa_bias  = log1p_exp(parameters(5));

% Transform:
biaseps     = nan(2, 1);
if epsilon < .5 % If default learning rate below 0.5
  biaseps(2)    = 1/ (1 + exp(-(nd_epsilon - kappa_bias))); % negative bias (Punishment after NoGo): subtract untransformed bias from untransformed epsilon, then transform
  biaseps(1)    = 2*epsilon - biaseps(2);                   % positive bias (Reward after Go): take difference transformed epsilon and transformed negative bias, add to transformed epsilon (= 2*transformed epsilon - transformed negative bias)
 else % If default learning rate above 0.5
  biaseps(1)    = 1 / (1 + exp(-(nd_epsilon + kappa_bias)));% positive bias (Reward after Go): add untransformed bias to untransformed epsilon, then transform
  biaseps(2)    = 2*epsilon - biaseps(1);                   % negative bias (Punishment after NoGo): take difference transformed epsilon and transformed positive bias, substract from transformed epsilon (= 2*transformed epsilon - transformed positive bias)
end

% 6) Neutral outcome reinterpretation parameter:
eta         = log1p_exp(parameters(6)); % eta (transformed to be positive)

% 7) Choice perseveration parameter:
phi_bias    = log1p_exp(parameters(7));

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

% Index of last response per cue:
lastResp    = zeros(nStim, 1);

% Initialize Q-values:
q0          = repmat([1 -1 1 -1]'/2, nStim/4, nResp);
q   	    = q0*rho; % multiply with feedback sensitivity

% ----------------------------------------------------------------------- %
%% Loop over trials:

for t=1:nTrial

    % Read info for the current trial:
    s    = stimuli(t); % stimulus on this trial
    c 	 = response(t); % response on this trial
    r    = outcome(t); % outcome on this trial

    if ~isnan(s)

        v    = q0(s, 1); % valence of cue
        lc   = lastResp(s); % last response to this cue
    
        % Retrieve Q-values of stimulus:
        w   = q(s, :) * valenced(s);
    
        % Add biases:
        w(1) = w(1) + go_bias + valenced(s)*v*pi_bias;
    
        % Add choice perseveration:
        if lc > 0 % if any last response available
             w(lc)  = w(lc) + phi_bias;
        end
    
        % Softmax (turn Q-values into probabilities):
        pt          = exp(w) ./ sum(exp(w));
        
        % Update last response: 
        lastResp(s) = c;
        
        % Select learning rate:
        if c == 1 && r == 1
            eff_epsilon = biaseps(1);
        elseif c == 2 && r == -1
            eff_epsilon = biaseps(2);
        else
            eff_epsilon = epsilon;
        end
    
        % Outcome re-interpretation:
        if r == 0
            eff_r = valenced(s)*v*eta;
        else
            eff_r = r;
        end
        
        % Update:
        delta       = (rho*eff_r) - q(s, c); % prediction error
        q(s, c)     = q(s, c) + (eff_epsilon*delta);
    
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