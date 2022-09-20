%% housekeeping
close all
clear
clc

addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12/matlabbatch');
addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/');
addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts/');

%% envioronmental variables
% these things will be/repeated used over and over again
path_main = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/';
subjects = {'S002' 'S005' 'S006' 'S008' 'S009' 'S010' 'S011' 'S013' 'S014' 'S015' 'S016' 'S018' 'S019' 'S021' 'S022' 'S023' 'S024' 'S025' 'S026'};
subject_group = {'S002' 'S005' 'S013' 'S023'};
group_counter = 1; % move through to the next factor group when the next stim group comes
n = length(subjects);
matlabbatch = cell(1, n*2); % need two cells per subject, for model specification and estimation

for counter = 1:n
    subj = subjects{counter};

    % subjects came in four stimulus presentation groups
    % S002
    % S005 through S011
    % S013 through S022
    % S023 through S026
    if subj == 'S005'
        group_counter = 2;
    elseif subj == 'S013'
        group_counter = 3;
    elseif subj == 'S023'
        group_counter = 4;
    end
    subj_group = subject_group{group_counter};
    fprintf('------writing matlabbatch for %s\n', subj)
     
    %%%%%%%% model specification
    % make a subject-specific destination folder
    mkdir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/',subj,'_betas_SPM/'));
    subj_folder = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/',subj,'_betas_SPM/');
    matlabbatch{counter*2-1}.spm.stats.factorial_design.dir = {subj_folder};
    
    %matlabbatch{counter*2-1}.spm.stats.factorial_design.dir = {path_main}; % where the generated SPM.mat will be stored
    % look for nifti files in the subject's folder
    path_scans = fullfile(path_main, 'Encoding_renamed', subj, 'betas_smoothed/');
    files_scan = dir(fullfile(path_scans, '*.nii'))';
    scans = {};
    for file_scan = files_scan
        path_scan = [fullfile(file_scan.folder, file_scan.name), ',1'];
        scans = [scans path_scan];
    end
    matlabbatch{counter*2-1}.spm.stats.factorial_design.des.mreg.scans = scans'; % make col because SPM wants that
    
    scans % eyeball the scans variable to see if it's defined correctly
    %keyboard
    clc % cleans the command window

    
    % add covariates/regressors - 10 factors
    for f = 1:10
        matlabbatch{counter*2-1}.spm.stats.factorial_design.des.mreg.mcov(f).iCC = 1;
        matlabbatch{counter*2-1}.spm.stats.factorial_design.des.mreg.mcov(f).cname = sprintf('f%02d', f); % e.g., 'f01'
        % read factor scores from mat file
        %warning("I'm not sure where the factor files are stored on your computer, so I just used relative paths; change accordingly\n")
        %keyboard
        factors = load(['/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/factor_noTax_subset_' subj_group '.mat']);
        factor_f = factors.(['factor_subset_' subj_group])(:, f); % 300 x 1 double array
        matlabbatch{counter*2-1}.spm.stats.factorial_design.des.mreg.mcov(f).c = factor_f;
        
        clc
        %warning('Need to make sure that the factor scores match up with the scan files for each item. \n')
        %warning('There will likely be <300 scan files if you filter for specific conditions (e.g. encTT3) \n')
        %warning('and that also needs to be reflected here. \n')
        if length(factor_f) ~= length(scans)
            error('different lengths of factor scores and nifti files\n')
        end
        %keyboard
    end

    
    matlabbatch{counter*2-1}.spm.stats.factorial_design.des.mreg.incint = 1;
    matlabbatch{counter*2-1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{counter*2-1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{counter*2-1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{counter*2-1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{counter*2-1}.spm.stats.factorial_design.masking.em = {[path_main '/mask_fMRI.nii,1']};
    matlabbatch{counter*2-1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{counter*2-1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{counter*2-1}.spm.stats.factorial_design.globalm.glonorm = 1;
    

    %%%%%%%% model estimation
    matlabbatch{counter*2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{counter*2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{counter*2}.spm.stats.fmri_est.method.Classical = 1;

end


%% let SPM run jobs
fprintf('Start running SPM \n')
% make sure SPM is on your path
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

