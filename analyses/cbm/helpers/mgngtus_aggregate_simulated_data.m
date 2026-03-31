function output = mgngtus_aggregate_simulated_data(sim)

% output = mgngtus_aggregate_simulated_data(sim)
%
% Take simulated raw data; aggregate per cue/outcome condition per
% required/actual response per stimulus repetition, aggregate across
% stimulus repetitions, time store in matrices.
%
% INPUTS:
% sim                   = structure with the following fields:
% .p                    = nSub x nIter x nTrial x nResp matrix with
% response probabilities per subject per iteration per trial per response.
% .pGo                  = nSub x nIter x nTrial matrix with response per
% subject per iteration per trial.
% .response             = nSub x nIter x nTrial matrix with response per
% subject per iteration per trial.
% .pStay                = nSub x nIter x nTrial matrix with response
% repetition per subject per iteration per trial.
% .subj                 = nSub x 1 cell with per-subject data.
%
% OUTPUTS:
% output                = structure with several fields with data matrices:
% .pGoSubStimRep        = nSub x nStim x nRep matrix with mean p(Go) per
% subject per time point per stimulus.
% .pCorrectSubStimRep   = nSub x nStim x nRep matrix with mean p(Correct)
%.per time point per stimulus.
% .pGoSubCondRep        = nSub x nCond x nRep matrix with mean p(Go) per
% subject per time point per condition (required action x valence) per
% subject.
% .pCorrectSubCondRep   = nSub x nCond x nRep matrix with mean p(Correct)
% per time point per condition (required action x valence).
% .RTSubCondRep         = nSub x nCond x nRep matrix with mean RT per
% subject per time point per condition (required action x valence) per
% subject.
% .pStayIterValOut      = nSub x nIter x 4 matrix with mean p(stay) per
% subject per iteration per outcome condition (reward, non-reward,
% no-punishment, punishment).
% .pStayIterRespValOut  = nSub x nIter x 8 matrix with mean p(stay) per
% subject per iteration per response (Go, NoGo) x outcome condition
% (reward, non-reward, no-punishment, punishment).
% .pStayIterVal         = nSub x nIter x 2 matrix with mean p(stay) per
% subject per iteration per cue valence (Win, Avoid).
% .pStayIterRespVal     = nSub x nIter x 4 matrix with mean p(stay) per
% subject per iteration per response (Go, NoGo) x cue valence (Win, Avoid).
% .pStayValOut          = nSub x 4 matrix with mean p(stay).per
% outcome condition (reward, non-reward, no-punishment, punishment).
% .pStayRespValOut      = nSub x 8 matrix with mean p(stay).per
% response (Go, NoGo) x outcome condition (reward, non-reward,
% no-punishment, punishment).
% .pStayVal             = nSub x 2 matrix with mean p(stay).per
% cue valence (Win, Avoid).
% .pStayRespVal         = nSub x 4 matrix with mean p(stay).per
% response (Go, NoGo) per cue valence (Win, Avoid).
% .pGoSubCond           = nSub x nStim matrix with mean p(Go) per subject
% per time point per condition (required action x valence).
% .pCorrectSubCond      = nSub x nStim matrix with mean p(Correct) per
% subject per time point per condition (required action x valence).
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

fprintf('*** Aggregate simulated data ... ***\n');

% ----------------------------------------------------------------------- %
%% Retrieve configurations:

cfg                         = mgngtus_cbm_set_config();
nSub                        = size(sim.subj, 2);
nIter                       = size(sim.p, 2);

% ----------------------------------------------------------------------- %
%% Initialize outputs:

output                      = []; % initialize

% Average over iterations (2nd dimension):
output.pGo                  = squeeze(nanmean(sim.pGo, 2));
% output.response             = squeeze(nanmean(sim.response, 2));
% output.stay                 = squeeze(nanmean(sim.stay, 2));

% Initialize:
output.pGoSubStimRep        = nan(nSub, cfg.nStim, cfg.nRep);
output.pCorrectSubStimRep   = nan(nSub, cfg.nStim, cfg.nRep);

output.pGoSubCondRep        = nan(nSub, cfg.nCond, cfg.nRep);
output.pCorrectSubCondRep   = nan(nSub, cfg.nCond, cfg.nRep);

% Intermediate steps for p(Stay) matrices:
output.pStayIterValOut      = nan(nSub, nIter, 4); % initialize
output.pStayIterRespValOut  = nan(nSub, nIter, 8); % initialize
output.pStayIterVal         = nan(nSub, nIter, 2); % initialize
output.pStayIterRespVal     = nan(nSub, nIter, 4); % initialize

% ----------------------------------------------------------------------- %
%% Loop over subjects:

for iSub = 1:nSub % iSub = 1;

    % Extract subject ID:
    subj = sim.subj{iSub};

    % ------------------------------------------------------------------- %
    %% Extract all trials per stimulus:
    
    for iStim = 1:cfg.nStim % iStim = 1;

        stimIdx         = subj.stimuli == iStim; % trials with this stimulus
        nTrialFound     = sum(stimIdx);
        output.pGoSubStimRep(iSub, iStim, 1:nTrialFound)            = output.pGo(iSub, stimIdx);
        if unique(subj.reqAct(stimIdx)) == 1
            output.pCorrectSubStimRep(iSub, iStim, 1:nTrialFound)   = output.pGo(iSub, stimIdx);
        else
            output.pCorrectSubStimRep(iSub, iStim, 1:nTrialFound)   = 1 - output.pGo(iSub, stimIdx);
        end

    end % end iStim

    % ------------------------------------------------------------------- %
    %% Average over stimuli of given condition:

    for iCond = 1:cfg.nCond
        condIdx = cfg.condVec == iCond; % retrieve mapping of stimulus IDs onto condition IDs
        output.pGoSubCondRep(iSub, iCond, :)        = nanmean(output.pGoSubStimRep(iSub, condIdx, :), 2);
        output.pCorrectSubCondRep(iSub, iCond, :)   = nanmean(output.pCorrectSubStimRep(iSub, condIdx, :), 2);
    end % end iCond

    % ------------------------------------------------------------------- % 
    % ------------------------------------------------------------------- % 
    % ------------------------------------------------------------------- % 
    %% Compute p(stay) given outcomes:

    % Loop over iterations:
    for iIter = 1:nIter % iIter = 1;

        % --------------------------------------------------------------- %
        %% Retrieve responses and outcomes (osap: empirical; modSim: simulated):

        if nIter == 1 % if osap
            respVec                 = subj.response; % actual response made by subject
            outVecAbs               = subj.outcome; % actual outcome received by subject
        else % if modSim
            respVec                 = squeeze(sim.response(iSub, iIter, :)); % response sampled in simulation
            outVecAbs               = squeeze(sim.outcome(iSub, iIter, :)); % absolute outcome sampled in simulation
        end

        % --------------------------------------------------------------- %
        %% Count stimulus repetitions (same stimulus order for each iteration):
        
        % Initialize for counting stimulus repetition:
        stimCount   = zeros(cfg.nStim, 1);
        stimRepVec  = nan(length(subj.stimuli), 1);
        
        for iTrial = 1:length(subj.stimuli)
            iStim               = subj.stimuli(iTrial); % retrieve stimulus ID
            stimCount(iStim)    = stimCount(iStim) + 1; % increment count for this stimulus ID
            stimRepVec(iTrial)  = stimCount(iStim); % store stimulus count
        end

        % --------------------------------------------------------------- % 
        %% Determine stay/switch:
        
        stay = nan(cfg.nTrial, 1); %initialize
        for iTrial = 1:length(subj.stimuli) % iTrial = 1;
            
            iStim       = subj.stimuli(iTrial); % retrieve stimulus identifier
            iRep        = stimRepVec(iTrial); % retrieve cumulative number of repetitions of this stimulus
            nextTrial   = find(subj.stimuli == iStim & stimRepVec == (iRep + 1)); % next trial with same stimulus
            
            if ~isempty(nextTrial) & iRep < max(stimRepVec) % if there is still a next trial left
                % Option A: Based on probability of making same response on the next trial
                iResp           = 2 - respVec(iTrial);
                stay(iTrial)    = sim.p(iSub, iIter, nextTrial, iResp); % probability for iTrial response on next trial
                % Option B: Based on repeating the same response as on this trial (only available for modSims):
                % stay(iTrial)    = double(sim.response(iSub, iIter, iTrial) == sim.response(iSub, iIter, nextTrial)); % probably for iTrial response on next trial
            end % end if nost last repetition
            
        end % end iTrial

        % squeeze(sim.stay(iSub, iIter, :)) == stay

        % --------------------------------------------------------------- % 
        %% Recompute interpretation of outcome obtained:

        valVec                  = ismember(subj.stimuli, find(cfg.valenceVec)); % cue valence per trial
        outVecRel               = 1 - outVecAbs; % Avoid cues: 0 --> 1 becomes good, -1 --> 2 becomes bad; mind next line for completion
        outVecRel(valVec == 1)  = outVecRel(valVec == 1) + 1; % Win cues: one up (1 --> 0 --> 1 becomes 1, 0 --> 1 --> 2 becomes 2)
        outVecAll               = outVecRel + 2 * (valVec == 0); % 1-4: reward, no-reward, no-punishment, punishment 
        % tabulate(outVecAll)
        % [valVec outVecAbs outVecRel outVecAll] % inspect

        % --------------------------------------------------------------- % 
        %% Compute pStay per valence x outcome condition:

        for iOut = 1:4 % outcome obtained

            % Find trials with this action and this outcome:
            trlIdx  = outVecAll == iOut;

            % Mean stay in this condition:
            output.pStayIterValOut(iSub, iIter, iOut)  = nanmean(stay(trlIdx));

        end % end iOut

        % --------------------------------------------------------------- % 
        %% Compute pStay per action x valence x outcome condition:
        
        iCond = 0; % initialize condition count

        for iResp = [1 0] % response made
            for iOut = 1:4 % outcome obtained

                % Find trials with this action and this outcome:
                iCond   = iCond + 1; % increment condition count
                trlIdx  = respVec == iResp & outVecAll == iOut;

                % Mean stay in this condition:
                output.pStayIterRespValOut(iSub, iIter, iCond)  = nanmean(stay(trlIdx));

            end % end iResp
        end % end iOut
        % --------------------------------------------------------------- % 
        %% Compute pStay per valence condition:

        % Add valence if needed:
        if ~isfield(subj, 'valence') && isfield(subj, 'stimuli')
            subj.valence = 1 - mod(floor((subj.stimuli - 1) / 2), 2);
        end
        
        iCond = 0; % initialize condition count

        for iVal = [1 0] % outcome obtained

            % Find trials with this action and this outcome:
            iCond   = iCond + 1; % increment condition count
            trlIdx  = subj.valence == iVal;

            % Mean stay in this condition:
            output.pStayIterVal(iSub, iIter, iCond)  = nanmean(stay(trlIdx));

        end % end iVal

        % --------------------------------------------------------------- % 
        %% Compute pStay per response x valence condition:
        
        iCond = 0; % initialize condition count

        for iResp = [1 0] % response made
            for iVal = [1 0] % cue valence

                % Find trials with this action and this outcome:
                iCond   = iCond + 1; % increment condition count
                trlIdx  = respVec == iResp & subj.valence == iVal;

                % Mean stay in this condition:
                output.pStayIterRespVal(iSub, iIter, iCond)  = nanmean(stay(trlIdx));

            end % end iResp
        end % end iOut
    end % end iIter 

end % end iSub

% ----------------------------------------------------------------------- %
%% Aggregate over repetitions:

output.pGoSubCond       = nanmean(output.pGoSubCondRep, 3);
output.pCorrectSubCond  = nanmean(output.pCorrectSubCondRep, 3);

output.pStayValOut      = squeeze(nanmean(output.pStayIterValOut, 2));
output.pStayRespValOut  = squeeze(nanmean(output.pStayIterRespValOut, 2));
output.pStayVal         = squeeze(nanmean(output.pStayIterVal, 2));
output.pStayRespVal     = squeeze(nanmean(output.pStayIterRespVal, 2));

% squeeze(nanmean(pGoSubStimRep(:, 1, :), 1))

fprintf('*** ... finished aggregating simulated data! :-) ***\n');

end % END OF FUNCTION.