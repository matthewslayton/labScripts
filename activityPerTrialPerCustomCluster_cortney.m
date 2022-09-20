addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/NIfTI_20140122

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts/';

% custom masks
maskdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/visLex_CR_masksClean/';
% atlast masks
atlasmaskdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/combined_masks_memOnly';
betadir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/';
outputdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/ROI_clusters/';
%cd (maskdir)
cd (atlasmaskdir)
ROIfiles=dir('*.nii');
ROIlist = {ROIfiles.name}.';
% 19 subjects
sublist = {'S002' 'S005' 'S006' 'S008' 'S009' 'S010' 'S011' 'S013' 'S014' 'S015' 'S016' 'S018' 'S019' 'S021' 'S022' 'S023' 'S024' 'S025' 'S026'};

%sub loop
for cursub = 1:length(sublist)
    sub=cell2mat(sublist(cursub));
    cd (strcat(betadir,sub,'/betas_smoothed/')) 
    betafiles=dir('*.nii');
    betanames = {betafiles.name}.';
    %create empty vector for ROI by beta data for this subject
    ROImeans=zeros(length(betanames),length(ROIlist)+1);
    ROImeans(:,1)=repelem(str2double(extractAfter( sub, 'S' )),length(ROImeans));
    % repelm is repeat copies of array elements

    %mask loop
    
    for curROI = 1:length(ROIlist)
        %pull the mask
        ROI = cell2mat(ROIlist(curROI));
        %curmask = load_untouch_nii(fullfile(maskdir,ROI));
        curmask = load_untouch_nii(fullfile(atlasmaskdir,ROI));
       
        %pull subject betas   
        for curbeta = 1:length(betanames)
            betafile = cell2mat(betanames(curbeta));
            beta = load_untouch_nii(betafile);
       
            %Get the item ID
            ROImeans(curbeta,2)=str2double(extractBetween( betafile, 'Item' , '_' ));
            %get average activity across voxels in the current mask per beta
            ROImeans(curbeta,curROI+2)=mean(beta.img(curmask.img==1));
            
        end
    %end ROI loop
    end

    if cursub==1
        tbl=ROImeans;
        %append sub table to group table
    else
        tbl=[tbl;ROImeans];
    end
%end sub loop
end

%convert to table and name variables for R
tbl=array2table(tbl);
tbl.Properties.VariableNames=[{'subject'};{'item'};erase( ROIlist , '.nii')];
%write table
cd (outputdir)
%writetable(tbl,'clustermeans_cleanMasks.csv');
writetable(tbl,'atlasMaskMeans.csv');

% don't forget that this activity data is complete, so it includes
% the false alarm trials. PCs_betas_lmer_customROIs.m removes those trials

% next step is to go to PCs_betas_lmer_customROIs.m to add the activity
% values to PCs and Factors to prepare for lmer() in R

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Notes from Cortney zoom
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % subject loop
% ROIlist=('mask34.nii');
% for currROI = 1:length(ROIlist)
% % mask loop
% 
% 
% % pull subject betas
% %will need to alter this to be a loop
% 
% % each subject folder has a mat file that describes the betas. load this instead
% % subbetainfo = load('matfile.mat');
% currBeta = load_untouch_nii('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S005/betas_smoothed/s0001-Sess1_Run1_Trial1_Cat8_Item2621_EncTT4_CMEM3_PMEM3_1.nii');
% 
% 
% %gunzip can unzip file. Won't read nii.gz, must be .nii
% ROI=ROIlist;%(currROI);
% maskdir = '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/bothVisLex_CR_betas/';
% 
% currMask = load_untouch_nii(fullfile(maskdir,ROI)); %loads an image as struct
% % spm likes to alter image dimensions. We want to load only
% 
% currImage = currROI.img; %pulls img out of struct. Can also just use currROI.img
% 
% dat=currBeta.img(currImage(:,:,:)=='1',:,:);
% 
% 
% % get average activity across voxels in current mask per trial
% 
% % sort betas by item
% 
% % create sub table
% 
% % end sub loop
% end
% 
% % append sub table to group table
% 
% % write table