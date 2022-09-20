% go to PCs_betas_multReg_allSubj. for the same code within a for loop


% want to take the PCs and betas and do multiple regressions
% for that I need to use tmp. 
% for this variable, cols are trials and rows are the voxels in a given ROI
% You want to take an average across rows so you get one beta per trial in
% an ROI
% If you go to the design struct -> ID-description, the file names are sorted by trial.
% /Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/Rs_ROIs
% /Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/Rs_ROIs/ROI/S002/data

% this folder has my betas, both smoothed (8 8 8) and non-smoothed
cd '/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed';
% I'm probably going to need functions from these here
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/function_files')


%   read in betas 
%   read in PCs
%   run regression
%   get the R-sqr val

% get beta filenames
%% TMP -- average beta value for voxels in ROI in trial

subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023'};

%for subjects = 1:length(subjectNum) 

%end

subjects = 1; %use this to write and debug and then put everything into the loop above

% load the file names for Enc 
matFiles_dir = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/Rs_ROIs/ROI/S',subjectNum{subjects},'/data/*.mat'));
% now I need to be able to access the files
addpath(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/Rs_ROIs/ROI/S',subjectNum{subjects},'/data'));
tmpFiles = cell(numel(matFiles_dir),1);
for file = 1:numel(matFiles_dir)

    % loads all vars in the mat file
    load(matFiles_dir(file).name,'-mat');
    tmpFiles{file} = tmp;

end 

% at this point tmpFiles has all the tmp files. 
% cols are trials and rows are voxels in the ROI.
% take the average to get one value per col
tmpMean = cell(1,numel(tmpFiles));
for row = 1:numel(tmpFiles)

    tmpMean{row} = mean(tmpFiles{row},1);

end

% now tmpMean has 246 ROIs.
% inside each cell element is a 1x266 double. 1 value per each of the 266
% trials

%% PCs subset to match tmpMean

% get subset of PC values that apply to the enc trials
% there's a subset of the 300 trials here.
% The Ps did a covert naming task. When they incorrectly named the trial
% that trial was discarded. Meaning, when the letter matched the first
% letter of the object name but the participant still pressed the button,
% it was a mismatch (false alarm)

% Step 1: Cut PCs down to the 300 used in Encoding

itemIDs_tbl = readtable('itemIDs.xlsx'); % this has all 995 item IDs and labels
% also score and coeff have 995 rows. 
% I have to grab the score and coeff vals that correspond to the items that
% are used

all_betas_enc = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii'));

IDs_enc = cell(numel(all_betas_enc),1);
indices_TT = zeros(numel(all_betas_enc),1); % 1 for TT3 and 0 for anything else
for row = 1:numel(all_betas_enc)

    % get the item number
    IDs_enc{row} = extractBetween(all_betas_enc(row).name,'Item', '_Enc');

    % is it TT3 (and should stay) or is it TT4, etc (and should go?)
    TT_num_cell = extractBetween(all_betas_enc(row).name,'EncTT', '_');
    TT_num = cell2mat(TT_num_cell);
    if TT_num == '3'
        indices_TT(row) = 1;
    end
end

% now I have the ID numbers that are used for the encoding trials of this
% subject
% I have to find the PC val that is on the row where that ID number is in
% itemIDs_tbl. So, I want the row number

indices_inOrder = zeros(numel(all_betas_enc),1);
for idNumber = 1:numel(all_betas_enc)
    % IDs_enc is cell array of cells, so I have to peel them out
    % then convert the char you get out to a num to match the table items
    index = find(itemIDs_tbl{:,2}==str2num(cell2mat(IDs_enc{idNumber}))); %find the four-digit ID num in the second col of the table
    indices_inOrder(idNumber) = index;
end


score_subset = zeros(numel(all_betas_enc),994); 
coeff_subset = zeros(numel(all_betas_enc),994); 

for row = 1:numel(all_betas_enc)
    score_subset(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    coeff_subset(row,:) = coeff(indices_inOrder(row),:); % the entire row which is all the PCs
end

% now I have the PC subsets that match the trials here

% Step 2: Remove any trial that isn't labelled with TT3
% in the previous step I made indices_TT. If there's a 1 in the row, keep it

for row = 1:numel(indices_TT)
    if indices_TT(row) == 1
        score_subset(row,:) = score_subset(row,:);
        coeff_subset(row,:) = coeff_subset(row,:);
    else 
        score_subset(row,:) = NaN;
        coeff_subset(row,:) = NaN;
    end 
end

% remove the rows with NaN
score_subset(any(isnan(score_subset), 2), :) = [];
coeff_subset(any(isnan(coeff_subset), 2), :) = [];
% now they have 266 rows, which is correct for S002


%% Regression between PCs and tmpFiles (which are the betas)

% tmpMean is 1x246 cell for 246 ROIS
% tmpMean{col} has 1x266 double, which are the single average beta vals for
% each ofthe 266 trials

% regression per ROI. Let's do the first one
% [b,bint,r] = regress(y,X);
% y is the betas and X is the PCs

[b,bint,r] = regress(tmpMean{1}',score_subset(:,1));

%% Do ret as well later
% all_betas_ret = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S',subjectNum{subjects},'/betas/*.nii');