clear
close all
clc

rootDir = 'D:/local/STAMP_Connectivity/';
cd([rootDir 'Scripts']);
addpath([rootDir 'Scripts/utility']);
addpath('D:/local/resources/BCT');

load utility\basics.mat


%% make brain map of IRAF values
V = spm_vol([rootDir, '/brainnetome/BNA_thr25_resliced_43_51_35.nii']);
nvoxel = prod(V.dim);
addpath('D:\local\resources\spm12')

% phases = {'Encoding' 'Retrieval'};
phases = {'Encoding'};

Step4_df_rsa_result = readtable('data/Step4/Networks/Step4_df_rsa_lmer_regtime_all_vggonly.csv');
fig_path = 'Figures_regtime';
if ~exist([rootDir '/' fig_path '/Step4_RSA_vggonly'], 'dir')
    mkdir([rootDir '/' fig_path '/Step4_RSA_vggonly']);
end

% get RDMs from results table
varnames = Step4_df_rsa_result.Properties.VariableNames;
RDMs = extractAfter(varnames(startsWith(varnames, 't_')), 't_')

% write nifti
fullbrain = struct;
for RDM = RDMs; RDM = RDM{1};
    fullbrain.(RDM) = nan(nvoxel, 1);
    % get t values from R result table
    load([rootDir '/brainnetome/BNA246_LOC.mat']);
    for iROI = 1:length(LOC)
        roi = LOC(iROI).roi;
        t = Step4_df_rsa_result.(['t_' RDM])(contains(Step4_df_rsa_result.ROI, LOC(iROI).name));
        fullbrain.(RDM)(roi) = repmat(t, length(roi), 1);
    end

    % reshape brain to 3D
    fullbrain.(RDM) = reshape(fullbrain.(RDM), V.dim(1), V.dim(2), V.dim(3));

    % write nifti
    V.fname = sprintf('%s/%s/Step4_RSA_vggonly/Step4_df_rsa_lmer_regtime_all_%s_%s.nii', rootDir, fig_path, 'Encoding', RDM);
    V.private.dat.fname = V.fname;
    V.descrip = '';
    spm_write_vol(V, fullbrain.(RDM));
    fprintf('----Step 4 created brain map for RSA results with RDM %s\n', RDM);
end

