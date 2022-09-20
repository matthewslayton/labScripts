% this code prepares factors to be loaded into SPM as covariates for the
% betas
% it shares some similarity with mem_MTurk_betas_masks.m which prepares
% memorability scores to be loaded into SPM as covariates for the betas.
% In that code we had to do a bunch of work to cut out false alarm trials
% and trials where the mem score from the norming study was NaN.
% When it comes to this code we're not dealing with memorability so it's ok
% to ignore that. 
% What that  means is the mem code had all these different subsets of 300,
% whether it was 292, 244, 241, or whatever, and we had to sort the betas
% into special folders to match.

% so, the goal is to get the 300 factor values from the 995-long factor
% array to be loaded as covariates for multiple regression. That gives us
% subject-specific betas, and then we do a t-test on those, get a t-map,
% and use that for eigenvariate analysis with custom ROI masks to determine
% how much each factor determines activity in that region

% ** the groups are:
% 002
% 005, 006, 008, 009, 010, 011
% 013, 014, 015, 016, 018, 019, 021, 022
% 023, 024, 025, 026

% to use SPM
% on laptop
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');

% on velociraptor
addpath '/Users/matthewslayton/spm12';

addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts'

load tenFactors_500features.mat % 995x10

%% need indices to match presentation order
itemIDs = readtable('itemIDs.xlsx');

% ~~~ % S002 group
betas_S002 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S002/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S002),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S002)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S002(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

factors_S002 = zeros(length(indices_inOrder),10);

for row = 1:length(indices_inOrder)
    factors_S002(row,:) = F(indices_inOrder(row),:);
end

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

factors_S005 = zeros(length(indices_inOrder),10);

for row = 1:length(indices_inOrder)
    factors_S005(row,:) = F(indices_inOrder(row),:);
end

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

factors_S013 = zeros(length(indices_inOrder),10);

for row = 1:length(indices_inOrder)
    factors_S013(row,:) = F(indices_inOrder(row),:);
end

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

factors_S023 = zeros(length(indices_inOrder),10);

for row = 1:length(indices_inOrder)
    factors_S023(row,:) = F(indices_inOrder(row),:);
end

save('factors_S002.mat','factors_S002')
save('factors_S005.mat','factors_S005')
save('factors_S013.mat','factors_S013')
save('factors_S023.mat','factors_S023')

load factors_S002.mat
load factors_S005.mat
load factors_S013.mat
load factors_S023.mat


