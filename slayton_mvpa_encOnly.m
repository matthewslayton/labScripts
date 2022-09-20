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

%% Take care of some set-up
% housekeeping
clear         % remove all stored variables
close all     % close all open windows (e.g., figures)
clc           % clean up the command window

% go to the correct folder and make sure I have access to what I need
cd('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/')
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed') % this has the betas, both smoothed and not smoothed

% save this for when I loop through for all subjects. For now we can just
% do one
%data_dir =
%dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii')); % dir() lists the names of files
% use strcat() when I'm looping through for all subjects
data_dir = '/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S002/betas/'; % just folder, not content yet. dir() gives me the content
all_betas = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S002/betas/*.nii');

% ~~~ % masks, spm, mvpa
data_dir_masks = '/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/';
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/princeton-mvpa-toolbox-master/') % local
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/spm12') %there are important SPM functions in spm12
mvpa_add_paths() %adds relevant subfolders to path

subj = init_subj('stamp', 'S002'); % ('name of experiment','subject')
summarize(subj)

%% Load Mask
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/*.nii')
% Cortney function import_atlas_labels, in FSL_class folder
import_atlas_labels() %atlas labels load as var 'ans', 211x2 table
subj = load_spm_mask(subj,'OcG_L', [data_dir_masks 'OcG_L_4_1.nii']);
% subj = load_spm_mask(subj, 'VT_category-selective', [data_dir 'mask_cat_select_vt.nii']);
% 'VT_category-selective' is what we want to name the maskOr

%% Load fMRI Data
% in the tutorial they read in the 10 functional files
% ~~~ % encoding
livingType = zeros(2,300);
for i=1:300 %150 for Run 1, 150 for Run 2 for 300 betas total per subj
    raw_filenames{i} = [data_dir all_betas(i).name]; 
    % need to get the living or non-living category for these betas
    currFileName = all_betas(i).name;
    if currFileName(27:28) == '1_' 
        livingType(1,i) = 1; % living
    elseif currFileName(27:28) == '5_'
        livingType(1,i) = 1; % living
    elseif currFileName(27:28) == '8_'
        livingType(1,i) = 1; % living
    elseif currFileName(27:28) == '12'
        livingType(1,i) = 1; % living
    else
        livingType(2,i) = 1; %non-living
    end
end

% use load_spm_pattern to read values from the betas, but only save values
% within the mask. Call the saved pattern (within the mask) 'epi'
subj = load_spm_pattern(subj, 'epi', 'OcG_L', raw_filenames);
% the pattern should be a matrix with dims nVox x nTRs

% **** use Run 1 for testing and Run 2 for training

% at this point for S002, patterns epi => 119x150 [nVox x nTRs]
% masks OcG_L 43x51x35 [X x Y x Z], nVox = 119

%% Load functional data
% the toolbox uses the term 'condition regressors' to refer to what we
% would call 'labels.' 
% These tell us about the conditions that each TR belonds to, just like the
% regressor matrix we use in a GLM.
% For the tutorial, the info is in tutorial_regs.mat. This is 8x1210. It's
% just 1s and 0s. There are 8 categories in the tutorial but should be just
% 2 for me, living vs non-living. The 1210 refers to the number of TRs in
% the tutorial experiment. 

%%%
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

% tutorial_regs.mat loads a varaible regs.
regs = livingType;

subj = init_object(subj, 'regressors', 'conds');
% load([data_dir 'tutorial_regs.mat']);
subj = set_mat(subj, 'regressors', 'conds', regs);
condnames = {'living', 'non-living'};
subj = set_objfield(subj, 'regressors', 'conds', 'condnames', condnames);

%% Set up selector (task run info)
% need to know which scanning session each TR comes from. We need that info
% to set up classifier.
% In tutorial that info is in tutorial_runs.mat. It's a 1x1210 matrix with
% integers because they have 1210 TRs. I have 300 and two runs.
% load all files here and use the selector to indicate train vs test
% that info is contained in runs. For me, run1 = train and run2 = test
% Then you flip for cross-validation. 1 predicts 2 and then 2 predicts 1
% Will have as many classifiers as runs

runs = zeros(1,300);
for i = 1:300
    if i < 151
        runs(i) = 1;
    else 
        runs(i) = 2;
    end
end

subj = init_object(subj, 'selector', 'runs');
% load([data_dir 'tutorial_runs.mat']);
subj = set_mat(subj,'selector', 'runs', runs);

%% Pre-classification processing

% ~~~~ % z-score the data to remove baseline shifts between runs
subj = zscore_runs(subj, 'epi', 'runs');

% to check how this looks, set voxel_to_plot to some value, eg 200
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
