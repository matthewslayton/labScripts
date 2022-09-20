% this is built from PCs_betas_multipleRegression.n
% mult_reg_betas.m was an early failed attempt
% Rs_for_ROIs_Script.m makes R and tmp files. You can load the betas and
% the masks

% also check out PCs_betas_mixedEffects_allSubj.m
% it's the same as this but doesn't do the linear model in the loop


% THIS IS FOR ENC. Can run PCs relevant to CMEM and PMEM

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed';
% I'm probably going to need functions from these here
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/function_files')
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/Enc_Rs_Combined_ROIs/ROI'
% Load the PCs
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
load all_score.mat %loads var 'score'
%load all_coeff.mat %loads var 'coeff'

%% TMP -- average beta value for voxels in ROI in trial

% 19 subjects
subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

% create table to store results
%sz = [1230*numel(subjectNum) 5]; %246 masks * 5 PCs of interest = 1230
sz = [150*numel(subjectNum) 5]; % 30 masks * 5 PCs of interest = 150
%varTypes = ["string","string","string","double","double","double","double"];
%varNames = ["Subject","ROI","PC","tStat-score","pVal-score","tStat-coeff","pVal-coeff"];
varTypes = ["string","string","string","double","double"];
varNames = ["Subject","ROI","PC","tStat-score","pVal-score"];
results_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
counter = 1; % use this to count rows in the results table

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
    % now they have 266 rows, which is correct for S002. Other subj
    % slightly diff

%% Regression between PCs and tmpFiles (which are the betas)

    % tmpMean is 1x246 cell for 246 ROIS
    % tmpMean{col} has 1x266 double, which are the single average beta vals for
    % each ofthe 266 trials
    
    % regression per ROI. Let's do the first one
    %PCs_for_enc = [2 4 6 7 12]; %cmem
    %PCs_for_enc = [1 5 6 11 18]; %pmem
    PCs_for_enc = [1 2 3 4 5 6 7 8 9 10];
    for PC = 1:length(PCs_for_enc)
        for ROI = 1:numel(tmpMean)
        
            mdl = fitlm(tmpMean{ROI}',score_subset(:,PCs_for_enc(PC)));
            %mdl2 = fitlm(tmpMean{ROI}',coeff_subset(:,PCs_for_enc(PC)));
            % save outputs (tstat) a table, start loop over
            tempTable_score = mdl.Coefficients; % gives a 2x4 table
            tStat_score = tempTable_score{2,'tStat'};
            pVal_score = tempTable_score{2,'pValue'};
            %tempTable_coeff = mdl2.Coefficients;
            %tStat_coeff = tempTable_coeff{2,'tStat'};
            %pVal_coeff = tempTable_coeff{2,'pValue'};

            current_mask_name = matFiles_dir(ROI).name; % still has numbers and extension
            nameOnly = current_mask_name(1:end-4); % just the name, no numbers or extension
            
           % these are the outputs. I want to save them
            %results_tbl(counter,:) = {strcat('S',subjectNum{subjects}),nameOnly,strcat('PC',num2str(PCs_for_enc(PC))),tStat_score,pVal_score,tStat_coeff,pVal_coeff};
            results_tbl(counter,:) = {strcat('S',subjectNum{subjects}),nameOnly,strcat('PC',num2str(PCs_for_enc(PC))),tStat_score,pVal_score};
            counter = counter + 1;
        end
    end



    % once I find a few interesting ROIs, look at change in r^2 by adding PCs one at a time
    % next ask if the outputs are significant across people
    % or, better yet, skip fitlm and write mean tmp and score into big table for all people 
    % and do mixed effect model (in R). Would give more power. Can have subject as
    % intercept or even item as intercept. This let's you do first and
    % second level at the same time
    % cols: subject num, stimulus ID, hit or miss, memorability, PCs, mean tmp for each ROI
    % put all info into giant table and build models in R
    % BN_Mixed_Model_Setup.m line 182ish makes the tables to prepare to go into R
    % continuous data so don't need logistic or ordinal. One main effect or
    % might add more (especially if I want to add memorability)
    % if I get an error that has to do with filtering, change the order you
    % load libraries in R -- LMEs_Interactions_BN_Obs... from Cortney
    % Filter eg line 26 to filter down to one condition. filter()
    % line 26 and 28 work with dplyr
    
end


% sort by ROI A to Z and then by PC A to Z
% That gives me the ROIs and PCs sorted, so I can see
% the individual tStat value for each subject. All I have to do is average
% them across 19 subjects and I can get an average tStat score per PC per
% ROI.
% Have I been making any comparisons? I guess multiple linear models count.

addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/')

ROI = results_tbl{:,'ROI'};
PC = results_tbl{:,'PC'};
tstat = results_tbl{:,'tStat-score'};
pval = results_tbl{:,'pVal-score'};
corrected_p= mafdr(pval);



% this was from an old version of the code where I select specific PCs that
% were relevant to cmem and pmem. I now know that this mem data is useless
% compared to the mem data from the MTurk norming study. 19 subjects in the
% fMRI study vs hundreds in the norming study. I'll just comment this out
% cmemVals = readtable('cmem_inOrder.xlsx');
% pmemVals = readtable('pmem_inOrder.xlsx');
% 
% cmemROI = cmemVals{:,'ROI'};
% cmemPC = cmemVals{:,'PC'};
% cmemScore_tstat = cmemVals{:,'tStat_score'};
% cmemScore_pval = cmemVals{:,'pVal_score'};
% 
% pmemROI = pmemVals{:,'ROI'};
% pmemPC = pmemVals{:,'PC'};
% pmemScore_stat = pmemVals{:,'tStat_score'};
% pmemScore_pval = pmemVals{:,'pVal_score'};
% 
% % multiple comparisons correction before averaging?
% % bonferroni-holm correction
% % [cor_p, h] = bonf_holm(p_vals,.05);
% 
% % false discovery rate
% % corrected_p = mafdr(p_vals);
% 
% corrected_p_cmem = mafdr(cmemScore_pval);
% corrected_p_pmem = mafdr(pmemScore_pval);





% average them -- not corrected
tStat_mean_cmem = zeros(numel(cmemScore)/19,1); %19 subjects
counter = 1;
for row = 1:150
    tStat_mean_cmem(row) = mean(abs(cmemScore(counter:counter+18)),1);
    counter = counter + 19; %skip ahead to the next 19 subj block
end

tStat_mean_pmem = zeros(numel(pmemScore)/19,1); %19 subjects
counter = 1;
for row = 1:150
    tStat_mean_pmem(row) = mean(abs(pmemScore(counter:counter+18)),1);
    counter = counter + 19;
end


sz = [150 5]; % 30 masks * 5 PCs of interest = 150
varTypes = ["string","string","string","double","double"];
varNames = ["ROI","CMEM-PC","PMEM-PC","Mean_tStat_CMEM",'Mean_tStat_PMEM'];
meanResults_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
counter = 1;
for row = 1:150

    meanResults_tbl(row,:) = {cmemROI{counter},cmemPC{counter},pmemPC{counter},tStat_mean_cmem(row),tStat_mean_pmem(row)};
    counter = counter + 19;
end
