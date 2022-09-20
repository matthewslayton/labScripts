% take a try at running MVPA on the STAMP data
% the goal is to do living vs non-living.

%% To-do
% (1) Make sure I generate separate classifiers, one for each subject.
%I could hypothesize that some representation should be the same across people, but I'll start with per subj
% (2) What's my hypothesis? Is it all Encoding, run 1 predicts run 2 and
% vice versa? Is it ERS, where it's encoding predicting retrieval?
% (3) Can I test more than one mask at a time? 


% I'm trying something out where in addition to ## for a heading,
% I'm going to use % ~~~~ % for a subheading. Maybe it'll help readability?
% to run selection on mac it's fn+shift+f7

% Remember you're training a classifier to look at neural data and assign a
% label of a thing it's trained to distinguish. 
%   Could do:
%   (1) living vs non-living in enc only, in ret only
%   (2) enc vs ret (both living and non-living all together)
%   (3) living (both types) vs non-living (both types)

%% Take care of some set-up
% housekeeping
clear         % remove all stored variables
close all     % close all open windows (e.g., figures)
clc           % clean up the command window

% go to the correct folder and make sure I have access to what I need
cd('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/')
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed') % this has the betas, both smoothed and not smoothed
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval')
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/')
itemIDs_tbl = readtable('itemIDs.xlsx'); % this has all 995 item IDs and labels

% save this for when I loop through for all subjects. For now we can just
% do one
%data_dir =
%dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii')); % dir() lists the names of files
% use strcat() when I'm looping through for all subjects
% ~~~ % encoding
data_dir_enc = '/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S005/betas/'; % just folder, not content yet. 
all_betas_enc = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S005/betas/*.nii'); % dir gives the file names

% ~~~ % retrieval
data_dir_ret = '/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S005/'; % just folder, not content
all_betas_ret = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S005/*.nii');

% ~~~ % masks, spm, mvpa
data_dir_masks = '/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/';
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/princeton-mvpa-toolbox-master/') % local
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/spm12') %there are important SPM functions in spm12
mvpa_add_paths() %adds relevant subfolders to path

subj = init_subj('stamp', 'S005'); % ('name of experiment','subject')
summarize(subj)

%% Load Mask
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/*.nii')
% Cortney function import_atlas_labels, in FSL_class folder
import_atlas_labels() %atlas labels load as var 'ans', 211x2 table
subj = load_spm_mask(subj,'OcG_L', [data_dir_masks 'OcG_L_4_1.nii']);
% subj = load_spm_mask(subj, 'VT_category-selective', [data_dir 'mask_cat_select_vt.nii']);
% 'VT_category-selective' is what we want to name the maskOr

% *** to do multiple masks, just put the whole thing into a for loop. 
% *** if you want to combine multiple ROIs, create a combined ROI mask and use
% the .nii files, or can use the tmp with different ROIs.
% if you're using tmp files, don't use load_spm_pattern() and make sure the
% data structure is the same as you would get with that function


%% Load fMRI Data
% in the tutorial they read in the 10 functional files

% ~~~ % encoding

% not optional
for i = 1:300
    raw_filenames_enc{i} = [data_dir_enc all_betas_enc(i).name];
end

% optional
livingType_enc = zeros(2,300);
for i=1:300 
    catNumCell = extractBetween(all_betas_enc(i).name,'Cat', '_Item'); %we want the category number
    catNum = cell2mat(catNumCell);
    if ismember(catNum, ['1' '5' '8' '12']) == 1 % living
        livingType_enc(1,i) = 1; %living
    else
        livingType_enc(2,i) = 1; % non-living
    end
end

save('livingType_S005.mat','livingType_enc');

% use load_spm_pattern to read values from the betas, but only save values
% within the mask. Call the saved pattern (within the mask) 'epi'
%subj = load_spm_pattern(subj, 'epi_enc', 'OcG_L', raw_filenames_enc);
% the pattern should be a matrix with dims nVox x nTRs

% ~~~ % retrieval

% not optional
load(strcat('IDs_S005withNaN')) % load the IDs of the items that were shown during enc
for i = 1:400
        %%%% need to make this thing 300 long, only adding filenames when
        %%%% IDs equals a number
        if isnan(IDs(i))
            raw_filenames_ret{i} = NaN;  
        else
        raw_filenames_ret{i} = [data_dir_ret all_betas_ret(i).name]; 
        end
end

% remove the values with NaN and you get a 1x300 cell for file names
raw_filenames_ret(cellfun(@(raw_filenames_ret) any(isnan(raw_filenames_ret)),raw_filenames_ret)) = [];

% optional
livingType_ret = zeros(2,300); % set this up for regs
for i=1:300 
    catNumCell = extractBetween(all_betas_ret(i).name,'Cat', '_Item'); %we want the category number
    catNum = cell2mat(catNumCell);
    if ismember(catNum, ['1' '5' '8' '12']) == 1 % living
        livingType_ret(1,i) = 1; %living
    else
        livingType_ret(2,i) = 1; % non-living
    end
end

% raw_filenames_enc and raw_filenames_ret are two cells that have my beta
% file names.

% ~~~ % combine living_type arrays
livingType_all = [livingType_enc livingType_ret]; 
%row 1 is living, row 2 is non-living

% **** if doing just Enc or just Ret, use Run 1 for testing and Run 2 for training

% at this point for S002, patterns epi => 119x600 [nVox x nTRs]
% masks OcG_L 43x51x35 [X x Y x Z], nVox = 119

% ~~~ % mix up the enc and ret filenames so there's 150 of each in both
% halves
% this is good for comparing enc vs ret without livingType AS WELL AS
% comparing living vs non-living with both enc and ret mixed in

% first_half_enc = raw_filenames_enc(1:150);
% second_half_enc = raw_filenames_enc(151:300);
% first_half_ret = raw_filenames_ret(1:150);
% second_half_ret = raw_filenames_ret(151:300);
% 
% first_half = horzcat(first_half_enc,first_half_ret);
% second_half = horzcat(second_half_enc,second_half_ret);
% 
% 
% mixed_filenames_all = horzcat(first_half,second_half);
% subj = load_spm_pattern(subj, 'epi', 'OcG_L', mixed_filenames_all);


% this has all 600 betas.
% one day figure out how not to have a meaningless sub-struct 'patterns' within subj.
% there's only something at 1,1
% these are the betas
% subj.patterns{1,1}.header.vol{1,position} %where 'position' is an int from 1 to 600


% enc
livingType_enc = zeros(3,300);
for i=1:300 
    catNumCell = extractBetween(all_betas_enc(i).name,'Cat', '_Item'); %we want the category number
    catNum = cell2mat(catNumCell);
    if ismember(catNum, ['1' '5' '8' '12']) == 1 % living
        livingType_enc(1,i) = 1; %living
    elseif ismember(catNum, ['2' '6' '10' '13']) == 1 % non-living-big
        livingType_enc(2,i) = 1; % non-living-big
    else
        livingType_enc(3,i) = 1; % non-living-small
    end
end

% ret
livingType_ret = zeros(3,300);
for i=1:300 
    catNumCell = extractBetween(all_betas_ret(i).name,'Cat', '_Item'); %we want the category number
    catNum = cell2mat(catNumCell);
    if ismember(catNum, ['1' '5' '8' '12']) == 1 % living
        livingType_ret(1,i) = 1; %living
    elseif ismember(catNum, ['2' '6' '10' '13']) == 1 % non-living-big
        livingType_ret(2,i) = 1; % non-living-big
    else
        livingType_ret(3,i) = 1; % non-living-small
    end
end

% ~~~ % combine living_type arrays
livingType_all = [livingType_enc livingType_ret]; 
%row 1 is living, row 2 is non-living-big, row 3 is non-living small


% ~~~ % combine the enc and ret filenames

raw_filenames_all = horzcat(raw_filenames_enc,raw_filenames_ret);
% col 1-300 enc, col 301-600 ret

subj = load_spm_pattern(subj, 'epi', 'OcG_L', raw_filenames_all);

%%%
% NOTE: Christina says that on munin there are 12 categories, not 13.
% it looks like category 7 (one of the 'tool' categories) was just a pipe
% can be combined with cat11 for nonliving small tools.
% So, cat1 through 6 are the same as below, but we renumber as:

% cat 7 living, mammal
% cat 8 nl_small musical instruments
% cat 9 nl_big street items
% cat 10 nl_small tools
% cat 11 living vegetable
% cat 12 nl_big vehicle


% ~~~ % need extract the category from the beta file names.
% which categories are living and which non-living?
% use the for loop abovethat loads the fMRI data to get the category
% number. Then make a 2x150 matrix where I put a 1 in the first row if it's
% living and a 1 in the second for if it's non-living. 0 is default

% living
% cat1 (bird)
% cat5 (fruit)
% cat8 (mammal)
% cat12 (vegetable)
% 
% non-living
% cat2 (building)
% cat3 (clothing)
% cat4 (food)
% cat6 (furniture)
% cat7 (tool)
% cat9 (musical instrument)
% cat10 (street items)
% cat11 (tool)
% cat13 (vehicle)


% ~~~ % three different living types

% living: 1, 5, 8, 12 
% non-living-small: 3, 4, 7, 9, 11
% non-living-big: 2, 6, 10, 13

%% Load functional data —— regs
% the toolbox uses the term 'condition regressors' to refer to what we
% would call 'labels.' 
% These tell us about the conditions that each TR belonds to, just like the
% regressor matrix we use in a GLM.
% For the tutorial, the info is in tutorial_regs.mat. This is 8x1210. It's
% just 1s and 0s. There are 8 categories in the tutorial but should be just
% 2 for me, living vs non-living. The 1210 refers to the number of TRs in
% the tutorial experiment. 

% tutorial_regs.mat loads a varaible regs.

% if I want to investigate how well categories hold up across enc and ret,
% just combine enc and ret together (livingType_all)

% living vs non-living
regs = livingType_all;

% % if I want to compare enc and ret, I don't need livingType
% trialType = zeros(2,600);
% 
% for beta = 1:600
%     if beta < 301
%         trialType(1,beta) = 1;
%     else
%         trialType(2,beta) = 1;
%     end
% 
% end
% 
% regs = trialType;

subj = init_object(subj, 'regressors', 'conds');
% load([data_dir 'tutorial_regs.mat']);
subj = set_mat(subj, 'regressors', 'conds', regs);
condnames = {'living', 'non-living'}; % two categories
%condnames = {'enc', 'ret'}; % Enc vs Ret
%condnames = {'living', 'non-living-big', 'non-living-small'}; % three categories
subj = set_objfield(subj, 'regressors', 'conds', 'condnames', condnames);

%% Set up selector (task run info) —— runs
% need to know which scanning session each TR comes from. We need that info
% to set up classifier. Runs tells you the training vs testing data. Only 1
% and 2

% In tutorial that info is in tutorial_runs.mat. It's a 1x1210 matrix with
% integers because they have 1210 TRs. I have 600 and two runs (living vs non-living).
% load all files here and use the selector to indicate train vs test
% that info is contained in runs. For me, run1 = train and run2 = test
% Then you flip for cross-validation. 1 predicts 2 and then 2 predicts 1
% Will have as many classifiers as runs

% Note: this is for if you're doing just one comparison, say, Run 1 vs Run
% 2. Enc had Run 1 and Run 2, Ret has Runs 3, 4, 5, and 6. I think I'd like
% to compare Enc vs Ret.

%sum(livingType_enc,2) = 100,200
%sum(livingType_ret,2) = 100,200
%sum(livingType_all,2) = 200,400

% ~~~ % sort your runs properly so you label the training data with 1
% and the testing data with 2


% ~~~ % this compares enc vs ret, so training on Enc and testing on Ret
% this works whether I'm comparing living vs non-living or not. Either way,
% I'll mix up the enc and ret trials (150 each) so I just need 300 1's and
% 300 2's, and it'll work
total = 600;
runs_600 = zeros(1,total);
for i = 1:total
    if i < (total/2)+1
        runs_600(i) = 1;
    else 
        runs_600(i) = 2;
    end
end


% ~~~ % this is the original code set up for enc run 1 vs run 2
% runs = zeros(1,300);
% for i = 1:300
%     if i < 151
%         runs(i) = 1;
%     else 
%         runs(i) = 2;
%     end
% end

subj = init_object(subj, 'selector', 'runs');
% load([data_dir 'tutorial_runs.mat']);
subj = set_mat(subj,'selector', 'runs', runs_600);


%% Pre-classification processing

% ~~~~ % z-score the data to remove baseline shifts between runs
subj = zscore_runs(subj, 'epi', 'runs');


% to check how this looks, set voxel_to_plot to some value, eg 200Th
voxel_to_plot = 100; 
timecourse_raw = subj.patterns{1}.mat(voxel_to_plot, :)';
timecourse_z = subj.patterns{2}.mat(voxel_to_plot, :)';
figure; 
scatter(timecourse_raw, timecourse_z);
title(['z-scored timecourse against raw timecourse for voxel ' num2str(voxel_to_plot)]);

% ~~~~ % create cross-validation indices
% partition data into n parts and train n different classifiers.
% Each classifier has n-1 parts used for training with 1 left-out part for
% testing
subj_TRselector = create_xvalid_indices(subj, 'runs');

% ~~~~ % then you can take a look at the new selectors:
summarize(subj_TRselector, 'objtype', 'selector');

% there should be two selectors. 1 for training, 2 for testing, which we
% skip in this step
figure; 
selector_to_plot = 1;
imagesc(subj_TRselector.selectors{selector_to_plot}.mat); 
colorbar;
title(['plotting selector ' num2str(selector_to_plot)]);

% ~~~~ % remove unhelpful voxels
% run an ANOVA for each voxel
subj_fs_05 = feature_select(subj_TRselector, 'epi_z', 'conds', 'runs_xval');
% this step gives you additional masks
summarize(subj_fs_05,'objtype','mask')

% default p-value is 0.5, but you can change
subj_fs_thres = feature_select(subj_TRselector, 'epi_z', 'conds', 'runs_xval', 'thresh', .05);

%% Leave-one-run-out cross-validation classification
% ~~~ % use a backpropogation neural network classifier
clf = 'bp'; 
class_args.train_funct_name = ['train_' clf]; 
class_args.test_funct_name = ['test_' clf];
class_args.nHidden = 0; % number of hidden layers in bp neural network

% ~~~ % run cross-validation classification.
[subj_fs_05, results_fs_05] = cross_validation(subj_fs_05, 'epi_z', 'conds', 'runs_xval', 'epi_z_thresh0.05', class_args);

% ~~~~ % how many condition regressors are there per TR?
figure; 

subplot(2,1,1)
imagesc(regs); 
colorbar;
title('8 regressors on each TR');

subplot(2,1,2)
imagesc(sum(regs)); 
colorbar;
title('Sum of regressors on each TR');

% ~~~ % remove rest TRs using selectors
% identify rest TRs
temp_sel = zeros(1, size(regs,2));
temp_sel(sum(regs)==1) = 1;

% create a new 'no_rest' selector object
subj_TRselector_norest = init_object(subj, 'selector', 'no_rest');
subj_TRselector_norest = set_mat(subj_TRselector_norest, 'selector', 'no_rest', temp_sel);
subj_TRselector_norest = create_xvalid_indices(subj_TRselector_norest, 'runs', 'actives_selname', 'no_rest');

% confirm that rest TRs really are removed
regs_norest = regs(:, logical(temp_sel));

figure; 

subplot(2,1,1)
imagesc(regs_norest); 
colorbar;
title('8 regressors on each task TR');

subplot(2,1,2)
imagesc(sum(regs_norest)); 
colorbar;
title('Sum of regressors on each task TR');

% ~~~ % Repeat feature selection and classification with task TRs only
% feature selection
subj_norest_fs_05 = feature_select(subj_TRselector_norest, 'epi_z', 'conds', 'runs_xval');

% use a backpropogation neural network classifier
clf = 'bp'; 
class_args.train_funct_name = ['train_' clf]; 
class_args.test_funct_name = ['test_' clf];
% parameters for the classifier chosen
class_args.nHidden = 0; % number of hidden layers in bp neural network

% classification
[subj_norest_fs_05, results_norest_fs_05] = cross_validation(subj_norest_fs_05, 'epi_z', 'conds', 'runs_xval', 'epi_z_thresh0.05', class_args);






%% Recycling bin

% From Load fMRI Data section
% can I do both enc and ret at once? 
all_betas = [all_betas_enc,all_betas_ret]; % <- can't concatenate these like this because diff sizes
num_betas = 600;
livingType = zeros(2,num_betas);

for i = 1:num_betas

    currFileName = all_betas(i).name;
    catPost = strfind(currFileName,'Cat'); %we want the category number
    if currFileName(catPos+3:catPos+4) == '1_' 
        livingType(1,i) = 1; % living
    elseif currFileName(catPos+3:catPos+4) == '5_'
        livingType(1,i) = 1; % living
    elseif currFileName(catPos+3:catPos+4) == '8_'
        livingType(1,i) = 1; % living
    elseif currFileName(catPos+3:catPos+4) == '12'
        livingType(1,i) = 1; % living
    else
        livingType(2,i) = 1; %non-living
    end
end



livingType_enc = zeros(2,300); % set this up for regs
for i=1:300 %150 for Run 1, 150 for Run 2 for 300 betas total per subj
    %raw_filenames_enc{i} = [data_dir_enc all_betas_enc(i).name]; 
    % need to get the living or non-living category for these betas
    currFileName = all_betas_enc(i).name;
    catPos = strfind(currFileName,'Cat'); %we want the category number
    if currFileName(catPos+3:catPos+4) == '1_' 
        livingType_enc(1,i) = 1; % living
    elseif currFileName(catPos+3:catPos+4) == '5_'
        livingType_enc(1,i) = 1; % living
    elseif currFileName(catPos+3:catPos+4) == '8_'
        livingType_enc(1,i) = 1; % living
    elseif currFileName(catPos+3:catPos+4) == '12'
        livingType_enc(1,i) = 1; % living
    else
        livingType_enc(2,i) = 1; %non-living
    end
end



