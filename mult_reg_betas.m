
% ************************* %
% Don't use this. Go to PCs_betas_multipleRegression.m for single subject
% Go to PCs_betas_multReg_allSubj.m for the same code within a for loop



% SPM is a real pain and I have to run the 2nd level analysis and estimate
% one at a time. Load betas as 'Scans' and load a PC as a 'covariate.'
% I can do multiple PCs with multiple covariates, but is that the same as
% doing them separately? I don't think so.

% subject loop
%   ROI loop 
% the betas are whole-brain, and you use a mask to let only the ROI through
% there's a Ben script that will give you the ROI. You pick an atlas
%   read in betas 
%   read in PCs
%   run regression
%   get the R-sqr val


% load the betas as part of a struct?



subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023'};

for subjects = 1:length(subjectNum) 
    % for ROI 
    betas_dir = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas_smoothed/*.nii'));
    for file = 1:length(betas_dir)
        first_beta = niftiread();
        % how do I read in something like this? Just rename the file?
        % Enc, CMEM, and PMEM keep varying. 
       % s0001-Sess1_Run1_Trial1_Cat9_Item2647_EncTT4_CMEM4_PMEM4_1.nii
    % niftiread()
    % need to get the average voxel info for a given ROI


% need a struct subj, a mask, and all the filenames. Then
% load_spm_pattern() can load the betas
    subj = load_spm_pattern(subj, 'epi', 'OcG_L', raw_filenames_all);

    end 

    % end
end


%% test

data_dir = '/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S002/betas_smoothed/'; % just folder, not content yet. 
betas_dir = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S002/betas_smoothed/*.nii'));
data_dir_masks = '/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/';
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/princeton-mvpa-toolbox-master/') % local
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/spm12') %there are important SPM functions in spm12

% initialize subject struct
subj = init_subj('stamp', 'S002'); % ('name of experiment','subject')

% load mask
subj = load_spm_mask(subj,'OcG_L', [data_dir_masks 'OcG_L_4_1.nii']);

for i=1:300 %150 for Run 1, 150 for Run 2 for 300 betas total per subj
    raw_filenames_enc{i} = [data_dir betas_dir(i).name]; 

end

% load subject betas
subj = load_spm_pattern(subj, 'epi', 'OcG_L', raw_filenames_enc);

% subj.patterns{1,1}.header.vol{1,position}.private %'position' int from 1 to 300
% subj.patterns{1,1}.header.vol{1,1}.private is a nifti object

% load PCs
load 'all_score.mat' %this is a 995x994 double that contains the 995 score (coordinate) values
% for all 994 PCs. Probably won't use that many, but we have it. The var name is 'score'

% run regression
% p = polyfit(PCs,betas) predicts betas froms PCs

pc1 = score(1:300,1);

beta_test = cell2mat(subj.patterns{1,1}.header.vol{1,:}.private);

p = polyfit(pc1,subj.patterns{1,1}.header.vol,2);
