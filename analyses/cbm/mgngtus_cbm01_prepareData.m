% mgngtus_cbm01_prepareData.m
% 
% Execute this script to prepare the behavioral data for an appropriate
% format for the CBM toolbox.
% Mind adjusting the root directory.
%
% INPUTS:
% none.
%
% OUTPUTS:
% Saves all .csv files as respective .mat files to indicated directory.
%
% MGNG TUS STUDY, PLYMOUTH.
% Copyright (C) Johannes Algermissen, University of Oxford, Oxford, UK, 2024-2025.
% Should work in MATLAB 2023b.

% clear all; close all; clc

% ----------------------------------------------------------------------- %
%% Initialize directories:

dirs            = mgngtus_cbm_set_dirs();

% ----------------------------------------------------------------------- %
%% Set configuration parameters:

cfg             = mgngtus_cbm_set_config();

% ----------------------------------------------------------------------- %
%% Retrieve available files (different sonication conditions):

% Extract subject numbers:
fileList    = dir(fullfile(dirs.input, '*mgngtus*.csv')); % extract all file names within directory
fileList    = {fileList.name}; % keep only column "name"

nFile       = numel(fileList); % number of data sets

% ----------------------------------------------------------------------- %
%% Loop over all files data sets, bring into cell structure:

for iFile = 1:nFile % iFile = 1;

    % Read in data:
    inFileName      = fileList{iFile};
    fprintf('*** ================================================ ***\n');
    fprintf('*** Read file %s ... ***\n', inFileName);
    fullFileName    = fullfile(dirs.input, inFileName);
    inputTable      = readtable(fullFileName, 'TreatAsMissing', 'NA');
    % inputMat        = inputTable{:, :}; % to matrix (deletes NAs)

    % Detect subjects:
    nSub = length(unique(inputTable.subject_n));
    fprintf('*** Found data from %02d subjects ***\n', nSub);

    % Initialize per-subject file:
    data            = cell(nSub, 1);

    fprintf('*** Recode data into cell ... ***\n');
    for iSub = 1:nSub % iSub = 1;

        % Detect rows for this subject:
        rowIdx      = find(inputTable.subject_n == iSub);

        % Copy over data into cell:
        data{iSub}.block        = inputTable.block_n(rowIdx);
        data{iSub}.stimuli      = inputTable.stimulus_n(rowIdx);
        data{iSub}.stimRep      = inputTable.stimRep_n(rowIdx);
        data{iSub}.reqAct       = inputTable.reqAction_n(rowIdx);
        data{iSub}.valence      = inputTable.valence_n(rowIdx);
        data{iSub}.response     = inputTable.response_n(rowIdx);
        data{iSub}.ACC          = inputTable.ACC_n(rowIdx);
        data{iSub}.RT           = inputTable.RT_n(rowIdx);
        data{iSub}.validity     = inputTable.validity_n(rowIdx);
        data{iSub}.outcome      = inputTable.outcome_n(rowIdx);
        data{iSub}.sonication   = inputTable.sonication_n(rowIdx);

    end % end iSub

    outFileName     = strrep(inFileName, '.csv', '.mat');
    fprintf('*** Save data as %s ... *** \n', outFileName);
    fullOutFileName = fullfile(dirs.input, outFileName);
    save(fullOutFileName, 'data');
    fprintf('*** Finished processing %s  :-) *** \n', inFileName);
   
end % end iFile

% END OF FILE.