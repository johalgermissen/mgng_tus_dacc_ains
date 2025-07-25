function [loglik] = mgngtus_cbm_mod04(parameters,subj)

% Standard Q-learning model with delta learning rule and with Go bias and
% instrumental learning bias.
% Constrain kappa to be positive using log1p_exp transform.
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

% 4) Instrumental learning bias:
kappa_bias  = log1p_exp(parameters(4));

% Transform:
biaseps = nan(2, 1);
if epsilon < .5 % If default learning rate below 0.5
  biaseps(2) = 1 / (1 + exp(-(nd_epsilon - kappa_bias))); % negative bias (Punishment after NoGo): subtract untransformed bias from untransformed epsilon, then transform
  biaseps(1) = 2 * epsilon - biaseps(2);                  % positive bias (Reward after Go): take difference transformed epsilon and transformed negative bias, add to transformed epsilon (= 2*transformed epsilon - transformed negative bias)
 else           % If default learning rate above 0.5
  biaseps(1) = 1 / (1 + exp(-(nd_epsilon + kappa_bias))); % positive bias (Reward after Go): add untransformed bias to untransformed epsilon, then transform
  biaseps(2) = 2 * epsilon - biaseps(1);                  % negative bias (Punishment after NoGo): take difference transformed epsilon and transformed positive bias, substract from transformed epsilon (= 2*transformed epsilon - transformed positive bias)
end

% ----------------------------------------------------------------------- %
%% Unpack data:

% Extract data:
stimuli     = subj.stimuli; % 1-16
response    = 2 - subj.response; % 1, 2
outcome     = subj.outcome; % 1,0,-1

% Number of trials:
nTrial      = size(outcome, 1);

% Number of stimuli:
nStim       = length(unique(stimuli));

% Number of responses:
nResp       = length(unique(response));

% To save probability of choice. Currently NaNs, will be filled below:
p           = nan(nTrial, 1);

% Index whether valence of cue detected or not:
valenced    = zeros(nStim, 1);

% Initialize Q-values:
q0          = repmat([1 -1 1 -1]'/2, nStim/4, nResp);
q           = q0*rho; % multiply with feedback sensitivity

% ----------------------------------------------------------------------- %
%% Loop over trials:

for t = 1:nTrial    

    % Read info for the current trial:
    s    = stimuli(t); % stimulus on this trial
    c    = response(t); % response on this trial
    r    = outcome(t); % outcome on this trial

    if ~isnan(s)

        % Retrieve Q-values of stimulus:
        w       = q(s, :) * valenced(s);
        
        % Add biases:
        w(1)    = w(1) + go_bias;
        
        % Softmax (turn Q-values into probabilities):
        pt      = exp(w) ./ sum(exp(w));
        
        % Store probability of the chosen response:
        p(t)    = pt(c);
           
        % Select learning rate:
        if c == 1 && r == 1
            eff_epsilon = biaseps(1);
        elseif c == 2 && r == -1
            eff_epsilon = biaseps(2);
        else
            eff_epsilon = epsilon;
        end
        
        % Update:
        delta    = (rho*r) - q(s, c); % prediction error
        q(s, c)  = q(s, c) + (eff_epsilon*delta);
    
        % Check if valence detected:
        if r ~= 0; valenced(s) = 1; end
    end % if not isnan s
end % end iTrial

% ----------------------------------------------------------------------- %
%% Compute log-likelihood (sum of log-probability of choice data given the parameters):

loglik  = nansum(log(p + eps));

end % END OF FUNCTION.