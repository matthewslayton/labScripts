% ** the groups are:
% S002
% 005, 006, 008, 009, 010, 011
% 013, 014, 015, 016, 018, 019, 021, 022
% 023, 024, 025, 026


%% Get score subsets for the four item presentation groups

% ~~~ % S002 group

% IDs_enc has the IDs in presentation order
% PCs_S002 is in ascending numerical order just like score
% PCs are in item-name ascending order, just like itemIDs

% I need to grab the PC rows whose name matches the row in itemIDs that
% matches the ID number in IDs_enc

addpath('/Users/matthewslayton/Library/CloudStorage/Box-Box/STAMP/spm12');

% itemIDs has the IDs in item-name alphabetical order
itemIDs = readtable('itemIDs.xlsx');

%betas_S002 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S002/betas_smoothed/*.nii');
betas_S002 = dir('/Users/matthewslayton/Library/CloudStorage/Box-Box/STAMP/Encoding_renamed/S002/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S002),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S002)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S002(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to
    % grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

% now my indices match presentation order

score_subset_S002 = zeros(length(indices_inOrder),994); % all PCs
visMem_subset_S002 = zeros(length(indices_inOrder),1); % all PCs
lexMem_subset_S002 = zeros(length(indices_inOrder),1); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S002(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    visMem_subset_S002(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S002(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs

end


% save(strcat('PCs_subset_S002_Group'),'score_subset_S002')


%betas_S005 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S005/betas_smoothed/*.nii');
betas_S005 = dir('/Users/matthewslayton/Library/CloudStorage/Box-Box/STAMP/Encoding_renamed/S005/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S005),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S005)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S005(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to
    % grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

% now my indices match presentation order

score_subset_S005 = zeros(length(indices_inOrder),994); % all PCs
visMem_subset_S005 = zeros(length(indices_inOrder),1); % all PCs
lexMem_subset_S005 = zeros(length(indices_inOrder),1); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S005(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    visMem_subset_S005(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S005(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs

end


%save(strcat('PCs_subset_S005_Group'),'score_subset_S005')



%betas_S013 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S013/betas_smoothed/*.nii');
betas_S013 = dir('/Users/matthewslayton/Library/CloudStorage/Box-Box/STAMP/Encoding_renamed/S013/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S013),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S013)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S013(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to
    % grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

% now my indices match presentation order

score_subset_S013 = zeros(length(indices_inOrder),994); % all PCs
visMem_subset_S013 = zeros(length(indices_inOrder),1); % all PCs
lexMem_subset_S013 = zeros(length(indices_inOrder),1); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S013(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    visMem_subset_S013(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S013(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs

end


%save(strcat('PCs_subset_S013_Group'),'score_subset_S013')


%betas_S023 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S023/betas_smoothed/*.nii');
betas_S023 = dir('/Users/matthewslayton/Library/CloudStorage/Box-Box/STAMP/Encoding_renamed/S023/betas_smoothed/*.nii');

IDs_enc = cell(numel(betas_S023),1);
indices_inOrder = zeros(300,1);
for row = 1:numel(betas_S023)

    % get the item number that matches presentation order
    IDs_enc{row} = extractBetween(betas_S023(row).name,'Item', '_Enc');

    % get that number out
    currNum = str2double(cell2mat(IDs_enc{row}));

    % where is that item number on the alphabetical item list
    % PCs are alphabetical by name, so this will tell me which PC rows to
    % grab
    index = find(itemIDs{:,2}==currNum); %find the four-digit ID num in the second col of the table
    indices_inOrder(row) = index;

end

% now my indices match presentation order
% S025 has 300. 
score_subset_S023 = zeros(length(indices_inOrder),994); % all PCs
visMem_subset_S023 = zeros(length(indices_inOrder),1); % all PCs
lexMem_subset_S023 = zeros(length(indices_inOrder),1); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S023(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    visMem_subset_S023(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S023(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs

end