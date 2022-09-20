%%% WARNING: this uses cmem and pmem which is not the right mem values.
% those are from the ~20 subjects from the scanner. We have hundreds of Ps
% from the MTurk mem data, so use that.
% you can get this in predict_mturk_mem_with_PCs.m


% want correlation values between item-wise memorability scores and
% item-wise betas (300 items, 300 betas per subject)

% load the memorability scores I calculated using the predict_mem_X_...
% series of files in STAMP_scripts
% need to load the item labels with the memorability score. I'll add that
% to predict_mem_2_enc_cmem.m and predict_mem_3_enc_pmem.m

load mem330_withIDs_cmem.mat
load mem330_withIDs_pmem.mat


% I can trust these because in the code that calculates the memorability
% scores, I found the hit or miss of each item and sorted the item IDs in
% ascending order, so I put the item hit or miss on the same row across
% subjects even though the subjects didn't all see the same items. 
% The strategy was to put a NaN if there was no memorability score for a
% given item for each subject. Then I took the mean skipping the NaNs, so
% we get an average score of hits/total even though not every subject
% contributed a hit or miss to each count.


subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

allMem_cmem = zeros(numel(subjectNum),300);
allMem_pmem = zeros(numel(subjectNum),300);
counter = 1; % count the subjects so I can fill the correct row of the allMem's
for subjects = 1:length(subjectNum) 

    % load the file names for Enc 
    matFiles_dir = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas_smoothed/*.nii'));
    % now I need to be able to access the files
    addpath(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas_smoothed/'));
    
    all_betas_enc = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii'));
   
    % get the item numbers so I know which 300 memorability scores to grab from the
    % lists of 330 memorability scores

    memVal = zeros(numel(all_betas_enc),1);
    for row = 1:numel(all_betas_enc)
    
        % get the item number
        ID_enc = extractBetween(all_betas_enc(row).name,'Item', '_Enc');
        index_cmem = find(memMean_330_withIDs_cmem(:,1)==str2num(ID_enc{1}));
        memVal_cmem(row) = memMean_330_withIDs_cmem(index_cmem,2);
        index_pmem = find(memMean_330_withIDs_pmem(:,1)==str2num(ID_enc{1}));
        memVal_pmem(row) = memMean_330_withIDs_pmem(index_pmem,2);
    end

    allMem_cmem(counter,:) = memVal_cmem;
    allMem_pmem(counter,:) = memVal_pmem;

    counter = counter + 1;
   
    % uncomment if you want to save the memorability values
%     memVal_cmem = memVal_cmem';
%     memVal_pmem = memVal_pmem';
%     save(strcat('memVal_cmem_S',subjectNum{subjects}),'memVal_cmem')
%     save(strcat('memVal_pmem_S',subjectNum{subjects}),'memVal_pmem')

    % now I have the 300 memorability scores for the subject-specific items

end

% ** the groups are:
% S002
% 005, 006, 008, 009, 010, 011
% 013, 014, 015, 016, 018, 019, 021, 022
% 023, 024, 025, 026

