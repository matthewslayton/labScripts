clear
close all
clc

%rootDir = 'D:/local/STAMP_Connectivity/';
%cd([rootDir 'Scripts']);
%addpath([rootDir 'Scripts/utility']);
addpath /Users/matthewslayton/spm12;
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/NIfTI_20140122/;
rootDir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
addpath = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
cd (rootDir)
addpath '/Users/matthewslayton/BCT'

% custom + atlas
maskdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/visLex_CR_masksClean/';
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/visLex_CR_masksClean/';


% include the custom cleaned masks as well as the six atlas mem masks
cd (maskdir)
ROIfiles = dir('*.nii');
ROIlist = {ROIfiles.name}.';

%% make color brain maps
% find the mask voxels and add t-values
% need 10 brain maps for the 10 factors

% run lmer() in R and then do summary(model) to see t-values
% copy and paste t-values into spreadsheet 

% in R, you migjht run something like avgActivity_customROIs_mem.xlsx or
% avgActivity_customROIs_PC_F.xlsx
% These are output from PCs_betas_lmer_customROIs.m
% This uses activityPerTrialPerCustomCluster_cortney.m to get the activity
% in the specific clusters that I got from making a cluster table using 
% fsl in the command line

%% factors
%tVal_tenIndiv = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/f500_tValues_tenIndiv.xlsx');
%tVal_oneBig = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/f500_tValues_oneBig.xlsx');
tVal_tenIndiv = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/f500_tValues_tenIndiv.xlsx');
tVal_oneBig = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/f500_tValues_oneBig.xlsx');

%% mem
%tVal_twoIndiv = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/custom_atlas_mem_tval.xlsx');
%tVal_oneBig = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/custom_atlas_mem_tVal_oneBig.xlsx');
tVal_bothMem = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothMem_masks.xlsx');
tVal_oneBig = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/tVal_cmem_pmem_lexMem_visMem.xlsx');

%% pick one of these
tVal_mat = table2array(tVal_oneBig);
%tVal_mat = table2array(tVal_tenIndiv);
%tVal_mat = table2array(tVal_twoIndiv);
%tVal_mat = table2array(tVal_bothMem);

% alternatively, combine the 10 separate 3D files to be 4D

%% load random mask for header info
% mem
mask28_clean = load_untouch_nii('mask28_clean.nii');

% create rest of the struct
% conceptual 
mem = struct;
mem.('hdr') = mask28_clean.hdr;
mem.('filetype') = 2;
mem.('fileprefix') = 'whole';
mem.('machine') = 'ieee-le';
mem.('ext') = [];
mem.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,4); % change this second number for the col i want
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                mem.img(voxel) = multMask(voxel);
            end
        end

end
%cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/visLexMem_re-do/allSubj_lex/mapFiles';
%save_nii(conMem,'conMem.nii')

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas'
save_nii(bothMem,'bothMem_tmap.nii')


cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
save_nii(mem,'lexMem_tmap.nii')
save_nii(mem,'cmem_tmap.nii')
save_nii(mem,'visMem_tmap.nii')
save_nii(mem,'pmem_tmap.nii')



mask28_clean = load_untouch_nii('mask28_clean.nii');

% create rest of the struct
factor_01 = struct;
factor_01.('hdr') = mask28_clean.hdr;
factor_01.('filetype') = 2;
factor_01.('fileprefix') = 'whole';
factor_01.('machine') = 'ieee-le';
factor_01.('ext') = [];
factor_01.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 1;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
   % factor_01.img = factor_01.img + multMask;
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_01.img(voxel) = multMask(voxel);
            end
        end

end

% make sure to save the nifti files in this folder
% pick one of these
%cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/factor_brainMaps/;
%cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/factor_maps_clean_oneBigModel/;
%cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/factor_maps_clean_tenIndiv/;
cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/factorMaps_clustersOnly/;
cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/factorMaps_memAtlasROIsOnly/;


save_nii(factor_01,'factor_01.nii')


% mem
mask28_clean = load_untouch_nii('mask28_clean.nii');

% create rest of the struct
% conceptual 
conMem = struct;
conMem.('hdr') = mask28_clean.hdr;
conMem.('filetype') = 2;
conMem.('fileprefix') = 'whole';
conMem.('machine') = 'ieee-le';
conMem.('ext') = [];
conMem.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,1); % col 1 for conceptual
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                conMem.img(voxel) = multMask(voxel);
            end
        end

end
cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/visLexMem_re-do/allSubj_lex/mapFiles';
%save_nii(conMem,'conMem.nii')
save_nii(conMem,'conMem_oneBig.nii')

% perceptual
cd (maskdir)

mask28_clean = load_untouch_nii('mask28_clean.nii');
% create rest of the struct
perMem = struct;
perMem.('hdr') = mask28_clean.hdr;
perMem.('filetype') = 2;
perMem.('fileprefix') = 'whole';
perMem.('machine') = 'ieee-le';
perMem.('ext') = [];
perMem.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,2); % col 2 for perceptual
         for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                perMem.img(voxel) = multMask(voxel);
            end
        end

end

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/visLexMem_re-do/allSubj_vis/mapFiles';
%save_nii(perMem,'perMem.nii')
save_nii(perMem,'perMem_oneBig.nii')

% create rest of the struct
factor_02 = struct;
factor_02.('hdr') = mask28_clean.hdr;
factor_02.('filetype') = 2;
factor_02.('fileprefix') = 'whole';
factor_02.('machine') = 'ieee-le';
factor_02.('ext') = [];
factor_02.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 2;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_02.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_02,'factor_02.nii')

% create rest of the struct
factor_03 = struct;
factor_03.('hdr') = mask28_clean.hdr;
factor_03.('filetype') = 2;
factor_03.('fileprefix') = 'whole';
factor_03.('machine') = 'ieee-le';
factor_03.('ext') = [];
factor_03.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 3;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_03.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_03,'factor_03.nii')

% create rest of the struct
factor_04 = struct;
factor_04.('hdr') = mask28_clean.hdr;
factor_04.('filetype') = 2;
factor_04.('fileprefix') = 'whole';
factor_04.('machine') = 'ieee-le';
factor_04.('ext') = [];
factor_04.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 4;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_04.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_04,'factor_04.nii')

% create rest of the struct
factor_05 = struct;
factor_05.('hdr') = mask28_clean.hdr;
factor_05.('filetype') = 2;
factor_05.('fileprefix') = 'whole';
factor_05.('machine') = 'ieee-le';
factor_05.('ext') = [];
factor_05.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 5;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_05.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_05,'factor_05.nii')

% create rest of the struct
factor_06 = struct;
factor_06.('hdr') = mask28_clean.hdr;
factor_06.('filetype') = 2;
factor_06.('fileprefix') = 'whole';
factor_06.('machine') = 'ieee-le';
factor_06.('ext') = [];
factor_06.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 6;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_06.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_06,'factor_06.nii')


% create rest of the struct
factor_07 = struct;
factor_07.('hdr') = mask28_clean.hdr;
factor_07.('filetype') = 2;
factor_07.('fileprefix') = 'whole';
factor_07.('machine') = 'ieee-le';
factor_07.('ext') = [];
factor_07.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 7;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_07.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_07,'factor_07.nii')

% create rest of the struct
factor_08 = struct;
factor_08.('hdr') = mask28_clean.hdr;
factor_08.('filetype') = 2;
factor_08.('fileprefix') = 'whole';
factor_08.('machine') = 'ieee-le';
factor_08.('ext') = [];
factor_08.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 8;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_08.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_08,'factor_08.nii')

% create rest of the struct
factor_09 = struct;
factor_09.('hdr') = mask28_clean.hdr;
factor_09.('filetype') = 2;
factor_09.('fileprefix') = 'whole';
factor_09.('machine') = 'ieee-le';
factor_09.('ext') = [];
factor_09.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 9;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_09.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_09,'factor_09.nii')

% create rest of the struct
factor_10 = struct;
factor_10.('hdr') = mask28_clean.hdr;
factor_10.('filetype') = 2;
factor_10.('fileprefix') = 'whole';
factor_10.('machine') = 'ieee-le';
factor_10.('ext') = [];
factor_10.('img') = zeros(43,51,35);

% this combines all of the masks that go into one factor
factor = 10;
for currROI = 1:length(ROIlist) % ROIlist goes from mask28 to mask41

    ROI = cell2mat(ROIlist(currROI));
    currMask = load_untouch_nii(fullfile(maskdir,ROI));
    multMask = currMask.img * tVal_mat(currROI,factor);
        for voxel = 1:numel(multMask)
            % use linear indexing
            if multMask(voxel) ~= 0 %not included in the atlas
                factor_10.img(voxel) = multMask(voxel);
            end
        end

end

save_nii(factor_10,'factor_10.nii')

%% failed stuff below

%% make brain map of IRAF values
% load atlas
%V = spm_vol([rootDir, '/BNA_thr25_resliced_43_51_35.nii']);
%nvoxel = prod(V.dim);


% load my visLex interaction masks (28 through 41, or skip 41 and do 28-40)
% these masks have 1s and 0s for in or out of ROI
% need to multiply these by integer so you have unique ints for each mask
% need table of masks and PCs/Fs where number of cols = unique numbers in
% atlas. 
% The atlas is the mergedMemROIs that I then feed into the script that
% adds color

% this is a test. Can I combine my int-mult masks into one nifti file
% after that I do something with the t-values


%addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/indiv_masks_resliced/

%% make integer maps and combine masks
% load random mask for header info
%PcunL_1 = load_untouch_nii('Pcun_L_4_1.nii');

% mask28_clean = load_untouch_nii('mask28_clean.nii');
% % create rest of the struct
% fullbrain = struct;
% %fullbrain.('hdr') = PcunL_1.hdr;
% fullbrain.('hdr') = mask28_clean;
% fullbrain.('filetype') = 2;
% fullbrain.('fileprefix') = 'whole';
% fullbrain.('machine') = 'ieee-le';
% fullbrain.('ext') = [];
% fullbrain.('img') = zeros(43,51,35);
% 
% % find the mask voxels and multiply by different integers
% for currROI = 1:length(ROIlist)
% 
%     ROI = cell2mat(ROIlist(currROI));
%     currMask = load_untouch_nii(fullfile(maskdir,ROI));
%     multMask = currMask.img * currROI;
%     fullbrain.img = fullbrain.img + multMask;

%  end


%% Shenyang code follows below

% fullbrain now has ints where the masks have values
save_nii(fullbrain,'fullbrain.nii')

% write nifti
for RDM = RDMs; RDM = RDM{1};
    %fullbrain.(RDM) = nan(nvoxel, 1);
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




% phases = {'Encoding' 'Retrieval'};
phases = {'Encoding'};

Step4_df_rsa_result = readtable('data/Step4/Networks/Step4_df_rsa_lmer_regtime_all_vggonly.csv');
fig_path = 'Figures_regtime';
if ~exist([rootDir '/' fig_path '/Step4_RSA_vggonly'], 'dir')
    mkdir([rootDir '/' fig_path '/Step4_RSA_vggonly']);
end

% get RDMs from results table
varnames = Step4_df_rsa_result.Properties.VariableNames;
RDMs = extractAfter(varnames(startsWith(varnames, 't_')), 't_');
