%-----------------------------------------------------------------------
% Job saved on 29-Aug-2022 20:55:44 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

%% housekeeping
close all
clear all
clc

addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12/matlabbatch');
addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/');
addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts/');

%% envioronmental variables
% these things will be/repeated used over and over again
path_main = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/subjBetas_vis/'; % encycl, fcn, tax, noTax, vis
subjects = {'S002' 'S005' 'S006' 'S008' 'S009' 'S010' 'S011' 'S013' 'S014' 'S015' 'S016' 'S018' 'S019' 'S021' 'S022' 'S023' 'S024' 'S025' 'S026'};

% subjBetas_fcn
% subjBetas_noTax
% subjBetas_tax
% subjBetas_vis

factors = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10'};
n = length(factors);
allSubjScans = cell(length(subjects),10); % ten factors
for counter = 1:length(subjects)
    subj = subjects{counter};
    fprintf('------collecting betas for %s\n', subj)


    % look for nifti files in the subject's folder
    % uses the same code as below for loading scans but we
    % don't actually add these to matlabbatch.
    % these betas need to be sorted first so we have 
    % 19 betas for all subjects per 10 factors
    path_scans = strcat(path_main, subj, '_betas_SPM/');
    files_scan = dir(fullfile(path_scans, '*.nii'))';
    beta_scans = {};
    for file_scan = files_scan
        path_scan = fullfile(file_scan.folder, file_scan.name);
        beta_scans = [beta_scans path_scan];
    end
    % at this point we have everything
    % get only betas 0002 through 0011. Those are the ten factors
    tenScans = beta_scans(4:13);
    allSubjScans(counter,:) = tenScans;

end

% I need to get all the scans read in so I can select them by factor

matlabbatch = cell(1, n*2); % need two cells per subject, for model specification and estimation
for factorCounter = 1:10
    fact = factors{factorCounter};
    fprintf('------collecting betas for Factor %s\n', fact)
   
    %%%%%%%% model specification
    % make a subject-specific destination folder
    subj_folder = strcat(path_main, 'Factor_tMaps/Factor_',fact,'/');
    mkdir(subj_folder);
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.dir = {subj_folder};

% is the reason this isn't working because I change folders?

% doesn't work because the file names are the same so they re-write
    for beta = 1:length(allSubjScans) %19
        currFile = allSubjScans{beta,factorCounter};
        copyfile(currFile,strcat(subj_folder,'/beta_',sprintf('%02d',beta),'.nii'))
    end

    path_scans = subj_folder;
    files_scan = dir(fullfile(path_scans, '*.nii'))';
    scans = {};
    for file_scan = files_scan
        path_scan = fullfile(file_scan.folder, file_scan.name);
        scans = [scans path_scan];
    end
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.des.mreg.scans = scans'; % make col because SPM wants that
    

    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.masking.im = 1;
    %matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{factorCounter*2-1}.spm.stats.factorial_design.globalm.glonorm = 1;

    %%%%%%%% model estimation. t-test needs it too
    matlabbatch{factorCounter*2}.spm.stats.fmri_est.spmmat = {strcat(subj_folder, 'SPM.mat')};
    matlabbatch{factorCounter*2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{factorCounter*2}.spm.stats.fmri_est.method.Classical = 1;
end

%% let SPM run jobs
fprintf('Start running SPM \n')
% make sure SPM is on your path
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

%%% What does spm add to the folder with the 19 subj factor-specific betas?
%%% adds mask.nii, beta_0001.nii, ResMS.nii, RPV.nii, and SPM.mat
%%% I'll want to run Results on SPM.mat to get spmT_0001.nii, but can I
%%% automate? Looks like I can only automate contrasts, mask (none), and FWE. 



%% results
% define contrast
% mask none
% FWE
% then you get spmT_0001.nii


%%% currently I'm doing this manually
%%% each factor has an SPM.mat file
%%% Do Results, contrast = 1, FWE .05, and get spmT_0001.nii
%%% it seems like this stuff below should work
%%% It looks like if I do run the code below (say, on Factor_01 folder),
%%% then SPM.mat does change. However, the t-map I get is not changed.
%%% Btw, if I do Results in the GUI, it makes spmT_0001.nii and con_0001.nii
%%% Also, FWE does not affect the tmap output 


%matlabbatch{1}.spm.stats.results.spmmat = {'/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/SPM.mat'};

% matlabbatch{1}.spm.stats.results.spmmat = {'/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/subjBetas_encycl/Factor_tMaps/Factor_01/SPM.mat'};
% matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
% matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
% matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'FWE';
% matlabbatch{1}.spm.stats.results.conspec.thresh = 0.05;
% matlabbatch{1}.spm.stats.results.conspec.extent = 0;
% matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
% matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
% matlabbatch{1}.spm.stats.results.units = 1;
% matlabbatch{1}.spm.stats.results.export{1}.ps = true;


%% copy tMap files from the factor folders and rename

type = 'vis'; % encycl, fcn, noTax, tax, vis
parentFolder = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/subjBetas_',type,'/Factor_tMaps'); 
cd(parentFolder)

for file = 1:10
    factorFolder = strcat(parentFolder, '/Factor_',sprintf('%02d',file));
    currFile = strcat(factorFolder,'/spmT_0001.nii');
    tmapFolder = strcat(parentFolder,'/all',type,'TMaps/');
    mkdir(tmapFolder);
    copyfile(currFile,strcat(tmapFolder,'spmT_',type,sprintf('_f%02d',file),'.nii'));
end


