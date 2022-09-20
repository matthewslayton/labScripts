% (1) Grab the specific item IDs in the betas per trial 
% (2) Find the index of each item in the score matrix (that is items by scores/coordinates, so the cols are the PCs)
% (3) Grab the specific score values for the subset of items in that trial.
% (4) Then we compare the score values for the items in that trial with the beta values for that trial

% featurematrix_4Cortney_withIDs has the item names and ID numbers. ID in a
% separate col. e.g. col 1 is 'accent lamp' and col 2 is '1111'. col 1 name
% is 'concept' and col 2 name is 'id'
% I made a separate file called itemIDs.xlsx.

% Btw
% **Where are the subject's betas?
% ----- STAMP/Encoding_renamed/S0[num]/betas_smoothed.
% Encoding folder came from Cortney. It's the first level data
%
% Where is the PC predicting the betas data?
% ----- STAMP/Folders eg. pc01_smoothedBetas_allSubj
% We take the smoothed subject betas and run a linear model
% to find corr between that PC's score values (derived from the
% covariance matrix of the feature matrix yielding a 995x995
% item array. Each folder has that PC's output beta for
% all subjects

% this is in the STAMP folder. (...documents/github/stamp)
itemIDs_tbl = readtable('itemIDs.xlsx');

%% Grab the item IDs from all of the betas and all of the folders for S002

% make a struct with all the betas
%betas_dir = dir('/Users/matthewslayton/Documents/GitHub/STAMP/S002_betas/*.nii');
% all the betas for subject 2 at encoding

subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};


% importantly, this is based off of featureMat which is in alphabetical
% order
% itemIDs is also in alphabetical order b/c it's just cut and pasted from featurematrix_4Cortney_withIDs
load 'all_score.mat' %this is a 995x994 double that contains the 995 score (coordinate) values
% for all 994 PCs. Probably won't use that many, but we have it. The var name is 'score'

for subjects = 1:length(subjectNum) 

    betas_dir = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding/S',subjectNum{subjects},'/betas/*.nii'));

    % now that I have them, I need to go through one at a time and extract the item IDs
    all_IDs = zeros(numel(betas_dir),1); % make an array of size equal to number of fields in struct
    for filenum = 1:numel(betas_dir) %numel gives me the number of fields in the struct
        all_IDs(filenum) = str2num(cell2mat(extractBetween(betas_dir(filenum).name, 'Item', '_EncTT'))); %extractBetween makes a cell. The ID comes out as a str, so we need to change it to a num before going into the double all_IDs
    end

% I have now extracted all of the item IDs from the struct, stored in a
% 300x1 double
    save(strcat('all_IDs_',subjectNum{subjects}),'all_IDs') %save the IDs for other scripts to use

%% Access the item name-ID table and determine the object order for the betas
    indices_inOrder = zeros(length(all_IDs),1);
    for idNumber = 1:length(all_IDs)
        index = find(itemIDs_tbl{:,2}==all_IDs(idNumber)); %find the four-digit ID num in the second col of the table
        indices_inOrder(idNumber) = index;
    end

    % Now we have a 300x1 double with the rows in the table where the betas'
    % items fall in order. 

%% Save the score values in the order that matches the betas and in some format that is helpful for comparison
    % load 'x_pc1_score_corrFull.mat' % just to one PC for now and I can think about doing more PCs later
    % it loads as x_pc1, which is the score vals (the coordinates) for PC1
    % load 'y_pc2_score_corrFull.mat'
    % load 'z_pc3_score_corrFull.mat'

    % I need to take the values from indices_inOrder and ask which score
    % values are in that row. This should preserve the order of the betas. 
    % The order is arbitrary going into matlab by 'dir' so I need to make
    % sure it goes into SPM in that same order


    % score_subset_pc1 = zeros(length(indices_inOrder),1);
    score_subset = zeros(length(indices_inOrder),994); % all PCs

    for row = 1:length(indices_inOrder)
        %score_subset_pc1(row) = x_pc1(indices_inOrder(row));
        score_subset(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs

    end
   
    % remember that we want all PCs per subject
    save(strcat('score_subset_',subjectNum{subjects}),'score_subset')
    
    % get some subsets of PCs for testing
    % initialize variables
%     first_20_PCs = zeros(300,20);
%     first_100_PCs = zeros(300,100);
%     first_299_PCs = zeros(300,299);
%     % save them
%     save(strcat('score_subset_20_',subjectNum{subjects}),'first_20_PCs')
%     save(strcat('score_subset_100_',subjectNum{subjects}),'first_100_PCs')
%     save(strcat('score_subset_299_',subjectNum{subjects}),'first_299_PCs')
   
end



%% Run the above code and then run ONE of the PC chunks below
% The reason is that this code is really dumb and when I load
% the score subset, it'll rewrite.
% There are two potential solutions to this naming problem
% (1) Table, (2) Struct. I'm really using the wrong data type here
% But, poster submission coming up and I don't want to make a big change.
% Come back and re-do this whole mess

% S002 is its own item order
% S005 through S011 is its own item order
% S013 through S022
% S023 through S026

%% PC1
load('score_subset_002.mat')
pc1_002 = score_subset(:,1);
save('pc1_002.mat','pc1_002');

load('score_subset_005.mat')
pc1_005 = score_subset(:,1);
save('pc1_005.mat','pc1_005');

load('score_subset_006.mat')
pc1_006 = score_subset(:,1);
save('pc1_006.mat','pc1_006');

load('score_subset_008.mat')
pc1_008 = score_subset(:,1);
save('pc1_008.mat','pc1_008');

load('score_subset_009.mat')
pc1_009 = score_subset(:,1);
save('pc1_009.mat','pc1_009');

load('score_subset_010.mat')
pc1_010 = score_subset(:,1);
save('pc1_010.mat','pc1_010');

load('score_subset_011.mat')
pc1_011 = score_subset(:,1);
save('pc1_011.mat','pc1_011');

load('score_subset_013.mat')
pc1_013 = score_subset(:,1);
save('pc1_013.mat','pc1_013');

load('score_subset_014.mat')
pc1_014 = score_subset(:,1);
save('pc1_014.mat','pc1_014');

load('score_subset_015.mat')
pc1_015 = score_subset(:,1);
save('pc1_015.mat','pc1_015');

load('score_subset_016.mat')
pc1_016 = score_subset(:,1);
save('pc1_016.mat','pc1_016');

load('score_subset_018.mat')
pc1_018 = score_subset(:,1);
save('pc1_018.mat','pc1_018');

load('score_subset_019.mat')
pc1_019 = score_subset(:,1);
save('pc1_019.mat','pc1_019');

load('score_subset_021.mat')
pc1_021 = score_subset(:,1);
save('pc1_021.mat','pc1_021');

load('score_subset_022.mat')
pc1_022 = score_subset(:,1);
save('pc1_022.mat','pc1_022');

load('score_subset_023.mat')
pc1_023 = score_subset(:,1);
save('pc1_023.mat','pc1_023');

load('score_subset_024.mat')
pc1_024 = score_subset(:,1);
save('pc1_024.mat','pc1_024');

load('score_subset_025.mat')
pc1_025 = score_subset(:,1);
save('pc1_025.mat','pc1_025');

load('score_subset_026.mat')
pc1_026 = score_subset(:,1);
save('pc1_026.mat','pc1_026');

load('pc1_002.mat')
load('pc1_005.mat')
load('pc1_006.mat')
load('pc1_008.mat')
load('pc1_009.mat')
load('pc1_010.mat')
load('pc1_011.mat')
load('pc1_013.mat')
load('pc1_014.mat')
load('pc1_015.mat')
load('pc1_016.mat')
load('pc1_018.mat')
load('pc1_019.mat')
load('pc1_021.mat')
load('pc1_022.mat')
load('pc1_023.mat')
load('pc1_024.mat')
load('pc1_025.mat')
load('pc1_026.mat')

%% PC2
load('score_subset_002.mat')
pc2_002 = score_subset(:,2);
save('pc2_002.mat','pc2_002');

load('score_subset_005.mat')
pc2_005 = score_subset(:,2);
save('pc2_005.mat','pc2_005');

load('score_subset_006.mat')
pc2_006 = score_subset(:,2);
save('pc2_006.mat','pc2_006');

load('score_subset_008.mat')
pc2_008 = score_subset(:,2);
save('pc2_008.mat','pc2_008');

load('score_subset_009.mat')
pc2_009 = score_subset(:,2);
save('pc2_009.mat','pc2_009');

load('score_subset_010.mat')
pc2_010 = score_subset(:,2);
save('pc2_010.mat','pc2_010');

load('score_subset_011.mat')
pc2_011 = score_subset(:,2);
save('pc2_011.mat','pc2_011');

load('score_subset_013.mat')
pc2_013 = score_subset(:,2);
save('pc2_013.mat','pc2_013');

load('score_subset_014.mat')
pc2_014 = score_subset(:,2);
save('pc2_014.mat','pc2_014');

load('score_subset_015.mat')
pc2_015 = score_subset(:,2);
save('pc2_015.mat','pc2_015');

load('score_subset_016.mat')
pc2_016 = score_subset(:,2);
save('pc2_016.mat','pc2_016');

load('score_subset_018.mat')
pc2_018 = score_subset(:,2);
save('pc2_018.mat','pc2_018');

load('score_subset_019.mat')
pc2_019 = score_subset(:,2);
save('pc2_019.mat','pc2_019');

load('score_subset_021.mat')
pc2_021 = score_subset(:,2);
save('pc2_021.mat','pc2_021');

load('score_subset_022.mat')
pc2_022 = score_subset(:,2);
save('pc2_022.mat','pc2_022');

load('score_subset_023.mat')
pc2_023 = score_subset(:,2);
save('pc2_023.mat','pc2_023');

load('score_subset_024.mat')
pc2_024 = score_subset(:,2);
save('pc2_024.mat','pc2_024');

load('score_subset_025.mat')
pc2_025 = score_subset(:,2);
save('pc2_025.mat','pc2_025');

load('score_subset_026.mat')
pc2_026 = score_subset(:,2);
save('pc2_026.mat','pc2_026');


load('pc2_002.mat')
load('pc2_005.mat')
load('pc2_006.mat')
load('pc2_008.mat')
load('pc2_009.mat')
load('pc2_010.mat')
load('pc2_011.mat')
load('pc2_013.mat')
load('pc2_014.mat')
load('pc2_015.mat')
load('pc2_016.mat')
load('pc2_018.mat')
load('pc2_019.mat')
load('pc2_021.mat')
load('pc2_022.mat')
load('pc2_023.mat')
load('pc2_024.mat')
load('pc2_025.mat')
load('pc2_026.mat')

%% PC3
load('score_subset_002.mat')
pc3_002 = score_subset(:,3);
save('pc3_002.mat','pc3_002');

load('score_subset_005.mat')
pc3_005 = score_subset(:,3);
save('pc3_005.mat','pc3_005');

load('score_subset_006.mat')
pc3_006 = score_subset(:,3);
save('pc3_006.mat','pc3_006');

load('score_subset_008.mat')
pc3_008 = score_subset(:,3);
save('pc3_008.mat','pc3_008');

load('score_subset_009.mat')
pc3_009 = score_subset(:,3);
save('pc3_009.mat','pc3_009');

load('score_subset_010.mat')
pc3_010 = score_subset(:,3);
save('pc3_010.mat','pc3_010');

load('score_subset_011.mat')
pc3_011 = score_subset(:,3);
save('pc3_011.mat','pc3_011');

load('score_subset_013.mat')
pc3_013 = score_subset(:,3);
save('pc3_013.mat','pc3_013');

load('score_subset_014.mat')
pc3_014 = score_subset(:,3);
save('pc3_014.mat','pc3_014');

load('score_subset_015.mat')
pc3_015 = score_subset(:,3);
save('pc3_015.mat','pc3_015');

load('score_subset_016.mat')
pc3_016 = score_subset(:,3);
save('pc3_016.mat','pc3_016');

load('score_subset_018.mat')
pc3_018 = score_subset(:,3);
save('pc3_018.mat','pc3_018');

load('score_subset_019.mat')
pc3_019 = score_subset(:,3);
save('pc3_019.mat','pc3_019');

load('score_subset_021.mat')
pc3_021 = score_subset(:,3);
save('pc3_021.mat','pc3_021');

load('score_subset_022.mat')
pc3_022 = score_subset(:,3);
save('pc3_022.mat','pc3_022');

load('score_subset_023.mat')
pc3_023 = score_subset(:,3);
save('pc3_023.mat','pc3_023');

load('score_subset_024.mat')
pc3_024 = score_subset(:,3);
save('pc3_024.mat','pc3_024');

load('score_subset_025.mat')
pc3_025 = score_subset(:,3);
save('pc3_025.mat','pc3_025');

load('score_subset_026.mat')
pc3_026 = score_subset(:,3);
save('pc3_026.mat','pc3_026');


load('pc3_002.mat')
load('pc3_005.mat')
load('pc3_006.mat')
load('pc3_008.mat')
load('pc3_009.mat')
load('pc3_010.mat')
load('pc3_011.mat')
load('pc3_013.mat')
load('pc3_014.mat')
load('pc3_015.mat')
load('pc3_016.mat')
load('pc3_018.mat')
load('pc3_019.mat')
load('pc3_021.mat')
load('pc3_022.mat')
load('pc3_023.mat')
load('pc3_024.mat')
load('pc3_025.mat')
load('pc3_026.mat')



%% PC4
load('score_subset_002.mat')
pc4_002 = score_subset(:,4);
save('pc4_002.mat','pc4_002');

load('score_subset_005.mat')
pc4_005 = score_subset(:,4);
save('pc4_005.mat','pc4_005');

load('score_subset_006.mat')
pc4_006 = score_subset(:,4);
save('pc4_006.mat','pc4_006');

load('score_subset_008.mat')
pc4_008 = score_subset(:,4);
save('pc4_008.mat','pc4_008');

load('score_subset_009.mat')
pc4_009 = score_subset(:,4);
save('pc4_009.mat','pc4_009');

load('score_subset_010.mat')
pc4_010 = score_subset(:,4);
save('pc4_010.mat','pc4_010');

load('score_subset_011.mat')
pc4_011 = score_subset(:,4);
save('pc4_011.mat','pc4_011');

load('score_subset_013.mat')
pc4_013 = score_subset(:,4);
save('pc4_013.mat','pc4_013');

load('score_subset_014.mat')
pc4_014 = score_subset(:,4);
save('pc4_014.mat','pc4_014');

load('score_subset_015.mat')
pc4_015 = score_subset(:,4);
save('pc4_015.mat','pc4_015');

load('score_subset_016.mat')
pc4_016 = score_subset(:,4);
save('pc4_016.mat','pc4_016');

load('score_subset_018.mat')
pc4_018 = score_subset(:,4);
save('pc4_018.mat','pc4_018');

load('score_subset_019.mat')
pc4_019 = score_subset(:,4);
save('pc4_019.mat','pc4_019');

load('score_subset_021.mat')
pc4_021 = score_subset(:,4);
save('pc4_021.mat','pc4_021');

load('score_subset_022.mat')
pc4_022 = score_subset(:,4);
save('pc4_022.mat','pc4_022');

load('score_subset_023.mat')
pc4_023 = score_subset(:,4);
save('pc4_023.mat','pc4_023');

load('score_subset_024.mat')
pc4_024 = score_subset(:,4);
save('pc4_024.mat','pc4_024');

load('score_subset_025.mat')
pc4_025 = score_subset(:,4);
save('pc4_025.mat','pc4_025');

load('score_subset_026.mat')
pc4_026 = score_subset(:,4);
save('pc4_026.mat','pc4_026');


load('pc4_002.mat')
load('pc4_005.mat')
load('pc4_006.mat')
load('pc4_008.mat')
load('pc4_009.mat')
load('pc4_010.mat')
load('pc4_011.mat')
load('pc4_013.mat')
load('pc4_014.mat')
load('pc4_015.mat')
load('pc4_016.mat')
load('pc4_018.mat')
load('pc4_019.mat')
load('pc4_021.mat')
load('pc4_022.mat')
load('pc4_023.mat')
load('pc4_024.mat')
load('pc4_025.mat')
load('pc4_026.mat')


%% PC5
load('score_subset_002.mat')
pc5_002 = score_subset(:,5);
save('pc5_002.mat','pc5_002');

load('score_subset_005.mat')
pc5_005 = score_subset(:,5);
save('pc5_005.mat','pc5_005');

load('score_subset_005.mat')
pc5_006 = score_subset(:,5);
save('pc5_006.mat','pc5_006');

load('score_subset_008.mat')
pc5_008 = score_subset(:,5);
save('pc5_008.mat','pc5_008');

load('score_subset_009.mat')
pc5_009 = score_subset(:,5);
save('pc5_009.mat','pc5_009');

load('score_subset_010.mat')
pc5_010 = score_subset(:,5);
save('pc5_010.mat','pc5_010');

load('score_subset_011.mat')
pc5_011 = score_subset(:,5);
save('pc5_011.mat','pc5_011');

load('score_subset_013.mat')
pc5_013 = score_subset(:,5);
save('pc5_013.mat','pc5_013');

load('score_subset_014.mat')
pc5_014 = score_subset(:,5);
save('pc5_014.mat','pc5_014');

load('score_subset_015.mat')
pc5_015 = score_subset(:,5);
save('pc5_015.mat','pc5_015');

load('score_subset_016.mat')
pc5_016 = score_subset(:,5);
save('pc5_016.mat','pc5_016');

load('score_subset_018.mat')
pc5_018 = score_subset(:,5);
save('pc5_018.mat','pc5_018');

load('score_subset_019.mat')
pc5_019 = score_subset(:,5);
save('pc5_019.mat','pc5_019');

load('score_subset_021.mat')
pc5_021 = score_subset(:,5);
save('pc5_021.mat','pc5_021');

load('score_subset_022.mat')
pc5_022 = score_subset(:,5);
save('pc5_022.mat','pc5_022');

load('score_subset_023.mat')
pc5_023 = score_subset(:,5);
save('pc5_023.mat','pc5_023');

load('score_subset_024.mat')
pc5_024 = score_subset(:,5);
save('pc5_024.mat','pc5_024');

load('score_subset_025.mat')
pc5_025 = score_subset(:,5);
save('pc5_025.mat','pc5_025');

load('score_subset_026.mat')
pc5_026 = score_subset(:,5);
save('pc5_026.mat','pc5_026');


load('pc5_002.mat')
load('pc5_005.mat')
load('pc5_006.mat')
load('pc5_008.mat')
load('pc5_009.mat')
load('pc5_010.mat')
load('pc5_011.mat')
load('pc5_013.mat')
load('pc5_014.mat')
load('pc5_015.mat')
load('pc5_016.mat')
load('pc5_018.mat')
load('pc5_019.mat')
load('pc5_021.mat')
load('pc5_022.mat')
load('pc5_023.mat')
load('pc5_024.mat')
load('pc5_025.mat')
load('pc5_026.mat')

%% PC6
load('score_subset_002.mat')
pc6_002 = score_subset(:,6);
save('pc6_002.mat','pc6_002');

load('score_subset_005.mat')
pc6_005 = score_subset(:,6);
save('pc6_005.mat','pc6_005');

load('score_subset_005.mat')
pc6_006 = score_subset(:,6);
save('pc6_006.mat','pc6_006');

load('score_subset_008.mat')
pc6_008 = score_subset(:,6);
save('pc6_008.mat','pc6_008');

load('score_subset_009.mat')
pc6_009 = score_subset(:,6);
save('pc6_009.mat','pc6_009');

load('score_subset_010.mat')
pc6_010 = score_subset(:,6);
save('pc6_010.mat','pc6_010');

load('score_subset_011.mat')
pc6_011 = score_subset(:,6);
save('pc6_011.mat','pc6_011');

load('score_subset_013.mat')
pc6_013 = score_subset(:,6);
save('pc6_013.mat','pc6_013');

load('score_subset_014.mat')
pc6_014 = score_subset(:,6);
save('pc6_014.mat','pc6_014');

load('score_subset_015.mat')
pc6_015 = score_subset(:,6);
save('pc6_015.mat','pc6_015');

load('score_subset_016.mat')
pc6_016 = score_subset(:,6);
save('pc6_016.mat','pc6_016');

load('score_subset_018.mat')
pc6_018 = score_subset(:,6);
save('pc6_018.mat','pc6_018');

load('score_subset_019.mat')
pc6_019 = score_subset(:,6);
save('pc6_019.mat','pc6_019');

load('score_subset_021.mat')
pc6_021 = score_subset(:,6);
save('pc6_021.mat','pc6_021');

load('score_subset_022.mat')
pc6_022 = score_subset(:,6);
save('pc6_022.mat','pc6_022');

load('score_subset_023.mat')
pc6_023 = score_subset(:,6);
save('pc6_023.mat','pc6_023');

load('score_subset_024.mat')
pc6_024 = score_subset(:,6);
save('pc6_024.mat','pc6_024');

load('score_subset_025.mat')
pc6_025 = score_subset(:,6);
save('pc6_025.mat','pc6_025');

load('score_subset_026.mat')
pc6_026 = score_subset(:,5);
save('pc6_026.mat','pc6_026');


load('pc6_002.mat')
load('pc6_005.mat')
load('pc6_006.mat')
load('pc6_008.mat')
load('pc6_009.mat')
load('pc6_010.mat')
load('pc6_011.mat')
load('pc6_013.mat')
load('pc6_014.mat')
load('pc6_015.mat')
load('pc6_016.mat')
load('pc6_018.mat')
load('pc6_019.mat')
load('pc6_021.mat')
load('pc6_022.mat')
load('pc6_023.mat')
load('pc6_024.mat')
load('pc6_025.mat')
load('pc6_026.mat')


%% PC7
load('score_subset_002.mat')
pc7_002 = score_subset(:,7);
save('pc7_002.mat','pc7_002');

load('score_subset_005.mat')
pc7_005 = score_subset(:,7);
save('pc7_005.mat','pc7_005');

load('score_subset_005.mat')
pc7_006 = score_subset(:,7);
save('pc7_006.mat','pc7_006');

load('score_subset_008.mat')
pc7_008 = score_subset(:,7);
save('pc7_008.mat','pc7_008');

load('score_subset_009.mat')
pc7_009 = score_subset(:,7);
save('pc7_009.mat','pc7_009');

load('score_subset_010.mat')
pc7_010 = score_subset(:,7);
save('pc7_010.mat','pc7_010');

load('score_subset_011.mat')
pc7_011 = score_subset(:,7);
save('pc7_011.mat','pc7_011');

load('score_subset_013.mat')
pc7_013 = score_subset(:,7);
save('pc7_013.mat','pc7_013');

load('score_subset_014.mat')
pc7_014 = score_subset(:,7);
save('pc7_014.mat','pc7_014');

load('score_subset_015.mat')
pc7_015 = score_subset(:,7);
save('pc7_015.mat','pc7_015');

load('score_subset_016.mat')
pc7_016 = score_subset(:,7);
save('pc7_016.mat','pc7_016');

load('score_subset_018.mat')
pc7_018 = score_subset(:,7);
save('pc7_018.mat','pc7_018');

load('score_subset_019.mat')
pc7_019 = score_subset(:,7);
save('pc7_019.mat','pc7_019');

load('score_subset_021.mat')
pc7_021 = score_subset(:,7);
save('pc7_021.mat','pc7_021');

load('score_subset_022.mat')
pc7_022 = score_subset(:,7);
save('pc7_022.mat','pc7_022');

load('score_subset_023.mat')
pc7_023 = score_subset(:,7);
save('pc7_023.mat','pc7_023');

load('score_subset_024.mat')
pc7_024 = score_subset(:,7);
save('pc7_024.mat','pc7_024');

load('score_subset_025.mat')
pc7_025 = score_subset(:,7);
save('pc7_025.mat','pc7_025');

load('score_subset_026.mat')
pc7_026 = score_subset(:,7);
save('pc7_026.mat','pc7_026');


load('pc7_002.mat')
load('pc7_005.mat')
load('pc7_006.mat')
load('pc7_008.mat')
load('pc7_009.mat')
load('pc7_010.mat')
load('pc7_011.mat')
load('pc7_013.mat')
load('pc7_014.mat')
load('pc7_015.mat')
load('pc7_016.mat')
load('pc7_018.mat')
load('pc7_019.mat')
load('pc7_021.mat')
load('pc7_022.mat')
load('pc7_023.mat')
load('pc7_024.mat')
load('pc7_025.mat')
load('pc7_026.mat')


%% PC8
load('score_subset_002.mat')
pc8_002 = score_subset(:,8);
save('pc8_002.mat','pc8_002');

load('score_subset_005.mat')
pc8_005 = score_subset(:,8);
save('pc8_005.mat','pc8_005');

load('score_subset_005.mat')
pc8_006 = score_subset(:,8);
save('pc8_006.mat','pc8_006');

load('score_subset_008.mat')
pc8_008 = score_subset(:,8);
save('pc8_008.mat','pc8_008');

load('score_subset_009.mat')
pc8_009 = score_subset(:,8);
save('pc8_009.mat','pc8_009');

load('score_subset_010.mat')
pc8_010 = score_subset(:,8);
save('pc8_010.mat','pc8_010');

load('score_subset_011.mat')
pc8_011 = score_subset(:,8);
save('pc8_011.mat','pc8_011');

load('score_subset_013.mat')
pc8_013 = score_subset(:,8);
save('pc8_013.mat','pc8_013');

load('score_subset_014.mat')
pc8_014 = score_subset(:,8);
save('pc8_014.mat','pc8_014');

load('score_subset_015.mat')
pc8_015 = score_subset(:,8);
save('pc8_015.mat','pc8_015');

load('score_subset_016.mat')
pc8_016 = score_subset(:,8);
save('pc8_016.mat','pc8_016');

load('score_subset_018.mat')
pc8_018 = score_subset(:,8);
save('pc8_018.mat','pc8_018');

load('score_subset_019.mat')
pc8_019 = score_subset(:,8);
save('pc8_019.mat','pc8_019');

load('score_subset_021.mat')
pc8_021 = score_subset(:,8);
save('pc8_021.mat','pc8_021');

load('score_subset_022.mat')
pc8_022 = score_subset(:,8);
save('pc8_022.mat','pc8_022');

load('score_subset_023.mat')
pc8_023 = score_subset(:,8);
save('pc8_023.mat','pc8_023');

load('score_subset_024.mat')
pc8_024 = score_subset(:,8);
save('pc8_024.mat','pc8_024');

load('score_subset_025.mat')
pc8_025 = score_subset(:,8);
save('pc8_025.mat','pc8_025');

load('score_subset_026.mat')
pc8_026 = score_subset(:,8);
save('pc8_026.mat','pc8_026');


load('pc8_002.mat')
load('pc8_005.mat')
load('pc8_006.mat')
load('pc8_008.mat')
load('pc8_009.mat')
load('pc8_010.mat')
load('pc8_011.mat')
load('pc8_013.mat')
load('pc8_014.mat')
load('pc8_015.mat')
load('pc8_016.mat')
load('pc8_018.mat')
load('pc8_019.mat')
load('pc8_021.mat')
load('pc8_022.mat')
load('pc8_023.mat')
load('pc8_024.mat')
load('pc8_025.mat')
load('pc8_026.mat')


%% PC9
load('score_subset_002.mat')
pc9_002 = score_subset(:,9);
save('pc9_002.mat','pc9_002');

load('score_subset_005.mat')
pc9_005 = score_subset(:,9);
save('pc9_005.mat','pc9_005');

load('score_subset_005.mat')
pc9_006 = score_subset(:,9);
save('pc9_006.mat','pc9_006');

load('score_subset_008.mat')
pc9_008 = score_subset(:,9);
save('pc9_008.mat','pc9_008');

load('score_subset_009.mat')
pc9_009 = score_subset(:,9);
save('pc9_009.mat','pc9_009');

load('score_subset_010.mat')
pc9_010 = score_subset(:,9);
save('pc9_010.mat','pc9_010');

load('score_subset_011.mat')
pc9_011 = score_subset(:,9);
save('pc9_011.mat','pc9_011');

load('score_subset_013.mat')
pc9_013 = score_subset(:,9);
save('pc9_013.mat','pc9_013');

load('score_subset_014.mat')
pc9_014 = score_subset(:,9);
save('pc9_014.mat','pc9_014');

load('score_subset_015.mat')
pc9_015 = score_subset(:,9);
save('pc9_015.mat','pc9_015');

load('score_subset_016.mat')
pc9_016 = score_subset(:,9);
save('pc9_016.mat','pc9_016');

load('score_subset_018.mat')
pc9_018 = score_subset(:,9);
save('pc9_018.mat','pc9_018');

load('score_subset_019.mat')
pc9_019 = score_subset(:,9);
save('pc9_019.mat','pc9_019');

load('score_subset_021.mat')
pc9_021 = score_subset(:,9);
save('pc9_021.mat','pc9_021');

load('score_subset_022.mat')
pc9_022 = score_subset(:,9);
save('pc9_022.mat','pc9_022');

load('score_subset_023.mat')
pc9_023 = score_subset(:,9);
save('pc9_023.mat','pc9_023');

load('score_subset_024.mat')
pc9_024 = score_subset(:,9);
save('pc9_024.mat','pc9_024');

load('score_subset_025.mat')
pc9_025 = score_subset(:,9);
save('pc9_025.mat','pc9_025');

load('score_subset_026.mat')
pc9_026 = score_subset(:,9);
save('pc9_026.mat','pc9_026');


load('pc9_002.mat')
load('pc9_005.mat')
load('pc9_006.mat')
load('pc9_008.mat')
load('pc9_009.mat')
load('pc9_010.mat')
load('pc9_011.mat')
load('pc9_013.mat')
load('pc9_014.mat')
load('pc9_015.mat')
load('pc9_016.mat')
load('pc9_018.mat')
load('pc9_019.mat')
load('pc9_021.mat')
load('pc9_022.mat')
load('pc9_023.mat')
load('pc9_024.mat')
load('pc9_025.mat')
load('pc9_026.mat')


%% PC10
load('score_subset_002.mat')
pc10_002 = score_subset(:,10);
save('pc10_002.mat','pc10_002');

load('score_subset_005.mat')
pc10_005 = score_subset(:,10);
save('pc10_005.mat','pc10_005');

load('score_subset_005.mat')
pc10_006 = score_subset(:,10);
save('pc10_006.mat','pc10_006');

load('score_subset_008.mat')
pc10_008 = score_subset(:,10);
save('pc10_008.mat','pc10_008');

load('score_subset_009.mat')
pc10_009 = score_subset(:,10);
save('pc10_009.mat','pc10_009');

load('score_subset_010.mat')
pc10_010 = score_subset(:,10);
save('pc10_010.mat','pc10_010');

load('score_subset_011.mat')
pc10_011 = score_subset(:,10);
save('pc10_011.mat','pc10_011');

load('score_subset_013.mat')
pc10_013 = score_subset(:,10);
save('pc10_013.mat','pc10_013');

load('score_subset_014.mat')
pc10_014 = score_subset(:,10);
save('pc10_014.mat','pc10_014');

load('score_subset_015.mat')
pc10_015 = score_subset(:,10);
save('pc10_015.mat','pc10_015');

load('score_subset_016.mat')
pc10_016 = score_subset(:,10);
save('pc10_016.mat','pc10_016');

load('score_subset_018.mat')
pc10_018 = score_subset(:,10);
save('pc10_018.mat','pc10_018');

load('score_subset_019.mat')
pc10_019 = score_subset(:,10);
save('pc10_019.mat','pc10_019');

load('score_subset_021.mat')
pc10_021 = score_subset(:,10);
save('pc10_021.mat','pc10_021');

load('score_subset_022.mat')
pc10_022 = score_subset(:,10);
save('pc10_022.mat','pc10_022');

load('score_subset_023.mat')
pc10_023 = score_subset(:,10);
save('pc10_023.mat','pc10_023');

load('score_subset_024.mat')
pc10_024 = score_subset(:,10);
save('pc10_024.mat','pc10_024');

load('score_subset_025.mat')
pc10_025 = score_subset(:,10);
save('pc10_025.mat','pc10_025');

load('score_subset_026.mat')
pc10_026 = score_subset(:,10);
save('pc10_026.mat','pc10_026');


load('pc10_002.mat')
load('pc10_005.mat')
load('pc10_006.mat')
load('pc10_008.mat')
load('pc10_009.mat')
load('pc10_010.mat')
load('pc10_011.mat')
load('pc10_013.mat')
load('pc10_014.mat')
load('pc10_015.mat')
load('pc10_016.mat')
load('pc10_018.mat')
load('pc10_019.mat')
load('pc10_021.mat')
load('pc10_022.mat')
load('pc10_023.mat')
load('pc10_024.mat')
load('pc10_025.mat')
load('pc10_026.mat')



% pc1_allSubj_job.m 


%% next to do

% compare the score vals per subject with the subject betas







%% Old code, delete later


% test_beta = niftiread('Sess1_Run1_Trial1_Cat9_Item2647_EncTT4_CMEM4_PMEM4_1.nii');
% info = niftiinfo('Sess1_Run1_Trial1_Cat9_Item2647_EncTT4_CMEM4_PMEM4_1.nii');
% info is a struct. Filename has the path and full name, which I'll need to
% get the item ID

%items = itemIDs_all.('concept'); %items is a cell. When you do .('col name') on a table it makes a cell
%ID_numbers = itemIDs_all.('id');

