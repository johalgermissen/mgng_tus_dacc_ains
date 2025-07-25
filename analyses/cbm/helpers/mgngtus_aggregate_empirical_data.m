function output = mgngtus_aggregate_empirical_data(rawData)

% output = mgngtus_aggregate_empirical_data(rawData)
%
% Take raw data. aggregate per cue/outcome condition per
% required/actual response per stimulus repetition, aggregate across
% stimulus repetitions, time store in matrices.
%
% INPUTS:
% rawData               = nSub x 1 cell with data set.
%
% OUTPUTS:
% output                = structure with several fields with data matrices:
% .pGoSubStimRep        = nSub x nStim x nRep matrix with mean p(Go) per
% subject per time point per stimulus.
% .pCorrectSubStimRep   = nSub x nStim x nRep matrix with mean p(Correct)
%.per time point per stimulus.
% .RTSubStimRep         = nSub x nStim x nRep matrix with mean RT per
% subject per time point per stimulus.
% .pGoSubCondRep        = nSub x nCond x nRep matrix with mean p(Go) per
% subject per time point per condition (required action x valence).
% .pCorrectSubCondRep   = nSub x nCond x nRep matrix with mean p(Correct)
% subject per per time point per condition (required action x valence).
% .RTSubCondRep         = nSub x nCond x nRep matrix with mean RT per
% subject per time point per condition (required action x valence).
% .pStayValOut          = nSub x 4 matrix with mean p(stay) subject per per
% outcome condition (reward, non-reward, no-punishment, punishment).
% .pStayRespValOut      = nSub x 8 matrix with mean p(stay) per subject per
% response (Go, NoGo) x outcome condition (reward, non-reward,
% no-punishment, punishment).
% .pStayVal             = nSub x 2 matrix with mean p(stay) per subject per
% cue valence (Win, Avoid).
% .pStayRespVal         = nSub x 4 matrix with mean p(stay) per subject per
% response (Go, NoGo) per cue valence (Win, Avoid).
% .pGoSubCond           = nSub x nStim matrix with mean p(Go) per subject
% per time point per condition (required action x valence).
% .pCorrectSubCond      = nSub x nStim matrix with mean p(Correct) per
% subject per time point per condition (required action x valence).
% .RTSubCond            = nSub x nStim matrix with mean RTs per subject per
% time point per condition (required action x valence).
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

fprintf('*** Aggregate empirical data ... ***\n');

% ----------------------------------------------------------------------- %
%% Retrieve configurations:

cfg                         = mgngtus_cbm_set_config();
nSub                        = size(rawData, 1);

% ----------------------------------------------------------------------- %
%% Initialize outputs:

output                      = []; % initialize

% Per stimulus:
output.pGoSubStimRep        = nan(nSub, cfg.nStim, cfg.nRep);
output.pCorrectSubStimRep   = nan(nSub, cfg.nStim, cfg.nRep);
output.RTSubStimRep         = nan(nSub, cfg.nStim, cfg.nRep);

% Per condition:
output.pGoSubCondRep        = nan(nSub, cfg.nCond, cfg.nRep);
output.pCorrectSubCondRep   = nan(nSub, cfg.nCond, cfg.nRep);
output.RTSubCondRep         = nan(nSub, cfg.nCond, cfg.nRep);

% p(Stay):
output.pStayValOut          = nan(nSub, 4);
output.pStayRespValOut      = nan(nSub, 8);
output.pStayVal             = nan(nSub, 2);
output.pStayRespVal         = nan(nSub, 4);

% ----------------------------------------------------------------------- %
%% Loop over subjects:

for iSub = 1:nSub % iSub = 1;

    % Extract subject subja:
    subj = rawData{iSub};

    % ------------------------------------------------------------------- %
    %% Extract all trials per stimulus:
    
    for iStim = 1:cfg.nStim % iStim = 1;

        stimIdx = find(subj.stimuli == iStim); % trials with this stimulus
        nRepFound = length(stimIdx); % number of stimulus repetitions
        if nRepFound > cfg.nRep; stimIdx = stimIdx(1:cfg.nRep); nRepFound = length(stimIdx); end % shorten if too long
        output.pGoSubStimRep(iSub, iStim, 1:nRepFound)        = subj.response(stimIdx); % store responses for this stimulus
        output.pCorrectSubStimRep(iSub, iStim, 1:nRepFound)   = subj.ACC(stimIdx); % store accuracy for this stimulus
        output.RTSubStimRep(iSub, iStim, 1:nRepFound)         = subj.RT(stimIdx); % store RTs for this stimulus

    end % end iStim

    % ------------------------------------------------------------------- %
    %% Average over stimuli of given condition:

    for iCond = 1:cfg.nCond
        condIdx = cfg.condVec == iCond; % retrieve mapping of stimulus IDs onto condition IDs
        output.pGoSubCondRep(iSub, iCond, :)        = nanmean(output.pGoSubStimRep(iSub, condIdx, :), 2); % average p(Go) for this condition
        output.pCorrectSubCondRep(iSub, iCond, :)   = nanmean(output.pCorrectSubStimRep(iSub, condIdx, :), 2); % average p(Correct) for this condition
        output.RTSubCondRep(iSub, iCond, :)         = nanmean(output.RTSubStimRep(iSub, condIdx, :), 2); % average RTs for this condition
    end % end iCond

    % ------------------------------------------------------------------- %
    %% Compute stay/switch.

    subj.stay = nan(cfg.nTrial, 1); % initialize

    % Loop over trials:
    for iTrial = 1:length(subj.stimuli) % iTrial = 1;
            
        iStim       = subj.stimuli(iTrial); % retrieve stimulus ID
        iRep        = subj.stimRep(iTrial); % retrieve cumulative number of repetitions of this stimulus
        nextTrial   = find(subj.stimuli == iStim & subj.stimRep == (iRep + 1)); % next trial with same stimulus
        
        if ~isempty(nextTrial) & iRep < cfg.nRep % if there is still a next trial left
            subj.stay(iTrial) = double(subj.response(iTrial) == subj.response(nextTrial)); % decide whether exact response (resp) repeated or not
        end
    end

    % ------------------------------------------------------------------- %
    %% Recompute interpretation of outcome obtained:

    subj.fb.abs                      = subj.outcome; % absolute outcome: +1, 0, -1
    subj.fb.rel                      = 1 - subj.outcome; % Avoid cues: 0-->1 becomes good, -1-->2 becomes bad; mind next line for completion
    subj.fb.rel(subj.valence == 1)   = subj.fb.rel(subj.valence == 1) + 1; % Win cues: one up : one up (1-->0-->1 becomes 1, 0-->1-->2 becomes 2)
    subj.fb.all                      = subj.fb.rel + 2 * (subj.valence == 0); % 1-4: reward, no-reward, no-punishment, punishment
    % [subj.valence subj.fb.abs subj.fb.rel subj.fb.all] % inspect

    % ------------------------------------------------------------------- %
    %% Compute pStay per valence condition:

    iCond = 0; % initialize

    for iVal = [1 0]
        iCond = iCond + 1; % increment
        idx                                 = subj.valence == iVal;
        output.pStayVal(iSub, iCond)        = nanmean(subj.stay(idx));
    end % end iOut

    % ------------------------------------------------------------------- %
    %% Compute pStay per response x valence condition:

    iCond = 0; % initialize

    for iResp = [1 0]
        for iVal = [1 0]
            iCond = iCond + 1; % increment
            idx                             = subj.response == iResp & subj.valence == iVal;
            output.pStayRespVal(iSub, iCond)= nanmean(subj.stay(idx));
        end % end iOut
    end

    % ------------------------------------------------------------------- %
    %% Compute pStay per valence x outcome condition:

    for iOut = 1:4
        idx                                 = subj.fb.all == iOut;
        output.pStayValOut(iSub, iOut)      = nanmean(subj.stay(idx));
    end % end iOut

    % ------------------------------------------------------------------- %
    %% Compute pStay per action x valence x outcome condition:

    iCond = 0; % initialize
    
    for iResp = [1 0]
        for iOut = 1:4
            iCond = iCond + 1; % increment
            idx                                 = subj.response == iResp & subj.fb.all == iOut;
            output.pStayRespValOut(iSub, iCond) = nanmean(subj.stay(idx));
        end % end iOut
    end % end iVal

end % end iSub

% ----------------------------------------------------------------------- %
%% Aggregate over repetitions:

output.pGoSubCond       = nanmean(output.pGoSubCondRep, 3);
output.pCorrectSubCond  = nanmean(output.pCorrectSubCondRep, 3);
output.RTSubCond        = nanmean(output.RTSubCondRep, 3);

% squeeze(nanmean(pGoSubStimRep(:, 1, :), 1))

fprintf('*** ... finished aggregating empirical data! :-) ***\n');

end % END OF FUNCTION.