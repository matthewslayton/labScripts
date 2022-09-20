% This is a version of PCs_betas_mixedEffects_allSubj_complete.m
% both scripts will prepare activity per ROI per trial in a table to be
% used in R to do a mixed effect moddel. This one works with custom-made
% ROIs (which are made with activityPerTrialPerCustomCluster.m). The other
% uses pre-made activity per atlas ROI (from Cortney)

set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts;
% I'm probably going to need functions from these here
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/function_files')
% load the PCs
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
load all_score.mat %loads var 'score'
% load Factors
% load twentyFactors.mat %loads var 'F', performed on 200 features
load tenFactors_500features.mat % done on entire feature matrix
%load fortyFactors_200features.mat

% can load FAs on subsets of the feature matrix.
% I have encycl, noTax, tax, fcn, vis
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/;
load 200feat_encycl_F.mat
numFactors = 10;

% load lex/con mem and vis/per mem and do the same thing with lmer as I did
% with Factors and PCs. These are from the MTurk norming study
load visMem_CR.mat
load lexMem_CR.mat

% Note, the mem data has NaNs in it. I use NaNs later to remove catch trials, 
% so I have to change the existing NaNs to something else
for row = 1:length(lexMem_CR)
    if isnan(lexMem_CR(row))
        lexMem_CR(row) = 999;
    end
    if isnan(visMem_CR(row))
        visMem_CR(row) = 999;
    end
end

% load IDs
itemIDs_tbl = readtable('itemIDs.xlsx'); % this has all 995 item IDs and labels
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/ROI_clusters;
% don't forget to save csv output as xlsx
%customMasks = readtable('clustermeans_cleanMasks.xlsx'); % these are the vis/lex interaction term masks
%customMasks = readtable('atlasMaskMeans.xlsx'); % these are the vis/lex interaction term masks
% don't forget to go to line 188 and change numMasks
% could also combine these tables and do them all at once. % allMasks = customMasks + atlasMasks
%customMasksArray = table2array(customMasks);
%maskArray_ID_data = customMasksArray(:,2:end);

allMasks = readtable('allMaskMeans.xlsx');
allMasksArr = table2array(allMasks);
maskArray_ID_data = allMasksArr(:,2:end);

%addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/combined_masks;

%% prepare betas per subject per trial per custom ROI

% struct for each subject's score_subset and activity
subjInfo = struct('PCval',[],'Fval',[],'IDs',[],'subjNum',[],'activityVal',[],'lexMem',[],'visMem',[],'bothMem',[]);

memInfo = struct('cmem',[],'pmem',[],'cmem_items',[],'pmem_items',[]);

% customMasks has values for the 300 trials
% we have to cut any trial that isn't labelled with TT3. 
% those are where the subject made some error

% once we have the 260ish we take the subset of PCs and Factors
% finally, we get the 260ish activity values from the 300

% 19 subjects
subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};
subjectCounter = 1; % add 300 each time through loop so I can grab the 300 rows per subject
% subject-specific data is on rows 2 to 301, 302 to 601, 602 to 901 etc.
% my var cuts off the col names, so start on index 1

% ~~~ % skip down to line 317 (after tables) for a repeat of the following loop.
% I'd like to average the activity but because of the false alarms the
% lengths are all different. I need to cut them to the length of the
% shortest which is S021's 249

% I need to use this code for compare_memorabilty.m
load pmem_combined.mat
load cmem_combined.mat 
load pmem_items.mat
load cmem_items.mat

for subjects = 1:length(subjectNum)

    % Step 1: Grab the subject-specific rows 
    subjectSpecificData = maskArray_ID_data(subjectCounter:subjectCounter+299,:);

    % Step 2: Cut PCs down to the 300 used in Encoding


    % **** instead of doing all of this, could get ID and TT num from the clustermeans table
    % currently activityPerTrialPerCustomCluster has ID but not TT. 
 
    all_betas_enc = dir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii'));
    IDs_enc = cell(numel(all_betas_enc),1);
    indices_TT = zeros(numel(all_betas_enc),1); % 1 for TT3 and 0 for anything else
    
    % get ID numbers used for the encoding trials
    for row = 1:numel(all_betas_enc)
    
        % get the item number. Could also get from custommasks table
        IDs_enc{row} = extractBetween(all_betas_enc(row).name,'Item', '_Enc');
    
        % is it TT3 (and should stay) or is it TT4, etc. 
        % not TT3 means there was a mismatch in covert naming (false alarm)
        TT_num_cell = extractBetween(all_betas_enc(row).name,'EncTT', '_');
        TT_num = cell2mat(TT_num_cell);
        if TT_num == '3'
            indices_TT(row) = 1;
        end
    end

    % now I have the ID numbers that are used for the encoding trials of this
    % subject
    % I have to find the PC val etc that is on the row where that ID number is in
    % itemIDs_tbl. So, I want the row number

    indices_inOrder = zeros(numel(all_betas_enc),1);
    for idNumber = 1:numel(all_betas_enc)
        % IDs_enc is cell array of cells, so I have to peel them out
        % then convert the char you get out to a num to match the table items
        index = find(itemIDs_tbl{:,2}==str2num(cell2mat(IDs_enc{idNumber}))); %find the four-digit ID num in the second col of the table
        indices_inOrder(idNumber) = index;
    end

    score_subset = zeros(numel(all_betas_enc),994); 
    %factor_subset = zeros(numel(all_betas_enc),20); 
    factor_subset = zeros(numel(all_betas_enc),numFactors);
    lexMem_subset = zeros(numel(all_betas_enc),1);
    visMem_subset = zeros(numel(all_betas_enc),1);
   
    % this is for compare_memorability.m
    % I want only the col for a given iteration of the subjects loop
    cmem_subset = cmem_combined(:,subjects);
    pmem_subset = pmem_combined(:,subjects);
    cmem_items_subset = cmem_items(:,subjects);
    pmem_items_subset = pmem_items(:,subjects);


    for row = 1:numel(all_betas_enc)
        score_subset(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
        factor_subset(row,:) = F(indices_inOrder(row),:); % the entire row which is all the factors
        lexMem_subset(row,:) = lexMem_CR(indices_inOrder(row),:);
        visMem_subset(row,:) = visMem_CR(indices_inOrder(row),:);
    end

    % Step 3: Remove any trial that isn't labelled with TT3
    % in the previous step I made indices_TT. If there's a 1 in the row, keep it

    %subject_numbers = customMasksArray(:,1);
    subject_numbers = allMasksArr(:,1);
    
    for row = 1:numel(indices_TT)
        if indices_TT(row) == 1
            score_subset(row,:) = score_subset(row,:);
            factor_subset(row,:) = factor_subset(row,:);
            subjectSpecificData(row,:) = subjectSpecificData(row,:);
            subject_numbers(row) = subject_numbers(row);
            lexMem_subset(row,:) = lexMem_subset(row,:);
            visMem_subset(row,:) = visMem_subset(row,:);

            % this is for compare_memorability.m
            cmem_subset(row,:) = cmem_subset(row,:);
            pmem_subset(row,:) = pmem_subset(row,:);
            cmem_items_subset(row,:) = cmem_items_subset(row,:);
            pmem_items_subset(row,:) = pmem_items_subset(row,:);
        else 
            score_subset(row,:) = NaN;
            factor_subset(row,:) = NaN;
            subjectSpecificData(row,:) = NaN;
            subject_numbers(row) = NaN;
            lexMem_subset(row,:) = NaN;
            visMem_subset(row,:) = NaN;

             % this is for compare_memorability.m
            cmem_subset(row,:) = NaN;
            pmem_subset(row,:) = NaN;
            cmem_items_subset(row,:) = NaN;
            pmem_items_subset(row,:) = NaN;
        end 
    end

    % remove the rows with NaN
    score_subset(any(isnan(score_subset), 2), :) = [];
    factor_subset(any(isnan(factor_subset), 2), :) = [];
    lexMem_subset(any(isnan(lexMem_subset), 2), :) = [];
    visMem_subset(any(isnan(visMem_subset), 2), :) = [];
    subjectSpecificData(any(isnan(subjectSpecificData), 2), :) = [];
    subject_numbers(any(isnan(subject_numbers), 2), :) = [];
    cmem_subset(any(isnan(cmem_subset), 2), :) = [];
    pmem_subset(any(isnan(pmem_subset), 2), :) = [];
    cmem_items_subset(any(isnan(cmem_items_subset), 2), :) = [];
    pmem_items_subset(any(isnan(pmem_items_subset), 2), :) = [];

    % store the PCs, factors, and activity
    subjInfo(subjects).PCval = score_subset;
    subjInfo(subjects).Fval = factor_subset;
    subjInfo(subjects).IDs = subjectSpecificData(:,1);
    subjInfo(subjects).subjNum = subject_numbers;
    subjInfo(subjects).activityVal = subjectSpecificData(:,2:end);
    subjInfo(subjects).lexMem = lexMem_subset;
    subjInfo(subjects).visMem = visMem_subset;

    memInfo(subjects).cmem = cmem_subset;
    memInfo(subjects).pmem = pmem_subset;
    memInfo(subjects).cmem_items = cmem_items_subset;
    memInfo(subjects).pmem_items = pmem_items_subset;

    subjectCounter = subjectCounter + 300; % go to next subject's first row
end

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP'
save('subjInfo_allROIs.mat','subjInfo')

save('memInfo.mat','memInfo')


% to not use cd you can assign var to new var with entire pathname and save that
save('subjInfo_customROIs_clean.mat','subjInfo')
%save('subjInfo_customROIs_F500.mat','subjInfo')
%save('subjInfo_customROIs_F200_m40.mat','subjInfo')
save('subjInfo_memAtlasROIs.mat','subjInfo')

%% make table to prepare for lmer
cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
load subjInfo_allROIs.mat

%load subjInfo_customROIs_clean.mat
%load subjInfo_memAtlasROIs.mat
% note, PCs_betas_mixedEffects_allSubj_complete.m loads the activity data
% as cells. It starts as rows that we horzcat, needs to be transposed, and
% then you get 5225x30, which is the number of ROIs
% In this script, I loaded the activity data as doubles. It's all cols, so
% we vertcat and we're done

%numMasks = 11; % all custom clusters = 14, but the ones I want = 11. 
%numMasks = 6; % atlas ROIs
numMasks = 17;
allActivityMat = zeros(5225,numMasks);
for ROI = 1:numMasks
    activityCol = vertcat(subjInfo(1).activityVal(:,ROI),subjInfo(2).activityVal(:,ROI), ...
        subjInfo(3).activityVal(:,ROI),subjInfo(4).activityVal(:,ROI),subjInfo(5).activityVal(:,ROI), ...
        subjInfo(6).activityVal(:,ROI),subjInfo(7).activityVal(:,ROI),subjInfo(8).activityVal(:,ROI), ...
        subjInfo(9).activityVal(:,ROI),subjInfo(10).activityVal(:,ROI),subjInfo(11).activityVal(:,ROI), ...
        subjInfo(12).activityVal(:,ROI),subjInfo(13).activityVal(:,ROI),subjInfo(14).activityVal(:,ROI), ...
        subjInfo(15).activityVal(:,ROI),subjInfo(16).activityVal(:,ROI),subjInfo(17).activityVal(:,ROI), ...
        subjInfo(18).activityVal(:,ROI),subjInfo(19).activityVal(:,ROI));
    allActivityMat(:,ROI) = activityCol;
end

%oneROI_PCs = vertcat(subjInfo.PCval(1:10)); %<-can't do if you want a subset
oneROI_PCs = vertcat(subjInfo(1).PCval(:,1:10),subjInfo(2).PCval(:,1:10),subjInfo(3).PCval(:,1:10), ...
    subjInfo(4).PCval(:,1:10),subjInfo(5).PCval(:,1:10),subjInfo(6).PCval(:,1:10),subjInfo(7).PCval(:,1:10), ...
    subjInfo(8).PCval(:,1:10),subjInfo(9).PCval(:,1:10),subjInfo(10).PCval(:,1:10),subjInfo(11).PCval(:,1:10), ...
    subjInfo(12).PCval(:,1:10),subjInfo(13).PCval(:,1:10),subjInfo(14).PCval(:,1:10),subjInfo(15).PCval(:,1:10), ...
    subjInfo(16).PCval(:,1:10),subjInfo(17).PCval(:,1:10),subjInfo(18).PCval(:,1:10),subjInfo(19).PCval(:,1:10));

oneROI_Fs = vertcat(subjInfo.Fval); %<- can do if you want it all
% oneROI_Fs = vertcat(subjInfo(1).Fval(:,1:10),subjInfo(2).Fval(:,1:10),subjInfo(3).Fval(:,1:10), ...
%     subjInfo(4).Fval(:,1:10),subjInfo(5).Fval(:,1:10),subjInfo(6).Fval(:,1:10),subjInfo(7).Fval(:,1:10), ...
%     subjInfo(8).Fval(:,1:10),subjInfo(9).Fval(:,1:10),subjInfo(10).Fval(:,1:10),subjInfo(11).Fval(:,1:10), ...
%     subjInfo(12).Fval(:,1:10),subjInfo(13).Fval(:,1:10),subjInfo(14).Fval(:,1:10),subjInfo(15).Fval(:,1:10), ...
%     subjInfo(16).Fval(:,1:10),subjInfo(17).Fval(:,1:10),subjInfo(18).Fval(:,1:10),subjInfo(19).Fval(:,1:10));

oneROI_lexMem = vertcat(subjInfo.lexMem);
oneROI_visMem = vertcat(subjInfo.visMem);

% I think I messed up the subject ID field, so just do it the old way
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
ID_col = vertcat(subjInfo.IDs);
% ID_col = vertcat(subjInfo(1).IDs,subjInfo(2).IDs,subjInfo(3).IDs,subjInfo(4).IDs, ...
%     subjInfo(5).IDs,subjInfo(6).IDs,subjInfo(7).IDs,subjInfo(8).IDs,subjInfo(9).IDs, ...
%     subjInfo(10).IDs,subjInfo(11).IDs,subjInfo(12).IDs,subjInfo(13).IDs,subjInfo(14).IDs,...
%     subjInfo(15).IDs,subjInfo(16).IDs,subjInfo(17).IDs,subjInfo(18).IDs,subjInfo(19).IDs);

%% PCs
sz = [5225 12]; 
varTypes = ["string","string","double","double","double","double","double","double","double","double","double","double"];
varNames = ["Subj","ItemID","PC01","PC02","PC03","PC04","PC05","PC06","PC07","PC08","PC09","PC10"];
allButROI_custom = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

allButROI_custom.Subj = subjCol;
allButROI_custom.ItemID = ID_col;
PCs_tbl = array2table(oneROI_PCs); 
allButROI_custom(:,3:12) = PCs_tbl;

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
save('allActivityMat_clean.mat','allActivityMat')
save('allButROI_customClean.mat','allButROI_custom')

%% Factors
sz = [5225 12]; 
varTypes = ["string","string","double","double","double","double","double","double","double","double","double","double"];
varNames = ["Subj","ItemID","F01","F02","F03","F04","F05","F06","F07","F08","F09","F10"];
allButROI_custom_F = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

allButROI_custom_F.Subj = subjCol;
allButROI_custom_F.ItemID = ID_col;
Fs_tbl = array2table(oneROI_Fs); 
allButROI_custom_F(:,3:12) = Fs_tbl;

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
%save('allActivityMat.mat','allActivityMat')
%save('allButROI_custom_F.mat','allButROI_custom_F')
save('allButROI_customClean_F500.mat','allButROI_custom_F')

allButROI_encycl = allButROI_custom_F;
save('allButROI_encycl.mat', 'allButROI_encycl')

%% Mem
% there are still 999 rows in lexMem and visMem we have to cut out those
% trials from allActivityMat as well as oneROI_lexMem and oneROI_visMem

lex_index = find(oneROI_lexMem==999); % 1030 of these
vis_index = find(oneROI_visMem==999); % 110
combined_index = vertcat(lex_index,vis_index); % 1140
both_index = unique(combined_index); % 1047

allActivityMat(both_index,:) = [];
oneROI_lexMem(both_index) = [];
oneROI_visMem(both_index) = [];
subjCol(both_index) = [];
ID_col(both_index) = [];

allActivityMat_memShort = allActivityMat;
oneROI_lexMem_short = oneROI_lexMem;
oneROI_visMem_short = oneROI_visMem;
subjCol_short = subjCol;
ID_col_short = ID_col;

% at this point the mem values should all be cleaned
% therefore, I can now make bothMem from the short versions of vis and lex

normLex = oneROI_lexMem_short - repmat(mean(oneROI_lexMem_short),length(oneROI_lexMem_short),1);
normVis = oneROI_visMem_short - repmat(mean(oneROI_visMem_short),length(oneROI_visMem_short),1);

bothMem = normVis .* normLex;


sz = [4178 5]; 
varTypes = ["string","string","double","double","double"];
varNames = ["Subj","ItemID","lexMem","visMem","bothMem"];
allButROI_memShort = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

allButROI_memShort.Subj = subjCol_short;
allButROI_memShort.ItemID = ID_col_short;
allButROI_memShort.lexMem = oneROI_lexMem_short;
allButROI_memShort.visMem = oneROI_visMem_short;
allButROI_memShort.bothMem = bothMem;





cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
save('allActivityMat_memShort.mat','allActivityMat_memShort')
save('allButROI_memShort.mat','allButROI_memShort')


%% Make final data table for R
%%%%%%%%%%%%%%%
load allActivityMat_clean.mat
load allButROI_customClean.mat
load allButROI_customClean_F500.mat
load allButROI_memShort.mat
load allActivityMat_memShort.mat

%allButROI_custom = allButROI_custom_F; % don't want to re-write code below, so just rename

% spreadsheet for PCs and F
% /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/avgActivity_customROIs_PC_F500.xlsx

% spreadsheet for Mem
% avgActivity_customROIs_mem.xlsx

% PCs
AvgROI = allActivityMat(:,1);
mask28_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,2);
mask29_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,3);
mask30_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,4);
mask31_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,5);
mask32_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

% AvgROI = allActivityMat(:,6);
% mask33_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,6);
mask34_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,7);
mask35_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

% AvgROI = allActivityMat(:,9);
% mask36_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,8);
mask37_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

% AvgROI = allActivityMat(:,11);
% mask38_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,9);
mask39_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,10);
mask40_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,11);
mask41_PC = addvars(allButROI_custom,AvgROI,'Before','Subj');

% Factors
AvgROI = allActivityMat(:,1);
mask28_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,2);
mask29_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,3);
mask30_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,4);
mask31_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,5);
mask32_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

% AvgROI = allActivityMat(:,6);
% mask33_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,6);
mask34_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,7);
mask35_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

% AvgROI = allActivityMat(:,9);
% mask36_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,8);
mask37_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

% AvgROI = allActivityMat(:,11);
% mask38_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,9);
mask39_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,10);
mask40_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

AvgROI = allActivityMat(:,11);
mask41_F = addvars(allButROI_custom_F,AvgROI,'Before','Subj');

% copy and paste into avgActivity_customROIs_PC_F.xlsx / ...F500.xlsx
% avgActivity_CleanCustomROIs_PC_F500

% Mem

% customMasks
AvgROI = allActivityMat_memShort(:,1);
mask28_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,2);
mask29_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,3);
mask30_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,4);
mask31_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,5);
mask32_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,6);
mask34_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,7);
mask35_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,8);
mask37_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,9);
mask39_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,10);
mask40_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,11);
mask41_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

% atlasMasks
AvgROI = allActivityMat_memShort(:,12);
L_HC_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,13);
R_HC_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,14);
L_PhG_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,15);
R_PhG_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,16);
L_Fus_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');

AvgROI = allActivityMat_memShort(:,17);
R_Fus_mem = addvars(allButROI_memShort,AvgROI,'Before','Subj');


% if I want activity and mem only

activity_mem_only = [AvgROI table2array(allButROI_memShort)];

save('activity_mem_only.mat','activity_mem_only')

%% re-do where all activity cut to same length

% these indices are for the subject with the shortest activity array,
% meaning we had to cut the most out because they made the most covert
% naming errors. We have to cut the arrays down to the length of the
% shortest so we can average them

addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts;
load indices_TT_S021
% numFactors = 40;
for subjects = 1:length(subjectNum)

    % Step 1: Grab the subject-specific rows 
    subjectSpecificData = maskArray_ID_data(subjectCounter:subjectCounter+299,:);

    % Step 2: Cut PCs down to the 300 used in Encoding


    % **** instead of doing all of this, could get ID and TT num from the clustermeans table
    % currently activityPerTrialPerCustomCluster has ID but not TT. 
 
    all_betas_enc = dir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii'));
    IDs_enc = cell(numel(all_betas_enc),1);
    indices_TT = zeros(numel(all_betas_enc),1); % 1 for TT3 and 0 for anything else
    
        % get ID numbers used for the encoding trials
    for row = 1:numel(all_betas_enc)
    
        % get the item number. Could also get from custommasks table
        IDs_enc{row} = extractBetween(all_betas_enc(row).name,'Item', '_Enc');
    
        % is it TT3 (and should stay) or is it TT4, etc. 
        % not TT3 means there was a mismatch in covert naming (false alarm)
        % use indices_TT_S021, the shortest
    end

    % now I have the ID numbers that are used for the encoding trials of this
    % subject
    % I have to find the PC val etc that is on the row where that ID number is in
    % itemIDs_tbl. So, I want the row number

    indices_inOrder = zeros(numel(all_betas_enc),1);
    for idNumber = 1:numel(all_betas_enc)
        % IDs_enc is cell array of cells, so I have to peel them out
        % then convert the char you get out to a num to match the table items
        index = find(itemIDs_tbl{:,2}==str2num(cell2mat(IDs_enc{idNumber}))); %find the four-digit ID num in the second col of the table
        indices_inOrder(idNumber) = index;
    end

    score_subset = zeros(numel(all_betas_enc),994); 
    factor_subset = zeros(numel(all_betas_enc),numFactors); 

    for row = 1:numel(all_betas_enc)
        score_subset(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
        factor_subset(row,:) = F(indices_inOrder(row),:); % the entire row which is all the factors
    end

    % Step 3: Remove any trial that isn't labelled with TT3
    % in the previous step I made indices_TT. If there's a 1 in the row, keep it

    subject_numbers = customMasksArray(:,1);
    
    for row = 1:numel(indices_TT_S021)
        if indices_TT_S021(row) == 1
            score_subset(row,:) = score_subset(row,:);
            factor_subset(row,:) = factor_subset(row,:);
            subjectSpecificData(row,:) = subjectSpecificData(row,:);
            subject_numbers(row) = subject_numbers(row);
        else 
            score_subset(row,:) = NaN;
            factor_subset(row,:) = NaN;
            subjectSpecificData(row,:) = NaN;
            subject_numbers(row) = NaN;
        end 
    end

    % remove the rows with NaN
    score_subset(any(isnan(score_subset), 2), :) = [];
    factor_subset(any(isnan(factor_subset), 2), :) = [];
    subjectSpecificData(any(isnan(subjectSpecificData), 2), :) = [];
    subject_numbers(any(isnan(subject_numbers), 2), :) = [];

    % store the PCs, factors, and activity
    subjInfo(subjects).PCval = score_subset;
    subjInfo(subjects).Fval = factor_subset;
    subjInfo(subjects).IDs = subjectSpecificData(:,1);
    subjInfo(subjects).subjNum = subject_numbers;
    subjInfo(subjects).activityVal = subjectSpecificData(:,2:end);

    subjectCounter = subjectCounter + 300; % go to next subject's first row
end

subjInfo_short = subjInfo;

save('subjInfo_short.mat','subjInfo_short')

%save('subjInfo_short_m40.mat','subjInfo_short')

% now I want to average them to make one 249x14 mat that's averaged
% activity for the 14 custom ROIs

sumMat = subjInfo_short(1).activityVal+subjInfo_short(2).activityVal+subjInfo_short(3).activityVal+...
    subjInfo_short(4).activityVal+subjInfo_short(5).activityVal+subjInfo_short(6).activityVal+...
    subjInfo_short(7).activityVal+subjInfo_short(8).activityVal+subjInfo_short(9).activityVal+...
    subjInfo_short(10).activityVal+subjInfo_short(11).activityVal+subjInfo_short(12).activityVal+...
    subjInfo_short(13).activityVal+subjInfo_short(14).activityVal+subjInfo_short(15).activityVal+...
    subjInfo_short(16).activityVal+subjInfo_short(17).activityVal+subjInfo_short(18).activityVal+...
    subjInfo_short(19).activityVal;

activityMean_allSubj = sumMat ./ 19;

save('activityMean_allSubj.mat','activityMean_allSubj')


%% need averages to make plots for poster.
%%% I want two scatter plots with regression line. One for mem and F and
%%% one for mem and activity. Both need to be item-level.


load allButROI_memShort
load allButROI_encycl
load allActivityMat_memShort.mat
F_sorted = sortrows(allButROI_encycl,{'ItemID'},{'ascend'});


% now that the rows are sorted by item, average the rows that go with each
% item. Unfortunately not all subjects saw all items, so I can't just do
% every 19 rows 


% find the positions of where the ItemID changes
itemID_col = F_sorted{:,2};
changePositions = zeros(length(itemID_col),1); % don't think you can append in matlab, so I'll just do 1s and 0s
for row = 1:length(itemID_col)-1

    if itemID_col(row) ~= itemID_col(row+1) % if they're different
        changePositions(row) = 1;
    else
        changePositions(row) = 0;
    end
end

% changePositions gives the LAST row of the group
row_indices = find(changePositions == 1); % there are 299
F_means = zeros(length(row_indices),10);
F_itemIDs = strings(length(row_indices),1);

for group = 1:length(row_indices)

    if group == 1
        firstRowOfGroup = 1;
    else
        firstRowOfGroup = 1 + (row_indices(group-1)); 
    end
    lastRowOfGroup = row_indices(group);
    currMean = mean(F_sorted{firstRowOfGroup:lastRowOfGroup,3:12});
    % 3 to 12 because first two cols are subj and ItemID
    F_means(group,:) = currMean;

    % grab the ItemID number
    F_itemIDs(group) = F_sorted{firstRowOfGroup,2}; % itemID col

end

%%% now I have a ref table of the ItemID and the ten F values that go with it



%%%%%% scatter of mem x F

% ask which IDs there are mem values for and then get the F values

mem_sorted = sortrows(allButROI_memShort,{'ItemID'},{'ascend'});



% need to do the same sorting and averaging to allActivityMat_memShort

activityTbl = array2table(allActivityMat_memShort,'VariableNames',...
    {'mask28','mask29','mask30','mask31','mask32','mask34','mask35',...
    'mask37','mask39','mask40','mask41','L_HC','R_HC','L_PhG','R_PhG',...
    'L_Fus','RFus'});

IDcol = allButROI_memShort{:,2};

memActivityTbl = addvars(activityTbl,IDcol,'After','RFus'); 

memActivity_sorted = sortrows(memActivityTbl,{'IDcol'},{'ascend'});



% thankfully the subj-wise mem values are just repeated, so I only need one
% still, I don't know which are missing, so I better find the ItemID
% changes, etc, just like I did for F

% find the positions of where the ItemID changes
itemID_col = mem_sorted{:,2};
changePositions = zeros(length(itemID_col),1); % don't think you can append in matlab, so I'll just do 1s and 0s
for row = 1:length(itemID_col)-1

    if itemID_col(row) ~= itemID_col(row+1) % if they're different
        changePositions(row) = 1;
    else
        changePositions(row) = 0;
    end
end
% changePositions gives the LAST row of the group

row_indices = find(changePositions == 1); % there are 240
mem_means = zeros(length(row_indices),2);
activity_means = zeros(length(row_indices),17);
mem_itemIDs = strings(length(row_indices),1);

for group = 1:length(row_indices)
    if group == 1
        firstRowOfGroup = 1;
    else
        firstRowOfGroup = 1 + (row_indices(group-1)); 
    end
    lastRowOfGroup = row_indices(group);
    currMean = mean(mem_sorted{firstRowOfGroup:lastRowOfGroup,3:4}); % 3 and 4 are MTurk lexMem and visMem
    currMean_activity = mean(memActivity_sorted{firstRowOfGroup:lastRowOfGroup,1:17}); % 17 ROIs
    mem_means(group,:) = currMean;
    activity_means(group,:) = currMean_activity;

    % grab the ItemID number
    mem_itemIDs(group) = mem_sorted{firstRowOfGroup,2}; % itemID col
end

%%% now I have a ref table of the ItemID and the two mem values that go with it
%%% Also, mem is 240 long and F is 299 long

% Grab the mem values and matching F value
F_short = zeros(length(mem_means),10);
for row = 1:length(mem_means)
    currID = mem_itemIDs(row);
    position = find(F_itemIDs == currID);
    F_short(row,:) = F_means(position,:);
end

% F_short cols 1 through 10 for the 10 factors
% mem_means cols 1 and 2 for lexMem and visMem (MTurk)


lexMemAll = mem_means(:,1);
visMemAll = mem_means(:,2);
f01_all = F_short(:,1);
f02_all = F_short(:,2);
f03_all = F_short(:,3);
f04_all = F_short(:,4);
f05_all = F_short(:,5);
f06_all = F_short(:,6);
f07_all = F_short(:,7);
f08_all = F_short(:,8);
f09_all = F_short(:,9);
f10_all = F_short(:,10);


tbl_mem_F = table(lexMemAll,visMemAll,f01_all,f02_all,f03_all,f04_all,...
    f05_all,f06_all,f07_all,f08_all,f09_all,f10_all);

%%% do one at a time
% lexMem
x = tbl_mem_F{:,1};
% visMem
x = tbl_mem_F{:,2};

for f_val = 1:10
    y = tbl_mem_F{:,f_val+2};
    % pearson's coefficient
    C = cov(x,y);
    p = C(2)/(std(x)*std(y));
    disp(p);
end

% lexMem and F01 is .22, F02 is .18, F04 is .14
% visMem and F01 is .337, F02 is .212, F04 is .258

% now plot the ones that look best
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

mdl1 = fitlm(tbl_mem_F,'f01_all ~ lexMemAll');
plot(mdl1)
xlabel('Conceptual Memorability')
ylabel('Factor 1 Scores')
title('Conceptual Memorability and Factor 1 Scores')
txt = 'r = .22';
text(-0.1, 4,txt,'FontSize',14)

figure

mdl2 = fitlm(tbl_mem_F,'f01_all ~ visMemAll');
plot(mdl2)
xlabel('Perceptual Memorability')
ylabel('Factor 1 Scores')
title('Perceptual Memorability and Factor 1 Scores')
txt = 'r = .34';
text(-0.2, 4,txt,'FontSize',14)


%%%%%% do the same for mem x BOLD

lexMemAll = mem_means(:,1);
visMemAll = mem_means(:,2);
mask28All = activity_means(:,1);
mask29All = activity_means(:,2);
mask30All = activity_means(:,3);
mask31All = activity_means(:,4);
mask32All = activity_means(:,5);
mask34All = activity_means(:,6);
mask35All = activity_means(:,7);
mask37All = activity_means(:,8);
mask39All = activity_means(:,9);
mask40All = activity_means(:,10);
mask41All = activity_means(:,11);
LHCall = activity_means(:,12);
RHCall = activity_means(:,13);
LPhGall = activity_means(:,14);
RPhGall = activity_means(:,15);
LFusAll = activity_means(:,16);
RFusAll = activity_means(:,17);

tbl_mem_activity = table(lexMemAll,visMemAll,mask28All,mask29All,mask30All,...
    mask31All,mask32All,mask34All,mask35All,mask37All,mask39All,mask40All,...
    mask41All,LHCall,RHCall,LPhGall,RPhGall,LFusAll,RFusAll);

%%% do one at a time
% lexMem
x = tbl_mem_activity{:,1};
% visMem
x = tbl_mem_activity{:,2};

for f_val = 1:17
    y = tbl_mem_activity{:,f_val+2};
    % pearson's coefficient
    C = cov(x,y);
    p = C(2)/(std(x)*std(y));
    disp(p);
end

% lexMem mask30 .15, R PhG .13

% visMem L HC .12, R HC .13
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

mdl1 = fitlm(tbl_mem_activity,'RPhGall ~ lexMemAll');
plot(mdl1)
xlabel('Conceptual Memorability','FontSize',13)
ylabel('BOLD','FontSize',13)
title('R Parahippocampal Gyrus','FontSize',14)
txt = 'r = .13';
text(0.4, -1,txt,'FontSize',14)

figure

mdl2 = fitlm(tbl_mem_activity,'RPhGall ~ lexMemAll');
plot(mdl2)
xlabel('Conceptual Memorability','FontSize',13)
ylabel('BOLD','FontSize',13)
title('Supramarginal Gyrus','FontSize',14)
txt = 'r = .15';
text(0.4, -1,txt,'FontSize',14)

figure

mdl3 = fitlm(tbl_mem_activity,'RHCall ~ visMemAll');
plot(mdl3)
xlabel('Perceptual Memorability','FontSize',13)
ylabel('BOLD','FontSize',13)
title('Right Hippocampus','FontSize',14)
txt = 'r = .13';
text(0.4,-1.5,txt,'FontSize',14)







%%%%%%%%%%
%% plot

lexMemAll = allButROI_memShort{:,3};
visMemAll = allButROI_memShort{:,4};

activity_mask34 = allActivityMat_memShort(:,6);
activity_LPhG = allActivityMat_memShort(:,12);
activity_RPhG = allActivityMat_memShort(:,13);
activity_LFus = allActivityMat_memShort(:,16);
activity_RFus = allActivityMat_memShort(:,17);

tbl = table(MPG,Weight,Year);
mdl = fitlm(tbl,'MPG ~ Year + Weight^2');
plot(mdl)


tbl_mask34 = table(lexMemAll,visMemAll,activity_mask34);
tbl_LPhG = table(lexMemAll,visMemAll,activity_LPhG);
tbl_RPhG = table(lexMemAll,visMemAll,activity_RPhG);
tbl_LFus = table(lexMemAll,visMemAll,activity_LFus);
tbl_RFus = table(lexMemAll,visMemAll,activity_RFus);

mdl = fitlm(tbl_mask34,'activity_mask34 ~ lexMemAll');
plot(mdl)

mdl = fitlm(tbl_LFus,'activity_LFus ~ lexMemAll');
plot(mdl)

mdl = fitlm(tbl_RFus,'activity_RFus ~ lexMemAll');
plot(mdl)

mdl = fitlm(tbl_LPhG,'activity_LPhG ~ lexMemAll');
plot(mdl)

mdl = fitlm(tbl_RPhG,'activity_RPhG ~ lexMemAll');
plot(mdl)


mean_activityFus = mean([activity_LFus activity_RFus],2);
mean_activityPhG = mean([activity_LPhG activity_RPhG],2);

tbl_meanFus = table(mean_activityFus,lexMemAll,visMemAll);
tbl_meanPhG = table(mean_activityPhG,lexMemAll,visMemAll);

mdl = fitlm(tbl_meanFus,'mean_activityFus ~ lexMemAll');
plot(mdl)

mdl = fitlm(tbl_meanFus,'mean_activityFus ~ visMemAll');
plot(mdl)

mdl = fitlm(tbl_meanPhG,'mean_activityPhG ~ lexMemAll');
plot(mdl)

mdl = fitlm(tbl_meanPhG,'mean_activityPhG ~ visMemAll');
plot(mdl)