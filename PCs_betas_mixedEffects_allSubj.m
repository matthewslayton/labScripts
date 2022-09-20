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
load tenFactors.mat %loads 10-factor FA var 'F'
%load twentyFactors.mat %loads 20-factor FA var 'F'

itemIDs_tbl = readtable('itemIDs.xlsx'); % this has all 995 item IDs and labels

%% TMP -- average beta value for voxels in ROI in trial

% 19 subjects
subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

% structs for each subject's score_subset and tmpMean
subjInfo = struct('PCval',[],'Fval',[],'tmpVal',[],'IDs',[]);

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
    factor_subset = zeros(numel(all_betas_enc),10);
    %coeff_subset = zeros(numel(all_betas_enc),994); 
    
    for row = 1:numel(all_betas_enc)
        score_subset(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
        factor_subset(row,:) = F(indices_inOrder(row),:);
        %coeff_subset(row,:) = coeff(indices_inOrder(row),:); % the entire row which is all the PCs
    end
    
    % now I have the PC subsets that match the trials here
    
    % Step 2: Remove any trial that isn't labelled with TT3
    % in the previous step I made indices_TT. If there's a 1 in the row, keep it
    
    IDs_subset = zeros(numel(all_betas_enc),1);
    for row = 1:numel(indices_TT)
        if indices_TT(row) == 1
            score_subset(row,:) = score_subset(row,:);
            factor_subset(row,:) = factor_subset(row,:);
            %coeff_subset(row,:) = coeff_subset(row,:);
            IDs_subset(row) = str2double(cell2mat(IDs_enc{row}));

        else 
            score_subset(row,:) = NaN;
            factor_subset(row,:) = NaN;
            %coeff_subset(row,:) = NaN;
            IDs_subset(row) = NaN;
        end 
    end
    
    % remove the rows with NaN
    score_subset(any(isnan(score_subset), 2), :) = [];
    factor_subset(any(isnan(factor_subset), 2), :) = [];
    %coeff_subset(any(isnan(coeff_subset), 2), :) = [];
    IDs_subset(any(isnan(IDs_subset), 2), :) = [];
    % S002 has 266 rows. Other subj slightly diff

    % store the PC and tmp info I need in struct
    subjInfo(subjects).PCval = score_subset;
    subjInfo(subjects).Fval = factor_subset;
    subjInfo(subjects).tmpVal = tmpMean;
    subjInfo(subjects).IDs = IDs_subset;
end
cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
save('subjInfo.mat','subjInfo')

%% make table to prepare for lmer
cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
load subjInfo.mat
% i know this is not the way to do this
% each col of allTmpMat is one col of my ROI-specific table
allTmpMat = zeros(5225,30); %I got 5225 by running this once
for ROI = 1:30
    tmpRow = horzcat(cell2mat(subjInfo(1).tmpVal(ROI)),cell2mat(subjInfo(2).tmpVal(ROI)), ...
        cell2mat(subjInfo(3).tmpVal(ROI)),cell2mat(subjInfo(4).tmpVal(ROI)),cell2mat(subjInfo(5).tmpVal(ROI)), ...
        cell2mat(subjInfo(6).tmpVal(ROI)),cell2mat(subjInfo(7).tmpVal(ROI)),cell2mat(subjInfo(8).tmpVal(ROI)), ...
        cell2mat(subjInfo(9).tmpVal(ROI)),cell2mat(subjInfo(10).tmpVal(ROI)),cell2mat(subjInfo(11).tmpVal(ROI)), ...
        cell2mat(subjInfo(12).tmpVal(ROI)),cell2mat(subjInfo(13).tmpVal(ROI)),cell2mat(subjInfo(14).tmpVal(ROI)), ...
        cell2mat(subjInfo(15).tmpVal(ROI)),cell2mat(subjInfo(16).tmpVal(ROI)),cell2mat(subjInfo(17).tmpVal(ROI)), ...
        cell2mat(subjInfo(18).tmpVal(ROI)),cell2mat(subjInfo(19).tmpVal(ROI)));
    tmpCol = tmpRow';
    allTmpMat(:,ROI) = tmpCol;
end

oneROI_PCs = vertcat(subjInfo(1).PCval(:,1:10),subjInfo(2).PCval(:,1:10),subjInfo(3).PCval(:,1:10), ...
    subjInfo(4).PCval(:,1:10),subjInfo(5).PCval(:,1:10),subjInfo(6).PCval(:,1:10),subjInfo(7).PCval(:,1:10), ...
    subjInfo(8).PCval(:,1:10),subjInfo(9).PCval(:,1:10),subjInfo(10).PCval(:,1:10),subjInfo(11).PCval(:,1:10), ...
    subjInfo(12).PCval(:,1:10),subjInfo(13).PCval(:,1:10),subjInfo(14).PCval(:,1:10),subjInfo(15).PCval(:,1:10), ...
    subjInfo(16).PCval(:,1:10),subjInfo(17).PCval(:,1:10),subjInfo(18).PCval(:,1:10),subjInfo(19).PCval(:,1:10));

oneROI_Fs = vertcat(subjInfo(1).Fval(:,1:10),subjInfo(2).Fval(:,1:10),subjInfo(3).Fval(:,1:10), ...
    subjInfo(4).Fval(:,1:10),subjInfo(5).Fval(:,1:10),subjInfo(6).Fval(:,1:10),subjInfo(7).Fval(:,1:10), ...
    subjInfo(8).Fval(:,1:10),subjInfo(9).Fval(:,1:10),subjInfo(10).Fval(:,1:10),subjInfo(11).Fval(:,1:10), ...
    subjInfo(12).Fval(:,1:10),subjInfo(13).Fval(:,1:10),subjInfo(14).Fval(:,1:10),subjInfo(15).Fval(:,1:10), ...
    subjInfo(16).Fval(:,1:10),subjInfo(17).Fval(:,1:10),subjInfo(18).Fval(:,1:10),subjInfo(19).Fval(:,1:10));

% col of subject names
subjCol = vertcat(repmat("S002",numel(subjInfo(1).PCval(:,1)),1),repmat("S005",numel(subjInfo(2).PCval(:,1)),1), ...
    repmat("S006",numel(subjInfo(3).PCval(:,1)),1),repmat("S008",numel(subjInfo(4).PCval(:,1)),1), ...
    repmat("S009",numel(subjInfo(5).PCval(:,1)),1),repmat("S010",numel(subjInfo(6).PCval(:,1)),1), ...
    repmat("S011",numel(subjInfo(7).PCval(:,1)),1),repmat("S013",numel(subjInfo(8).PCval(:,1)),1), ...
    repmat("S014",numel(subjInfo(9).PCval(:,1)),1),repmat("S015",numel(subjInfo(10).PCval(:,1)),1), ...
    repmat("S016",numel(subjInfo(11).PCval(:,1)),1),repmat("S018",numel(subjInfo(12).PCval(:,1)),1), ...
    repmat("S019",numel(subjInfo(13).PCval(:,1)),1),repmat("S021",numel(subjInfo(14).PCval(:,1)),1), ...
    repmat("S022",numel(subjInfo(15).PCval(:,1)),1),repmat("S023",numel(subjInfo(16).PCval(:,1)),1), ...
    repmat("S024",numel(subjInfo(17).PCval(:,1)),1),repmat("S025",numel(subjInfo(18).PCval(:,1)),1), ...
    repmat("S026",numel(subjInfo(19).PCval(:,1)),1));


% col of ItemIDs
ID_col = vertcat(subjInfo(1).IDs,subjInfo(2).IDs,subjInfo(3).IDs,subjInfo(4).IDs, ...
    subjInfo(5).IDs,subjInfo(6).IDs,subjInfo(7).IDs,subjInfo(8).IDs,subjInfo(9).IDs, ...
    subjInfo(10).IDs,subjInfo(11).IDs,subjInfo(12).IDs,subjInfo(13).IDs,subjInfo(14).IDs,...
    subjInfo(15).IDs,subjInfo(16).IDs,subjInfo(17).IDs,subjInfo(18).IDs,subjInfo(19).IDs);

% stick them all together
% cunL_tbl.AvgROI = allTmpMat(:,1);
% cunL_tbl.Subj = subjCol;
% cunL_tbl.ItemID = ID_col;
% PCs_tbl = array2table(oneROI_PCs); 
% cunL_tbl(:,4:13) = PCs_tbl;


%% PCs
sz = [5225 12]; 
varTypes = ["string","string","double","double","double","double","double","double","double","double","double","double"];
varNames = ["Subj","ItemID","PC01","PC02","PC03","PC04","PC05","PC06","PC07","PC08","PC09","PC10"];
allButROI = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

allButROI.Subj = subjCol;
allButROI.ItemID = ID_col;
PCs_tbl = array2table(oneROI_PCs); 
allButROI(:,3:12) = PCs_tbl;

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
save('allTmpMat.mat','allTmpMat')
save('allButROI.mat','allButROI')

%% Factors
sz = [5225 12]; 
varTypes = ["string","string","double","double","double","double","double","double","double","double","double","double"];
varNames = ["Subj","ItemID","F01","F02","F03","F04","F05","F06","F07","F08","F09","F10"];
allButROI_F = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

allButROI_F.Subj = subjCol;
allButROI_F.ItemID = ID_col;
Fs_tbl = array2table(oneROI_Fs); 
allButROI_F(:,3:12) = Fs_tbl;

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
save('allTmpMat.mat','allTmpMat')
save('allButROI_F.mat','allButROI_F')

%% Make final data table for R
%%%%%%%%%%%%%%%
load allTmpMat.mat
load allButROI.mat
load allButROI_F.mat

allButROI = allButROI_F; % don't want to re-write code below, so just rename

AvgROI = allTmpMat(:,1);
cunL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,2);
cunR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,3);
fugL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,4);
fugR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,5);
hippL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,6);
hippR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,7);
ifgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,8);
ifgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,9);
iplL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,10);
iplR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,11);
itgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,12);
itgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,13);
mfgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,14);
mfgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,15);
mtgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,16);
mtgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,17);
phgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,18);
phgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,19);
pogL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,20);
pogR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,21);
prgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,22);
prgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,23);
pstsL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,24);
pstsR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,25);
sfgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,26);
sfgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,27);
splL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,28);
splR_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,29);
stgL_tbl = addvars(allButROI,AvgROI,'Before','Subj');

AvgROI = allTmpMat(:,30);
stgR_tbl = addvars(allButROI,AvgROI,'Before','Subj');


%lmer(averaged beta in PhG ~ PC1 + PC2 + ... + {1|Subject)))




% current_mask_name = matFiles_dir(ROI).name; % still has numbers and extension
% nameOnly = current_mask_name(4:end-4); % just the name, no numbers or extension

% subjInfo(1 through 19).tmpVal(1 through 30)
% numRows = 0;
% for subj = 1:19
%     tmpCell = subjInfo(subj).tmpVal(ROI);
%     tmpMat = cell2mat(tmpCell);
%     numRows = numRows + numel(tmpMat);
% end
% storeRows{ROI} = numRows;


%sz = [numRows 13]; 
% sz = [5225 13]; 
% varTypes = ["double","string","string","double","double","double","double","double","double","double","double","double","double"];
% varNames = ["AvgROI","Subj","ItemID","PC01","PC02","PC03","PC04","PC05","PC06","PC07","PC08","PC09","PC10"];
% cunL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

% cunR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% fugL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% fugR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% hippL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% hippR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% ifgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% ifgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% iplL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% iplR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% itgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% itgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% mfgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% mfgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% mtgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% mtgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% phgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% phgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% pogL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% pogR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% prgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% prgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% pstsL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% pstsR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% sfgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% sfgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% splL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% splR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% stgL_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% stgR_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


