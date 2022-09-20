%% Normative study memory data
% want to check diff measures of mem and the single-trial betas

% to use SPM
% on laptop
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');

% on velociraptor
addpath '/Users/matthewslayton/spm12';

addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
memData = readtable('memData.xlsx'); % this is the MTurk data from 566 raters

% these are in alphabetical order
visMem_HR = memData{:,'visual_HR'};
lexMem_HR = memData{:,'lexical_HR'};
visMem_FAR = memData{:,'visual_FAR'};
lexMem_FAR = memData{:,'lexical_FAR'};

% bainbridge calculated Corrected Recognition (CR) = HR – FAR
visMem_CR = visMem_HR - visMem_FAR;
lexMem_CR = lexMem_HR - lexMem_FAR;

save('visMem_CR.mat','visMem_CR')
save('lexMem_CR.mat','lexMem_CR')


%% want the 300 items shown to the subjects
% skip S002 for now
% may as well grab the betas too since I'll need them

% ** the groups are:
% S002
% 005, 006, 008, 009, 010, 011
% 013, 014, 015, 016, 018, 019, 021, 022
% 023, 024, 025, 026

load all_score.mat %loads var 'score'


itemIDs = readtable('itemIDs.xlsx');

% ~~~ % S005 group
betas_S005 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S005/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S005),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S005)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S005(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

% now my indices match presentation order

visMem_HR_subset_S005 = zeros(length(indices_inOrder),1); 
visMem_FAR_subset_S005 = zeros(length(indices_inOrder),1); 
lexMem_HR_subset_S005 = zeros(length(indices_inOrder),1); 
lexMem_FAR_subset_S005 = zeros(length(indices_inOrder),1); 
visMem_CR_subset_S005 = zeros(length(indices_inOrder),1); 
lexMem_CR_subset_S005 = zeros(length(indices_inOrder),1);
PCs_S005 = zeros(length(indices_inOrder),994);

for row = 1:length(indices_inOrder)
    visMem_HR_subset_S005(row,:) = visMem_HR(indices_inOrder(row),:);
    visMem_FAR_subset_S005(row,:) = visMem_FAR(indices_inOrder(row),:);
    lexMem_HR_subset_S005(row,:) = lexMem_HR(indices_inOrder(row),:);
    lexMem_FAR_subset_S005(row,:) = lexMem_FAR(indices_inOrder(row),:);
    visMem_CR_subset_S005(row,:) = visMem_CR(indices_inOrder(row),:);    
    lexMem_CR_subset_S005(row,:) = lexMem_CR(indices_inOrder(row),:);
    PCs_S005(row,:) = score(indices_inOrder(row),:);

end

% save('visMem_HR_subset_S005','visMem_HR_subset_S005')
% save('visMem_FAR_subset_S005','visMem_FAR_subset_S005')
% save('visMem_CR_subset_S005','visMem_CR_subset_S005')
% save('lexMem_HR_subset_S005','lexMem_HR_subset_S005')
% save('lexMem_FAR_subset_S005','lexMem_FAR_subset_S005')
% save('lexMem_CR_subset_S005','lexMem_CR_subset_S005')
save('PCs_S005','PCs_S005')

% ~~~ % S013 group
betas_S013 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S013/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S013),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S013)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S013(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

% now my indices match presentation order

visMem_HR_subset_S013 = zeros(length(indices_inOrder),1); 
visMem_FAR_subset_S013 = zeros(length(indices_inOrder),1);
visMem_CR_subset_S013 = zeros(length(indices_inOrder),1);
lexMem_HR_subset_S013 = zeros(length(indices_inOrder),1); 
lexMem_FAR_subset_S013 = zeros(length(indices_inOrder),1); 
lexMem_CR_subset_S013 = zeros(length(indices_inOrder),1); 
PCs_S013 = zeros(length(indices_inOrder),994);

for row = 1:length(indices_inOrder)
    visMem_HR_subset_S013(row,:) = visMem_HR(indices_inOrder(row),:);
    visMem_FAR_subset_S013(row,:) = visMem_FAR(indices_inOrder(row),:);
    visMem_CR_subset_S013(row,:) = visMem_CR(indices_inOrder(row),:);
    lexMem_HR_subset_S013(row,:) = lexMem_HR(indices_inOrder(row),:);
    lexMem_FAR_subset_S013(row,:) = lexMem_FAR(indices_inOrder(row),:);
    lexMem_CR_subset_S013(row,:) = lexMem_CR(indices_inOrder(row),:);
    PCs_S013(row,:) = score(indices_inOrder(row),:);
end
% 
% save('visMem_HR_subset_S013','visMem_HR_subset_S013')
% save('visMem_FAR_subset_S013','visMem_FAR_subset_S013')
% save('visMem_CR_subset_S013','visMem_CR_subset_S013')
% save('lexMem_HR_subset_S013','lexMem_HR_subset_S013')
% save('lexMem_FAR_subset_S013','lexMem_FAR_subset_S013')
% save('lexMem_CR_subset_S013','lexMem_CR_subset_S013')
save('PCs_S013','PCs_S013')


% ~~~ % S023 group
betas_S023 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S023/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S023),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S023)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S023(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

% now my indices match presentation order

visMem_HR_subset_S023 = zeros(length(indices_inOrder),1); 
visMem_FAR_subset_S023 = zeros(length(indices_inOrder),1);
visMem_CR_subset_S023 = zeros(length(indices_inOrder),1);
lexMem_HR_subset_S023 = zeros(length(indices_inOrder),1); 
lexMem_FAR_subset_S023 = zeros(length(indices_inOrder),1); 
lexMem_CR_subset_S023 = zeros(length(indices_inOrder),1); 
PCs_S023 = zeros(length(indices_inOrder),994);

for row = 1:length(indices_inOrder)
    visMem_HR_subset_S023(row,:) = visMem_HR(indices_inOrder(row),:);
    visMem_FAR_subset_S023(row,:) = visMem_FAR(indices_inOrder(row),:);
    visMem_CR_subset_S023(row,:) = visMem_CR(indices_inOrder(row),:);
    lexMem_HR_subset_S023(row,:) = lexMem_HR(indices_inOrder(row),:);
    lexMem_FAR_subset_S023(row,:) = lexMem_FAR(indices_inOrder(row),:);
    lexMem_CR_subset_S023(row,:) = lexMem_CR(indices_inOrder(row),:);
    PCs_S023(row,:) = score(indices_inOrder(row),:);

end

% save('visMem_HR_subset_S023','visMem_HR_subset_S023')
% save('visMem_FAR_subset_S023','visMem_FAR_subset_S023')
% save('visMem_CR_subset_S023','visMem_CR_subset_S023')
% save('lexMem_HR_subset_S023','lexMem_HR_subset_S023')
% save('lexMem_FAR_subset_S023','lexMem_FAR_subset_S023')
% save('lexMem_CR_subset_S023','lexMem_CR_subset_S023')
save('PCs_S023','PCs_S023')

%% sort betas into new folders
% i have to do this because several lines in lexMem are NaN, so I have to
% have a subset of betas that match ONLY the items that do have values.
% note that S005, S013, and S023 are different


% I'll also need the mem values without NaNs


addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/visLexMem_groups'
load lexMem_HR_subset_S005
load lexMem_HR_subset_S013
load lexMem_HR_subset_S023
load visMem_HR_subset_S005
load visMem_HR_subset_S013
load visMem_HR_subset_S023


load lexMem_CR_subset_S005
load lexMem_CR_subset_S013
load lexMem_CR_subset_S023
load visMem_CR_subset_S005
load visMem_CR_subset_S013
load visMem_CR_subset_S023

% HR
lexMem_HR_S005_SPM = lexMem_HR_subset_S005(~isnan(lexMem_HR_subset_S005));
lexMem_HR_S013_SPM = lexMem_HR_subset_S013(~isnan(lexMem_HR_subset_S013));
lexMem_HR_S023_SPM = lexMem_HR_subset_S023(~isnan(lexMem_HR_subset_S023));

visMem_HR_S005_SPM = visMem_HR_subset_S005(~isnan(lexMem_HR_subset_S005));
visMem_HR_S013_SPM = visMem_HR_subset_S013(~isnan(lexMem_HR_subset_S013));
visMem_HR_S023_SPM = visMem_HR_subset_S023(~isnan(lexMem_HR_subset_S023));

% CR
lexMem_CR_S005_SPM = lexMem_CR_subset_S005(~isnan(lexMem_CR_subset_S005));
lexMem_CR_S013_SPM = lexMem_CR_subset_S013(~isnan(lexMem_CR_subset_S013));
lexMem_CR_S023_SPM = lexMem_CR_subset_S023(~isnan(lexMem_CR_subset_S023));

% match the lex NaNs to make them match when I do the intercept
visMem_CR_S005_SPM = visMem_CR_subset_S005(~isnan(lexMem_CR_subset_S005));
visMem_CR_S013_SPM = visMem_CR_subset_S013(~isnan(lexMem_CR_subset_S013));
visMem_CR_S023_SPM = visMem_CR_subset_S023(~isnan(lexMem_CR_subset_S023));

% also  make sure lex doesn't have any of the NaNs that vis has
% leaves these 241 long
lexMem_CR_S005_SPM_clean = lexMem_CR_S005_SPM(~isnan(visMem_CR_S005_SPM));
lexMem_CR_S013_SPM_clean = lexMem_CR_S013_SPM(~isnan(visMem_CR_S013_SPM));
lexMem_CR_S023_SPM_clean = lexMem_CR_S023_SPM(~isnan(visMem_CR_S023_SPM));

visMem_CR_S005_SPM_clean = visMem_CR_S005_SPM(~isnan(visMem_CR_S005_SPM));
visMem_CR_S013_SPM_clean = visMem_CR_S013_SPM(~isnan(visMem_CR_S013_SPM));
visMem_CR_S023_SPM_clean = visMem_CR_S023_SPM(~isnan(visMem_CR_S023_SPM));


load lexMem_CR_S005_SPM
load lexMem_CR_S013_SPM
load lexMem_CR_S023_SPM
load visMem_CR_S005_SPM
load visMem_CR_S013_SPM
load visMem_CR_S023_SPM


% remove only the vis NaNs to  maximize the amount of data I use
% will be 294 long
% visMem_CR_S005_SPM = visMem_CR_subset_S005(~isnan(visMem_CR_subset_S005));
% visMem_CR_S013_SPM = visMem_CR_subset_S013(~isnan(visMem_CR_subset_S013));
% visMem_CR_S023_SPM = visMem_CR_subset_S023(~isnan(visMem_CR_subset_S023));

% to do interaction of vis and lex, mean center and then multiply
% find the mean of the array and subtract the mean from each value
% I also have to use the subset of vis and lex so we don't have NaNs in lex

% HR
meanCtr_vis_HR_S005 = visMem_HR_S005_SPM - mean(visMem_HR_S005_SPM);
meanCtr_vis_HR_S013 = visMem_HR_S013_SPM - mean(visMem_HR_S013_SPM);
meanCtr_vis_HR_S023 = visMem_HR_S023_SPM - mean(visMem_HR_S023_SPM);

meanCtr_lex_HR_S005 = lexMem_HR_S005_SPM - mean(lexMem_HR_S005_SPM);
meanCtr_lex_HR_S013 = lexMem_HR_S013_SPM - mean(lexMem_HR_S013_SPM);
meanCtr_lex_HR_S023 = lexMem_HR_S023_SPM - mean(lexMem_HR_S023_SPM);

meanCtr_both_HR_S005 = meanCtr_vis_HR_S005 .* meanCtr_lex_HR_S005; % .* multiplies on each element indiv
meanCtr_both_HR_S013 = meanCtr_vis_HR_S013 .* meanCtr_lex_HR_S013; 
meanCtr_both_HR_S023 = meanCtr_vis_HR_S023 .* meanCtr_lex_HR_S023; 

save('meanCtr_both_HR_S005','meanCtr_both_HR_S005')
save('meanCtr_both_HR_S013','meanCtr_both_HR_S013')
save('meanCtr_both_HR_S023','meanCtr_both_HR_S023')

% CR
meanCtr_vis_CR_S005 = visMem_CR_S005_SPM_clean - mean(visMem_CR_S005_SPM_clean);
meanCtr_vis_CR_S013 = visMem_CR_S013_SPM_clean - mean(visMem_CR_S013_SPM_clean);
meanCtr_vis_CR_S023 = visMem_CR_S023_SPM_clean - mean(visMem_CR_S023_SPM_clean);

meanCtr_lex_CR_S005 = lexMem_CR_S005_SPM_clean - mean(lexMem_CR_S005_SPM_clean);
meanCtr_lex_CR_S013 = lexMem_CR_S013_SPM_clean - mean(lexMem_CR_S013_SPM_clean);
meanCtr_lex_CR_S023 = lexMem_CR_S023_SPM_clean - mean(lexMem_CR_S023_SPM_clean);

meanCtr_both_CR_S005 = meanCtr_vis_CR_S005 .* meanCtr_lex_CR_S005; % .* multiplies on each element indiv
meanCtr_both_CR_S013 = meanCtr_vis_CR_S013 .* meanCtr_lex_CR_S013; 
meanCtr_both_CR_S023 = meanCtr_vis_CR_S023 .* meanCtr_lex_CR_S023; 

save('meanCtr_both_CR_S005','meanCtr_both_CR_S005')
save('meanCtr_both_CR_S013','meanCtr_both_CR_S013')
save('meanCtr_both_CR_S023','meanCtr_both_CR_S023')

load meanCtr_both_CR_S005
load meanCtr_both_CR_S013
load meanCtr_both_CR_S023

subjectNum_005 = {'005' '006' '008' '009' '010' '011'};

% lexMem_HR
for subjects = 1:length(subjectNum_005)
    counter = 0;
    data_dir_enc = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_005{subjects},'/betas_smoothed/'); % just folder, not content yet. 
    all_betas_enc = dir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_005{subjects},'/betas_smoothed/*.nii')); % dir gives the file names

    for i = 1:300
       
        cd(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_005{subjects},'/betas_smoothed/'));
    
        source = all_betas_enc(i).name;
        destination_HR = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_005{subjects},'/betas_smoothed_noLexNaN/');
        destination_CR = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_005{subjects},'/betas_smoothed_noLexCRNaN/');
        if isnan(lexMem_HR_subset_S005(i)) % is this value equal to NaN?
            counter = counter + 1;
        else
            copyfile(source,destination_HR); 
        end
        if isnan(lexMem_CR_subset_S005(i))
            counter = counter + 1;
        else
            copyfile(source,destination_CR);
        end
    end
end

subjectNum_013 = {'013' '014' '015' '016' '018' '019' '021' '022'};
for subjects = 1:length(subjectNum_013)
    counter = 0;
    data_dir_enc = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_013{subjects},'/betas_smoothed/'); % just folder, not content yet. 
    all_betas_enc = dir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_013{subjects},'/betas_smoothed/*.nii')); % dir gives the file names

    for i = 1:300
       
        cd(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_013{subjects},'/betas_smoothed/'));
    
        source = all_betas_enc(i).name;
        destination_HR = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_013{subjects},'/betas_smoothed_noLexNaN/');
        destination_CR = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_013{subjects},'/betas_smoothed_noLexCRNaN/');
        if isnan(lexMem_HR_subset_S013(i)) % is this value equal to NaN?
            counter = counter + 1;
        else
            copyfile(source,destination_HR); 
        end
        if isnan(lexMem_CR_subset_S013(i))
            counter = counter + 1;
        else
            copyfile(source,destination_CR);
        end
    end
end

subjectNum_023 = {'023' '024' '025' '026'};
for subjects = 1:length(subjectNum_023)
    counter = 0;
    data_dir_enc = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_023{subjects},'/betas_smoothed/'); % just folder, not content yet. 
    all_betas_enc = dir(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_023{subjects},'/betas_smoothed/*.nii')); % dir gives the file names

    for i = 1:300
       
        cd(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_023{subjects},'/betas_smoothed/'));
    
        source = all_betas_enc(i).name;
        destination_HR = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_023{subjects},'/betas_smoothed_noLexNaN/');
        destination_CR = strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S',subjectNum_023{subjects},'/betas_smoothed_noLexCRNaN/');
        if isnan(lexMem_HR_subset_S023(i)) % is this value equal to NaN?
            counter = counter + 1;
        else
            copyfile(source,destination_HR); 
        end
        if isnan(lexMem_CR_subset_S023(i))
            counter = counter + 1;
        else
            copyfile(source,destination_CR);
        end
    end
end

%% re-do visMem_HR with extra ROI-based mask
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/NIfTI_20140122
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/indiv_masks_resliced/
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/combined_masks/
cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/visMem_masks


% all the masks that I think could have something to do with semantics and
% memory. Should I try visual areas?

% occipital/parietal
cunL = load_untouch_nii('cunL.nii');
cunR = load_untouch_nii('cunR.nii');


% occipital/temporal
fugL = load_untouch_nii('fugL.nii');
fugR = load_untouch_nii('fugR.nii');

% phg -- parahippocampal gyrus
phgL = load_untouch_nii('phgL.nii');
phgR = load_untouch_nii('phgR.nii');
% add missing fields to frontal struct
phg.('hdr') = phgL.hdr;
phg.('filetype') = 2;
phg.('fileprefix') = 'subcortical';
phg.('machine') = 'ieee-le';
phg.('ext') = [];
phg.img = phgL.img+phgR.img;
phg.('untouch') = 1;
% save
save_untouch_nii(phg,'phg.nii')

% subcortical
hippL = load_untouch_nii('hippL.nii');
hippR = load_untouch_nii('hippR.nii');
phgL = load_untouch_nii('phgL.nii');
phgR = load_untouch_nii('phgR.nii');
% add missing fields to frontal struct
subcortical.('hdr') = hippL.hdr;
subcortical.('filetype') = 2;
subcortical.('fileprefix') = 'subcortical';
subcortical.('machine') = 'ieee-le';
subcortical.('ext') = [];
subcortical.img = hippL.img+hippR.img+phgL.img+phgR.img;
subcortical.('untouch') = 1;
% save
save_untouch_nii(subcortical,'subcortical.nii')

subcorticalR.('hdr') = hippL.hdr;
subcorticalR.('filetype') = 2;
subcorticalR.('fileprefix') = 'subcorticalR';
subcorticalR.('machine') = 'ieee-le';
subcorticalR.('ext') = [];
subcorticalR.img = hippR.img+phgR.img;
subcorticalR.('untouch') = 1;
% save
save_untouch_nii(subcorticalR,'subcorticalR.nii')

% frontal
ifgL = load_untouch_nii('ifgL.nii');
ifgR = load_untouch_nii('ifgR.nii');
mfgL = load_untouch_nii('mfgL.nii');
mfgR = load_untouch_nii('mfgR.nii');
% add missing fields to frontal struct
frontal.('hdr') = ifgL.hdr;
frontal.('filetype') = 2;
frontal.('fileprefix') = 'frontal';
frontal.('machine') = 'ieee-le';
frontal.('ext') = [];
frontal.img = ifgL.img+ifgR.img+mfgL.img+mfgR.img;
frontal.('untouch') = 1;
% save
save_untouch_nii(frontal,'frontal.nii')

% parietal
iplL = load_untouch_nii('iplL.nii');
iplR = load_untouch_nii('iplR.nii');
pogL = load_untouch_nii('pogL.nii');
pogR = load_untouch_nii('pogR.nii');
prgL = load_untouch_nii('prgL.nii');
prgR = load_untouch_nii('prgR.nii');
splL = load_untouch_nii('splL.nii');
splR = load_untouch_nii('splR.nii');
% add missing fields to parietal struct
parietal.('hdr') = iplL.hdr;
parietal.('filetype') = 2;
parietal.('fileprefix') = 'parietal';
parietal.('machine') = 'ieee-le';
parietal.('ext') = [];
parietal.img = iplL.img+iplR.img+pogL.img+pogR.img+prgL.img+prgR.img+splL.img+splR.img;
parietal.('untouch') = 1;
% save
save_untouch_nii(parietal,'parietal.nii')

% temporal
itgL = load_untouch_nii('itgL.nii');
itgR = load_untouch_nii('itgR.nii');
mtgL = load_untouch_nii('mtgL.nii');
mtgR = load_untouch_nii('mtgR.nii');
pstsL = load_untouch_nii('pstsL.nii');
pstsR = load_untouch_nii('pstsR.nii');
sfgL = load_untouch_nii('sfgL.nii');
sfgR = load_untouch_nii('sfgR.nii');
stgL = load_untouch_nii('stgL.nii');
stgR = load_untouch_nii('stgR.nii');
% add missing fields to parietal struct
temporal.('hdr') = itgL.hdr;
temporal.('filetype') = 2;
temporal.('fileprefix') = 'temporal';
temporal.('machine') = 'ieee-le';
temporal.('ext') = [];
temporal.img = itgL.img+itgR.img+mtgL.img+mtgR.img+pstsL.img+pstsR.img+sfgL.img+sfgR.img+stgL.img+stgR.img;
temporal.('untouch') = 1;
% save
save_untouch_nii(temporal,'temporal.nii')

temporalR.('hdr') = itgL.hdr;
temporalR.('filetype') = 2;
temporalR.('fileprefix') = 'temporalR';
temporalR.('machine') = 'ieee-le';
temporalR.('ext') = [];
temporalR.img = itgR.img+mtgR.img+pstsR.img+sfgR.img+stgR.img;
temporalR.('untouch') = 1;
% save
save_untouch_nii(temporalR,'temporalR.nii')





