% the goal here is to compare the memorability scores for the MTurk norming
% study with the scores from the fMRI subjects 

% there will be vis (pmem) and lex (cmem)

addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/visLexMem_groups'
memData = readtable('memData.xlsx'); % this is the MTurk data from 566 raters

% remember we're using ret only. Still need to remove the lures which I did
% in the cmem and pmem scripts. They have names like predict_mem_2_enc_cmem.m
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/items_cmem_ret';
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/items_pmem_ret';
cmemdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/items_cmem_ret';
pmemdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/items_pmem_ret';

cd (cmemdir)
cmem_files = dir('*.mat');
cmemList = {cmem_files.name}.';

cd (pmemdir)
pmem_files = dir('*.mat');
pmemList = {pmem_files.name}.';

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts'


%% make scatter plot that compares item-wise mturk mem with fmri cmem and pmem

% memData has 995. Also doesn't appear to be in any order
load visMem_CR.mat % HR-FAR calculated in mem_MTurk_betas_masks.m
load lexMem_CR.mat

% memData needs ID numbers
itemIDs_names = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/itemIDs.xlsx');

% the 1111s weren't used in the fMRI study, so I don't have to worry about them

% lexMem

conceptCol = memData{:,2};
itemCol = itemIDs_names{:,1};
IDnumCol = zeros(length(conceptCol),1);
for obj = 1:length(conceptCol)
   currObj = conceptCol{obj};
   index = find(itemCol==string(conceptCol(obj)));
   IDnumCol(obj) = itemIDs_names{index,2};
   
end


memData = addvars(memData,IDnumCol,'Before','concept');

save memData.mat memData


%% lexMem and cmem

% items_and_cmem_sorted have itemIDs
sub01_c = importdata(cmemList{1});
sub02_c = importdata(cmemList{2});
sub03_c = importdata(cmemList{3});
sub04_c = importdata(cmemList{4});
sub05_c = importdata(cmemList{5});
sub06_c = importdata(cmemList{6});
sub07_c = importdata(cmemList{7});
sub08_c = importdata(cmemList{8});
sub09_c = importdata(cmemList{9});
sub10_c = importdata(cmemList{10});
sub11_c = importdata(cmemList{11});
sub12_c = importdata(cmemList{12});
sub13_c = importdata(cmemList{13});
sub14_c = importdata(cmemList{14});
sub15_c = importdata(cmemList{15});
sub16_c = importdata(cmemList{16});
sub17_c = importdata(cmemList{17});
sub18_c = importdata(cmemList{18});
sub19_c = importdata(cmemList{19});

cmem_combined = [sub01_c(:,2),sub02_c(:,2),sub03_c(:,2),sub04_c(:,2),sub05_c(:,2),...
    sub06_c(:,2),sub07_c(:,2),sub08_c(:,2),sub09_c(:,2),sub10_c(:,2),sub11_c(:,2),...
    sub12_c(:,2),sub13_c(:,2),sub14_c(:,2),sub15_c(:,2),sub16_c(:,2),sub17_c(:,2),...
    sub18_c(:,2),sub19_c(:,2)];

cmem_items = [sub01_c(:,1),sub02_c(:,1),sub03_c(:,1),sub04_c(:,1),sub05_c(:,1),...
    sub06_c(:,1),sub07_c(:,1),sub08_c(:,1),sub09_c(:,1),sub10_c(:,1),sub11_c(:,1),...
    sub12_c(:,1),sub13_c(:,1),sub14_c(:,1),sub15_c(:,1),sub16_c(:,1),sub17_c(:,1),...
    sub18_c(:,1),sub19_c(:,1)];

cmem_mean = mean(cmem_combined,2);

cmem_mean_300 = cmem_mean;

% I want to grab the relevant memData rows that match the items in
% items_and_cmem_sorted

lexMem_300 = zeros(300,1);
visMem_300 = zeros(300,1);
for row = 1:length(items_and_cmem_sorted)
    IDnum = items_and_cmem_sorted(row,1);
    row_index = find(IDnumCol==IDnum);
    lexMem_300(row) = memData{row_index,11};
    visMem_300(row) = memData{row_index,10};
end

% remove the rows with NaN
cmem_mean(any(isnan(lexMem_300), 2), :) = [];
lexMem_300(any(isnan(lexMem_300), 2), :) = [];

scatter(lexMem_300,cmem_mean,'filled')
corrcoef(lexMem_300,cmem_mean) % r = .0577
xlabel('MTurk lexical mem')
ylabel('fMRI cmem')

%% visMem and pmem

% items_and_cmem_sorted have itemIDs
sub01_p = importdata(pmemList{1});
sub02_p = importdata(pmemList{2});
sub03_p = importdata(pmemList{3});
sub04_p = importdata(pmemList{4});
sub05_p = importdata(pmemList{5});
sub06_p = importdata(pmemList{6});
sub07_p = importdata(pmemList{7});
sub08_p = importdata(pmemList{8});
sub09_p = importdata(pmemList{9});
sub10_p = importdata(pmemList{10});
sub11_p = importdata(pmemList{11});
sub12_p = importdata(pmemList{12});
sub13_p = importdata(pmemList{13});
sub14_p = importdata(pmemList{14});
sub15_p = importdata(pmemList{15});
sub16_p = importdata(pmemList{16});
sub17_p = importdata(pmemList{17});
sub18_p = importdata(pmemList{18});
sub19_p = importdata(pmemList{19});


pmem_combined = [sub01_p(:,2),sub02_p(:,2),sub03_p(:,2),sub04_p(:,2),sub05_p(:,2),...
    sub06_p(:,2),sub07_p(:,2),sub08_p(:,2),sub09_p(:,2),sub10_p(:,2),sub11_p(:,2),...
    sub12_p(:,2),sub13_p(:,2),sub14_p(:,2),sub15_p(:,2),sub16_p(:,2),sub17_p(:,2),...
    sub18_p(:,2),sub19_p(:,2)];

pmem_items = [sub01_p(:,1),sub02_p(:,1),sub03_p(:,1),sub04_p(:,1),sub05_p(:,1),...
    sub06_p(:,1),sub07_p(:,1),sub08_p(:,1),sub09_p(:,1),sub10_p(:,1),sub11_p(:,1),...
    sub12_p(:,1),sub13_p(:,1),sub14_p(:,1),sub15_p(:,1),sub16_p(:,1),sub17_p(:,1),...
    sub18_p(:,1),sub19_p(:,1)];

pmem_mean = mean(pmem_combined,2);

pmem_mean_300 = pmem_mean;

% remove the rows with NaN
pmem_mean(any(isnan(visMem_300), 2), :) = [];
visMem_300(any(isnan(visMem_300), 2), :) = [];

figure
scatter(visMem_300,pmem_mean,'filled')
corrcoef(visMem_300,pmem_mean) % r = .04
xlabel('MTurk visual mem')
ylabel('fMRI pmem')


%% set up table to run linear model with fMRI activity and both mem types


load allActivityMat.mat % from PCs_betas_lmer_customROIs.m
% remember, the subj col will be different, but we'll need activity per ROI

load subjInfo_allROIs.mat

numMasks = 17;
% it goes mask 28, 29, 30, 31, 32, 34, 35, 37, 39, 40, 41,
% fugL, fugR, hippL, hippR, phgL, phgR
allActivityMat = zeros(5225,numMasks);
% remember that each subject missed different trials, so they are all
% some number less than 300
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

allActivityMat_17 = allActivityMat;

save allActivityMat_17.mat allActivityMat_17

% col of ItemIDs
ID_col = vertcat(subjInfo.IDs);

% subjCol
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

allCol_unsorted = [allActivityMat,ID_col];

% we need to re-sort allActivityMat, ID_col, and subjCol. 
% They are grouped by subject. We need them grouped by item

allCol_sorted = sortrows(allCol_unsorted,18,'ascend');


% the next step is to find the catch trials and remove them from cmem and
% pmem. I did this in PCs_betas_lmer_customROIs.m, so I may as well just do
% it there

save('pmem_combined.mat','pmem_combined')
save('cmem_combined.mat','cmem_combined')
save('pmem_items.mat','pmem_items')
save('cmem_items.mat','cmem_items')

% go to PCs_betas_lmer_customROIs.m

addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts'
load memInfo
load cmem_combined.mat
load cmem_items.mat
load pmem_combined.mat
load pmem_items.mat
load lexMem_CR.mat
load visMem_CR.mat
load memData.mat


% memInfo is a struct that has the NaNs removed. Now the cmem and pmem
% trials will sum to match the 5225 of the activity.
% (I checked the individual subject lengths and it matches)


allcmem = vertcat(memInfo(1).cmem,memInfo(2).cmem,memInfo(3).cmem,memInfo(4).cmem,...
    memInfo(5).cmem,memInfo(6).cmem,memInfo(7).cmem,memInfo(8).cmem,memInfo(9).cmem,...
    memInfo(10).cmem,memInfo(11).cmem,memInfo(12).cmem,memInfo(13).cmem,memInfo(14).cmem,...
    memInfo(15).cmem,memInfo(16).cmem,memInfo(17).cmem,memInfo(18).cmem,memInfo(19).cmem);

allpmem = vertcat(memInfo(1).pmem,memInfo(2).pmem,memInfo(3).pmem,memInfo(4).pmem,...
    memInfo(5).pmem,memInfo(6).pmem,memInfo(7).pmem,memInfo(8).pmem,memInfo(9).pmem,...
    memInfo(10).pmem,memInfo(11).pmem,memInfo(12).pmem,memInfo(13).pmem,memInfo(14).pmem,...
    memInfo(15).pmem,memInfo(16).pmem,memInfo(17).pmem,memInfo(18).pmem,memInfo(19).pmem);

allpmem_items = vertcat(memInfo(1).pmem_items,memInfo(2).pmem_items,memInfo(3).pmem_items,memInfo(4).pmem_items,...
    memInfo(5).pmem_items,memInfo(6).pmem_items,memInfo(7).pmem_items,memInfo(8).pmem_items,memInfo(9).pmem_items,...
    memInfo(10).pmem_items,memInfo(11).pmem_items,memInfo(12).pmem_items,memInfo(13).pmem_items,memInfo(14).pmem_items,...
    memInfo(15).pmem_items,memInfo(16).pmem_items,memInfo(17).pmem_items,memInfo(18).pmem_items,memInfo(19).pmem_items);

allcmem_items = vertcat(memInfo(1).cmem_items,memInfo(2).cmem_items,memInfo(3).cmem_items,memInfo(4).cmem_items,...
    memInfo(5).cmem_items,memInfo(6).cmem_items,memInfo(7).cmem_items,memInfo(8).cmem_items,memInfo(9).cmem_items,...
    memInfo(10).cmem_items,memInfo(11).cmem_items,memInfo(12).cmem_items,memInfo(13).cmem_items,memInfo(14).cmem_items,...
    memInfo(15).cmem_items,memInfo(16).cmem_items,memInfo(17).cmem_items,memInfo(18).cmem_items,memInfo(19).cmem_items);


% I have the cmem and pmem values cut down so they sum to 5225.
% next:
% 1. Use cmem_items and pmem_items to match visMem and lexMem
% 2. Use how many items there are for subj col
% 3. Make sure everything matches

% make lexMem and visMem cols that match cmem_items and pmem_items

for row = 1:length(items_and_cmem_sorted)
    IDnum = items_and_cmem_sorted(row,1);
    row_index = find(IDnumCol==IDnum);
    lexMem_300(row) = memData{row_index,11};
    visMem_300(row) = memData{row_index,10};
end


mturk_lexMem = zeros(5225,1);
counter = 1;
for subject = 1:19
    currItemList = memInfo(subject).cmem_items;
    lexMemCol = zeros(length(currItemList),1);
    for row = 1:length(currItemList)
        row_index = find(IDnumCol==currItemList(row));
        lexMemCol(row) = memData{row_index,11};
    end
    mturk_lexMem(counter:counter+length(lexMemCol)-1) = lexMemCol;
    counter = counter + length(lexMemCol);
end

mturk_visMem = zeros(5225,1);
counter = 1;
for subject = 1:19
    currItemList = memInfo(subject).pmem_items;
    visMemCol = zeros(length(currItemList),1);
    for row = 1:length(currItemList)
        row_index = find(IDnumCol==currItemList(row));
        visMemCol(row) = memData{row_index,10};
    end
    mturk_visMem(counter:counter+length(visMemCol)-1) = visMemCol;
    counter = counter + length(visMemCol);
end

save mturk_visMem.mat mturk_visMem
save mturk_lexMem.mat mturk_lexMem

addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts'
% load memInfo
% load cmem_combined.mat
% load cmem_items.mat
% load pmem_combined.mat
% load pmem_items.mat
% load lexMem_CR.mat
% load visMem_CR.mat
% load memData.mat
load subjInfo_allROIs.mat
load allActivityMat_17.mat

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

save subjCol.mat subjCol
load subjCol.mat

allCol_noROI = [allcmem,allpmem,mturk_visMem,mturk_lexMem,allcmem_items,subjCol];

save allCol_noROI.mat allCol_noROI

% the question is, do I have to remove rows where lex or vis have NaN?


% then, you make a spreadsheet where allCol_noROI is on every page and
% there's an additional column of ROI-specific activity.
% in RStudio you run lmer on each page separately. Should be able to do
% cmem and pmem one after the other per sheet.

% mturk_cmem_pmem_activity.xlsx


% read this in and see if I can remove rows with NaNs. There are a LOT


mask28 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',1);
mask29 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',2);
mask30 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',3);
mask31 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',4);
mask32 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',5);
mask34 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',6);
mask35 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',7);
mask37 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',8);
mask39 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',9);
mask40 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',10);
mask41 = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',11);
fugL = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',12);
fugR = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',13);
hippL = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',14);
hippR = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',15);
phgL = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',16);
phgR = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx','Sheet',17);


mask28_clean=mask28(~any(ismissing(mask28),2),:);
mask29_clean=mask29(~any(ismissing(mask29),2),:);
mask30_clean=mask30(~any(ismissing(mask30),2),:);
mask31_clean=mask31(~any(ismissing(mask31),2),:);
mask32_clean=mask32(~any(ismissing(mask32),2),:);
mask34_clean=mask34(~any(ismissing(mask34),2),:);
mask35_clean=mask35(~any(ismissing(mask35),2),:);
mask37_clean=mask37(~any(ismissing(mask37),2),:);
mask39_clean=mask39(~any(ismissing(mask39),2),:);
mask40_clean=mask40(~any(ismissing(mask40),2),:);
mask41_clean=mask41(~any(ismissing(mask41),2),:);
fugL_clean=fugL(~any(ismissing(fugL),2),:);
fugR_clean=fugR(~any(ismissing(fugR),2),:);
hippL_clean=hippL(~any(ismissing(hippL),2),:);
hippR_clean=hippR(~any(ismissing(hippR),2),:);
phgL_clean=phgL(~any(ismissing(phgL),2),:);
phgR_clean=phgR(~any(ismissing(phgR),2),:);



writetable(mask28_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',1);
writetable(mask29_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',2);
writetable(mask30_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',3);
writetable(mask31_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',4);
writetable(mask32_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',5);
writetable(mask34_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',6);
writetable(mask35_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',7);
writetable(mask37_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',8);
writetable(mask39_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',9);
writetable(mask40_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',10);
writetable(mask41_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',11);
writetable(fugL_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',12);
writetable(fugR_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',13);
writetable(hippL_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',14);
writetable(hippR_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',15);
writetable(phgL_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',16);
writetable(phgR_clean,'mturk_cmem_pmem_activity.xlsx','Sheet',17);

% mturk_cmem_pmem_activity_full.xlsx  has the NaNs
% mturk_cmem_pmem_activity.xlsx does not

% it goes mask 28, 29, 30, 31, 32, 34, 35, 37, 39, 40, 41,
% fugL, fugR, hippL, hippR, phgL, phgR


% lmer( fmri activity ~ memorability + cmem + (1|subj) + (1|itemID)
% 
% in the cmem variable, we have 0s and 1s. 
% 
% memorability is repeated 19 times to match the 19 0s and 1s in cmem
% itemID is repeated 19 times
% subjID is looped over the 19 subj
