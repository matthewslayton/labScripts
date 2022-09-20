%% Take care of some set-up
clear         % remove all stored variables
close all     % close all open windows (e.g., figures)
clc           % clean up the command window

% go to the correct folder and make sure I have access to what I need
cd('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/')
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed') % this has the betas, both smoothed and not smoothed
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval')
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/')
itemIDs_tbl = readtable('itemIDs.xlsx'); % this has all 995 item IDs and labels
% ~~~ % spm, mvpa
%data_dir_masks = '/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/';
data_dir_masks = '/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/combined_masks/';
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/princeton-mvpa-toolbox-master/') % local
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/spm12') %there are important SPM functions in spm12
mvpa_add_paths() %adds relevant subfolders to path

subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};
% masks
%addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/')
%mask_names = dir('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/*.nii');
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/combined_masks/')
mask_names = dir('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/combined_masks/*.nii');
import_atlas_labels() %atlas labels load as var 'ans'
% create table to store results
%sz = [246*numel(subjectNum) 4]; %246 masks
sz = [30*numel(subjectNum) 4]; % 30 masks
varTypes = ["string","string","double","double"];
varNames = ["Subject","Mask","Results","Results_noRest"];
results_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
counter = 1; % use this to count rows in the results table


for subjects = 1:length(subjectNum)

    % ~ % encoding
    %data_dir_enc = strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/'); % just folder, not content yet. 
    %all_betas_enc = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii')); % dir gives the file names
    
    data_dir_enc = strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas_smoothed/'); % just folder, not content yet. 
    all_betas_enc = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas_smoothed/*.nii')); % dir gives the file names
    
    % ~ % retrieval
    data_dir_ret = strcat('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S',subjectNum{subjects},'/'); % just folder, not content
    all_betas_ret = dir(strcat('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S',subjectNum{subjects},'/*.nii'));
   
    % subj = init_subj('stamp', strcat('S',subjectNum{subjects})); % ('name of experiment','subject')
    % summarize(subj)

    % ~~~ % load mask
    for maskNum = 1:numel(mask_names)
        subj = init_subj('stamp', strcat('S',subjectNum{subjects})); % ('name of experiment','subject')
        current_mask_name = mask_names(maskNum).name; % still has numbers and extension
        %nameOnly = current_mask_name(1:end-8); % just the name, no numbers or extension
        nameOnly = current_mask_name(1:end-4); % just the name, no numbers or extension
        subj = load_spm_mask(subj,nameOnly, [data_dir_masks current_mask_name]);

        %% load fmri data

        % ~ % encoding
        
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

        % ~ % retrieval
        
        % not optional
        % these come from /Users/matthewslayton/Documents/GitHub/STAMP/STAMP_scripts/predict_mem_5_retrieval_pmem.m
        load(strcat('IDs_S',subjectNum{subjects},'withNaN')) % load the IDs of the items that were shown during enc
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
        % ~ % combine living_type arrays
        % row 1 is living, row 2 is non-living
        livingType_all = [livingType_enc livingType_ret]; 

        % ~ % combine the enc and ret filenames

        % col 1-300 enc, col 301-600 ret
        raw_filenames_all = horzcat(raw_filenames_enc,raw_filenames_ret);
        
        subj = load_spm_pattern(subj, 'epi', nameOnly, raw_filenames_all);

        %% set up regressors
        regs = livingType_all;

        subj = init_object(subj, 'regressors', 'conds');
        subj = set_mat(subj, 'regressors', 'conds', regs);
        condnames = {'living', 'non-living'}; % two categories
        subj = set_objfield(subj, 'regressors', 'conds', 'condnames', condnames);

        %% set up runs
        total = 600;
        runs_600 = zeros(1,total);
        for i = 1:total
            if i < (total/2)+1
                runs_600(i) = 1;
            else 
                runs_600(i) = 2;
            end
        end

        subj = init_object(subj, 'selector', 'runs');
        subj = set_mat(subj,'selector', 'runs', runs_600);

        %% Pre-classification processing

        
        % ~ % z-score the data to remove baseline shifts between runs
        subj = zscore_runs(subj,'epi', 'runs');
        
        % ~ % create cross-validation indices
        % partition data into n parts and train n different classifiers.
        % Each classifier has n-1 parts used for training with 1 left-out part for
        % testing
        subj_TRselector = create_xvalid_indices(subj, 'runs');

        % ~ % remove unhelpful voxels
        % run an ANOVA for each voxel
        subj_fs_05 = feature_select(subj_TRselector,'epi_z', 'conds', 'runs_xval');
        % this step gives you additional masks
        %summarize(subj_fs_05,'objtype','mask')
        
        % default p-value is 0.5, but you can change
        subj_fs_thres = feature_select(subj_TRselector, 'epi_z', 'conds', 'runs_xval', 'thresh', .05);
        
        %% Leave-one-run-out cross-validation classification
        % ~ % use a backpropogation neural network classifier
        clf = 'bp'; 
        class_args.train_funct_name = ['train_' clf]; 
        class_args.test_funct_name = ['test_' clf];
        class_args.nHidden = 0; % number of hidden layers in bp neural network
        
        % ~ % run cross-validation classification.
        [subj_fs_05, results_fs_05] = cross_validation(subj_fs_05,'epi_z', 'conds', 'runs_xval', 'epi_z_thresh0.05', class_args);

        % ~ % remove rest TRs using selectors
        % identify rest TRs
        temp_sel = zeros(1, size(regs,2));
        temp_sel(sum(regs)==1) = 1;
        
        % create a new 'no_rest' selector object
        subj_TRselector_norest = init_object(subj, 'selector', 'no_rest');
        subj_TRselector_norest = set_mat(subj_TRselector_norest, 'selector', 'no_rest', temp_sel);
        subj_TRselector_norest = create_xvalid_indices(subj_TRselector_norest, 'runs', 'actives_selname', 'no_rest');
        
        % confirm that rest TRs really are removed
        regs_norest = regs(:, logical(temp_sel));

        % ~ % Repeat feature selection and classification with task TRs only
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

        % these are the outputs. I want to save them
        results_tbl(counter,:) = {strcat('S',subjectNum{subjects}),nameOnly,results_fs_05.total_perf,results_norest_fs_05.total_perf};
        counter = counter + 1;
        clear subj % clearvars [indiv vars]
    end

end

%% test for significance
% need to do a one-sample t-test to see if the classification is
% significantly greater than the chance level of 0.5
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/')
results_tbl_spreadsheet = readtable('30ROI_betas_smoothed_mvpa_living_nonliving_encRet_table.xlsx'); % or 240ROI_
results_col = results_tbl_spreadsheet{:,'Results'};
results_mask = removevars(results_tbl_spreadsheet,{'Subject','Results_noRest'});
results_mask_only = results_tbl_spreadsheet{:,'Mask'};


% ~ % set the mask number first
%maskNum = 246;
maskNum = 30;
% There are 18 results per ROI, so I run a t-test on those values to see if
% they are significantly larger than 0.5 (which is chance)

% first set up the table that will hold all the p-values
sz = [maskNum 2]; %246 or 30 masks so far
varTypes = ["string","double"];
varNames = ["Mask_Name","p-value"];
ttest_tbl = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
tbl_counter = 1; % use this to count rows in the results table

% grab 18 results at a time, run a t-test, and store the p-value in a
% table
counter = 1;
for ROI = 1:maskNum
    curr_roi = results_col(counter:counter+18);
    [~,p]= ttest(curr_roi,0.5);
    currName = results_mask_only{counter};
    nameOnly = currName(1:end-4); % just the name, no numbers or extension
    ttest_tbl(tbl_counter,:) = {nameOnly,p};
    counter = counter+19;
    tbl_counter = tbl_counter + 1;
end

% generates a table of ROI names and p-values. After correcting for
% multiple comparisons, you can see if any ROIs were consistently about
% chance
p_vals = ttest_tbl{:,'p-value'};

% bonferroni-holm correction
%bonf_holm(pvalues,alpha) 
% don't forget to add path
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/bonf_holm')
[cor_p, h] = bonf_holm(p_vals,.05);

% false discovery rate
corrected_p = mafdr(p_vals);

% ~ % for 30 masks
% There are still 18 results per 
% none of that shit I wrote below is true. I'm going to delete it 

% Instead of grouping results 






