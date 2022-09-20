addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/NIfTI_20140122;
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts;
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/;
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/visLex_CR_masksForMatlab/;
% addpath addpath /Users/matthewslayton/spm12;
cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/;

% load atlas
atlas = load_untouch_nii('BNA_thr25_resliced_43_51_35.nii');


maskdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/visLex_CR_masksForMatlab/';

cd (maskdir)
ROIfiles = dir('*.nii');
ROIlist = {ROIfiles.name}.';


% find the mask voxels and multiply by different integers
%for currROI = 1:length(ROIlist)

currROI = 11; % 1 through 11

ROI = cell2mat(ROIlist(currROI));
currMask = load_untouch_nii(fullfile(maskdir,ROI));
for voxel = 1:numel(atlas.img)
    % use linear indexing
    if atlas.img(voxel) == 0 %not included in the atlas
        currMask.img(voxel) = 0;
    end
end

% I don't know how to automate making the struct and save_nii because you
% can't change the var name each time through a loop
% Maybe I have to make one big one and then split it up later? I'd still
% have to put the var name in save_nii

% create rest of the struct
mask41_clean = struct; % re-label these each time you run these
mask41_clean.('hdr') = currMask.hdr;
mask41_clean.('filetype') = 2;
mask41_clean.('fileprefix') = 'whole';
mask41_clean.('machine') = 'ieee-le';
mask41_clean.('ext') = [];
mask41_clean.('img') = currMask.img;

cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/visLex_CR_masksClean;
save_nii(mask41_clean,'mask41_clean.nii')


%end


