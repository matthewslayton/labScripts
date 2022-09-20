% read the nifti file in matlab
% find the corresponding voxel positions within PhG
% average them, and save one value

addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/NIfTI_20140122
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/allSubj_10PCs_oneModelPerSubj'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/allSubj_10PCs_oneModelPerSubj/all_tmaps'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/combined_masks'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/indiv_masks_resliced'

%% nii files load as struct
pc01_tmap = load_nii('spmT_pc01.nii');
pc02_tmap = load_nii('spmT_pc02.nii');
pc03_tmap = load_nii('spmT_pc03.nii');
pc04_tmap = load_nii('spmT_pc04.nii');
pc05_tmap = load_nii('spmT_pc05.nii');
pc06_tmap = load_nii('spmT_pc06.nii');
pc07_tmap = load_nii('spmT_pc07.nii');
pc08_tmap = load_nii('spmT_pc08.nii');
pc09_tmap = load_nii('spmT_pc09.nii');
pc10_tmap = load_nii('spmT_pc10.nii');

phgL = load_nii('phgL.nii');
phgR = load_nii('phgR.nii');
phg = load_nii('phg.nii');
fugL = load_nii('fugL.nii');
fugR = load_nii('fugR.nii');
hippL = load_nii('hippL.nii');
hippR = load_nii('hippR.nii');
iplL = load_nii('iplL.nii');
iplR = load_nii('iplR.nii');
ifgL = load_nii('ifgL.nii');
ifgR = load_nii('ifgR.nii');
stgL = load_nii('stgL.nii');
stgR = load_nii('stgR.nii');
splL = load_nii('splL.nii');
splR = load_nii('splR.nii');
cunL = load_nii('cunL.nii');
cunR = load_nii('cunR.nii');
itgL = load_nii('itgL.nii');
itgR = load_nii('itgR.nii');
mfgL = load_nii('mfgL.nii');
mfgR = load_nii('mfgR.nii');
pstsL = load_nii('pstsL.nii');
pstsR = load_nii('pstsR.nii');

% next check all of the PhG masks.
% phgL_6_1 = load_nii('PhG_L_6_1.nii');
% phgL_6_2 = load_nii('PhG_L_6_2.nii');
% phgL_6_3 = load_nii('PhG_L_6_3.nii');
% phgL_6_4 = load_nii('PhG_L_6_4.nii');
% phgL_6_5 = load_nii('PhG_L_6_5.nii');
% phgL_6_6 = load_nii('PhG_L_6_6.nii');
% phgR_6_1 = load_nii('PhG_R_6_1.nii');
% phgR_6_2 = load_nii('PhG_R_6_2.nii');
% phgR_6_3 = load_nii('PhG_R_6_3.nii');
% phgR_6_4 = load_nii('PhG_R_6_4.nii');
% phgR_6_5 = load_nii('PhG_R_6_5.nii');
% phgR_6_6 = load_nii('PhG_R_6_6.nii');

%% get voxel coordinates from mask

% use the linear coordinates
coord = find(phgL.img==1); % <-- change ROI here
coord_zero = find(phgL.img==0);

% ind2sub converts linear coordinates to subscripts
% [i,j,k] = ind2sub(size(phgL.img),find(phgL.img==1));

%% use mask coordinates to grab t-values from t-map
storeValues_pc01 = zeros(length(coord),1);
storeValues_pc02 = zeros(length(coord),1);
storeValues_pc03 = zeros(length(coord),1);
storeValues_pc04 = zeros(length(coord),1);
storeValues_pc05 = zeros(length(coord),1);
storeValues_pc06 = zeros(length(coord),1);
storeValues_pc07 = zeros(length(coord),1);
storeValues_pc08 = zeros(length(coord),1);
storeValues_pc09 = zeros(length(coord),1);
storeValues_pc10 = zeros(length(coord),1);
for coordinate = 1:length(coord)
    storeValues_pc01(coordinate) = pc01_tmap.img(coord(coordinate));
    storeValues_pc02(coordinate) = pc02_tmap.img(coord(coordinate));
    storeValues_pc03(coordinate) = pc03_tmap.img(coord(coordinate));
    storeValues_pc04(coordinate) = pc04_tmap.img(coord(coordinate));
    storeValues_pc05(coordinate) = pc05_tmap.img(coord(coordinate));
    storeValues_pc06(coordinate) = pc06_tmap.img(coord(coordinate));
    storeValues_pc07(coordinate) = pc07_tmap.img(coord(coordinate));
    storeValues_pc08(coordinate) = pc08_tmap.img(coord(coordinate));
    storeValues_pc09(coordinate) = pc09_tmap.img(coord(coordinate));
    storeValues_pc10(coordinate) = pc10_tmap.img(coord(coordinate));
end

%% average the t-map
mean_pc01 = mean(storeValues_pc01);
mean_pc02 = mean(storeValues_pc02);
mean_pc03 = mean(storeValues_pc03);
mean_pc04 = mean(storeValues_pc04);
mean_pc05 = mean(storeValues_pc05);
mean_pc06 = mean(storeValues_pc06);
mean_pc07 = mean(storeValues_pc07);
mean_pc08 = mean(storeValues_pc08);
mean_pc09 = mean(storeValues_pc09);
mean_pc10 = mean(storeValues_pc10);

allMeans = [mean_pc01 mean_pc02 mean_pc03 mean_pc04 mean_pc05 mean_pc06 mean_pc07 mean_pc08 mean_pc09 mean_pc10];
allMeans = allMeans';

%% t-test on voxel-level t values
% are they above 0? Would help test significance
% Then again, if they're all 0.1 we'd get a sig second-order ttest result,
% but 0.1 is not sig.
% need a second order t-test because we want to make a claim at the ROI
% level, not the voxel level

storeValues_pc01

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% average voxel activity in step 1
% one value per ROI



