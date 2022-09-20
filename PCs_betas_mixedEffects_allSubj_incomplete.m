% *** go to the _complete version of this script


% same as PCs_betas_multReg_allSubj.m, but instead of doing linear models
% in the loop, we just get the average betas per ROI and then do mixed
% effects linear model

% note: this script deals with atlas ROIs.
% for a script that will work with custom ROIs, go to
% PCs_betas_lmer_customROIs.
% (the script that does activity per trial per custom ROI is
% activityPerTrialPerCustomCluster.m)


cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed';
% I'm probably going to need functions from these here
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/function_files')
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/Enc_Rs_Combined_ROIs/ROI'
% Load the PCs
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
load all_score.mat %loads var 'score'
%load all_coeff.mat %loads var 'coeff'
itemIDs_tbl = readtable('itemIDs.xlsx'); % this has all 995 item IDs and labels


%% TMP -- average beta value for voxels in ROI in trial

% 19 subjects
subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

% struct for each subject's score_subset and tmpMean
subjInfo = struct('PCval',[],'tmpVal',[]);

for subjects = 1:length(subjectNum) 

    % load the file names for Enc 
    matFiles_dir = dir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/Enc_Rs_Combined_ROIs/ROI/S',subjectNum{subjects},'/data/*.mat'));
    % access them
    addpath(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/Enc_Rs_Combined_ROIs/ROI/S',subjectNum{subjects},'/data'));
    tmpFiles = cell(numel(matFiles_dir),1); % time series. average activity per ROI
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
    % inside each cell element is a 1x266 double (or a similar number)
    % 1 value per each of the 266ish valid trials


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
    % I could get the same info from design.ID_descrip which is a struct
    % that loads when you load an ROI data file, e.g. QA_cunL.mat. There's
    % one per subj. In this code I load all of them per subj above in
    % matFIles_dir
    
    all_betas_enc = dir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii'));
    
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
    %coeff_subset = zeros(numel(all_betas_enc),994); 
    
    for row = 1:numel(all_betas_enc)
        score_subset(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
        %coeff_subset(row,:) = coeff(indices_inOrder(row),:); % the entire row which is all the PCs
    end
    
    % now I have the PC subsets that match the trials here
    
    % Step 2: Remove any trial that isn't labelled with TT3
    % in the previous step I made indices_TT. If there's a 1 in the row, keep it
    
    for row = 1:numel(indices_TT)
        if indices_TT(row) == 1
            score_subset(row,:) = score_subset(row,:);
            %coeff_subset(row,:) = coeff_subset(row,:);
        else 
            score_subset(row,:) = NaN;
            %coeff_subset(row,:) = NaN;
        end 
    end
    
    % remove the rows with NaN
    score_subset(any(isnan(score_subset), 2), :) = [];
    %coeff_subset(any(isnan(coeff_subset), 2), :) = [];
    % S002 has 266 rows. Other subj slightly diff

    % store the PC and tmp info I need in struct
    subjInfo(subjects).PCval = score_subset;
    subjInfo(subjects).tmpVal = tmpMean;
end

save('subjInfo.mat','subjInfo')

%%%% maybe skip everything below here and switch to R


%% make table to prepare for lmer

%*** I think I just did this manually. This code doesn't really make anything

% subjInfo(1 through 19).tmpVal(1 through 30)
ROI = 1; % 1 through 30
numRows = 0;
for subj = 1:19
    tmpCell = subjInfo(subj).tmpVal(ROI);
    tmpMat = cell2mat(tmpCell);
    numRows = numRows + numel(tmpMat);
end
current_mask_name = matFiles_dir(ROI).name; % still has numbers and extension
nameOnly = current_mask_name(4:end-4); % just the name, no numbers or extension

sz = [numRows 13]; 
varTypes = ["double","string","string","double","double","double","double","double","double","double","double","double","double"];
varNames = ["AvgROI","Subj","ItemID","PC01","PC02","PC03","PC04","PC05","PC06","PC07","PC08","PC09","PC10"];
cunL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


results_tbl(counter,:) = {strcat('S',subjectNum{subjects}),nameOnly,strcat('PC',num2str(PCs_for_enc(PC))),tStat_score,pVal_score};
            counter = counter + 1;


