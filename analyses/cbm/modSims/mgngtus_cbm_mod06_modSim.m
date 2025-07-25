function [out] = mgngtus_cbm_mod06_modSim(parameters, subj)

% Model simulations (sample new responses and outcomes) for:
% Standard Q-learning model with delta learning rule and Go bias and
% Pavlovian response bias and Pavlovian learning bias and single
% perseveration parameter.
% Constrain kappa and phi to be positive using log1p_exp transform.
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

% 6) Choice perseveration parameter:
phi_bias    = log1p_exp(parameters(6));

% ----------------------------------------------------------------------- %
%% Unpack data:

% Extract task features:
stimuli     = subj.stimuli; % 1-16
reqactions  = 2 - subj.reqAct; % 1-2
feedback    = subj.validity; % 0-1

% Data dimensions:
nTrial      = length(stimuli); % number trials
nStim       = length(unique(stimuli(~isnan(stimuli)))); % number stimuli
nResp       = length(unique(reqactions(~isnan(reqactions)))); % number responses

% To save outcome objects:
p           = nan(nTrial, nResp);
Lik         = nan(nTrial, 1);
PE          = nan(nTrial, 1);
EV          = nan(nTrial, nStim, nResp);
Update      = nan(nTrial, 1);

% Specific for model simulations (because probabilistic):
response    = nan(nTrial, 1);
outcome     = nan(nTrial, 1);
stay        = nan(nTrial, 1);

% For win-stay lose shift: count cumulative number presentations this
% stimulus:
cCount      = zeros(nTrial, 1);
cRep        = nan(nTrial, 1);

% Index whether valence of cue detected or not:
valenced    = zeros(nStim, 1);

% Index of last action per cue:
lastAct     = zeros(nStim, 1);

% Initialize Q-values:
q0          = repmat([1 -1 1 -1]'/2, nStim/4, nResp);
q   	    = q0 * rho; % multiply with feedback sensitivity

% ----------------------------------------------------------------------- %
%% Loop over trials:

for t = 1:nTrial    

    % Read info for the current trial:
    s   = stimuli(t); % stimulus on this trial
    ra  = reqactions(t); % required action on this trial
    f   = feedback(t); % feedback validity on this trial

    if ~isnan(s)

        v   	    = q0(s, 1); % valence of cue on this trial
        la          = lastAct(s); % last action to this cue
    
        % Cumulative number presentations this stimulus:
        cCount(s)   = cCount(s) + 1; % increment count for this stimulus ID
        cRep(t)     = cCount(s); % store stimulus count
        
        % Retrieve Q-values of stimulus:
        w           = q(s, :) * valenced(s);
        
        % Add biases:
        w(1)        = w(1) + go_bias + valenced(s)*v*pi_bias;
        
        % Add choice perseveration:
        if la > 0 % if any last action available
             w(la)  = w(la) + phi_bias;
        end
        
        % Softmax (turn Q-values into probabilities):
        pt          = exp(w) ./ sum(exp(w));
        
        % Choose actions:
        c           = randsample(nResp, 1, true, pt);
        
        % Update last action: 
        lastAct(s)  = c;
    
        % Determine outcome:
        if((c == ra && f == 1 && v > 0) || (c ~= ra && f == 0 && v > 0)); r = 1; end
        if((c == ra && f == 1 && v < 0) || (c ~= ra && f == 0 && v < 0)); r = 0; end
        if((c == ra && f == 0 && v > 0) || (c ~= ra && f == 1 && v > 0)); r = 0; end
        if((c == ra && f == 0 && v < 0) || (c ~= ra && f == 1 && v < 0)); r = -1; end
    
        % Determine learning rate:
        if c == 1 && r == 1
            eff_epsilon = biaseps(1);
        elseif c == 2 && r == -1
            eff_epsilon = biaseps(2);
        else
            eff_epsilon = epsilon;
        end
        
        % Update Q-values:
        delta    	= (rho * r) - q(s, c); % prediction error
        q(s, c)   	= q(s, c) + (eff_epsilon * delta);    
    
        % Check if valence detected:
        if r ~= 0; valenced(s) = 1; end
        
        % Save objects for output:
        p(t,:)          = pt;
        Lik(t)          = pt(c);
        response(t)     = c;
        outcome(t)      = r;
        PE(t)           = delta;
        Update(t)       = eff_epsilon*delta; 
        EV(t,:,:)       = q;

    end % if not isnan s
end % end iTrial

% ----------------------------------------------------------------------- %
%% Win stay-lose shift:

for t = 1:nTrial % iTrial = 1;    
    s           = stimuli(t); % retrieve stimulus identifier
    repIdx      = cRep(t); % retrieve cumulative number of appearance of this stimulus
    nextTrlIdx  = stimuli == s & cRep == (repIdx + 1); % next trial with this stimulus
    if repIdx < max(cRep) % if there is still a "next trial" left
        stay(t) = double(response(t) == response(nextTrlIdx)); % decide whether exact response (resp) repeated or not
    end
end

% ----------------------------------------------------------------------- %
%% Save as output object:

out.p           = p;
out.lik         = Lik;
out.PE          = PE;
out.EV          = EV;

out.response    = 2 - response; % convert back to 1 = Go, 0 = NoGo.
out.outcome     = outcome;
out.stay        = stay;

end % END OF FUNCTION.