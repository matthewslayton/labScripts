
%%% this is not the most elegant way to do it. Go to 
%%% predict_memorability_2.m

% In this script I am going to attempt to mimic the Hebart 2020 fig 6.
% Hebart, M.N., Zheng, C.Y., Pereira, F. et al. 
% Revealing the multidimensional mental representations of natural objects 
% underlying human similarity judgements. Nat Hum Behav 4, 1173–1185 (2020)
% 
% The goal is to see if we can predict item memorability using the item PCs.
% 

%% Memorability score for each item
% There will be excel files with cols for newCMEM.
% for trials with old items, newCMEM 1-2 would be miss and 3-4 would be hits

subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023'};

for subjects = 1:length(subjectNum) 
    behav_dir = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'));

    % this is a sub-folder in STAMP. (...documents/github/stamp/Behav)
    cmem_col = xlsread(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'AC:AC');
    IDs = xlsread(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'Z:Z');

    % 1,2 = misses. 3,4 = hits. 0 is catch trial. 
    % remove the 0s which are the catch trials and we'll have 300
    
    % not ever cmem with 0s removed has 300 rows to match the IDs from item_betas_filter. So, I
    % need to grab the IDs from the spreadsheet and only fill the rows with
    % non-zero CMEM values
    cmem_noZeros = [];
    IDs_noZeros = [];
    for row = 1:length(cmem_col)
       if cmem_col(row) ~= 0
          cmem_noZeros = [cmem_noZeros,cmem_col(row)];
          IDs_noZeros = [IDs_noZeros,IDs(row)];
       end 
    end
    
    % they have one row, so transpose to get one col
    cmem_noZeros = cmem_noZeros.';
    IDs_noZeros = IDs_noZeros.';
    
    
    % now I need the item IDs in order, just like I did in item_betas_filter.m
    % all_IDs has the items in order for the current subject. 
    % cmem_col has 330 and there are only 300 item IDs. 
    
    memorability = zeros(length(cmem_noZeros),1);
    for number = 1:length(cmem_noZeros)
        if cmem_noZeros(number) == 1 %0 for miss
            memorability(number) = 0;
        elseif cmem_noZeros(number) == 2 
            memorability(number) = 0;
        elseif cmem_noZeros(number) == 3 %1 for hit
            memorability(number) = 1;
        else  %3 for hit
            memorability(number) = 1;
        end
    end

    % load the IDs from item_betas_filter so I can match remembered vs
    % forgotten to the item IDs
    % load(strcat('all_IDs_',subjectNum{subjects},'.mat'));
    % combine remembered vs forgotten with the Item IDs.
    items_and_memTrials = [IDs_noZeros,memorability];
    
    items_and_mem_sorted = sortrows(items_and_memTrials,1);
    
    save(strcat('items_mem_S',subjectNum{subjects}),'items_and_mem_sorted')
    
    %save(strcat('memorabilityInOrder_S',subjectNum{subjects}),'memorability')
  
end
% memorability scores for each item
% take a given item. How many subjects remembered / total subjects

%% take average across subjects for each item

% structs
itemMem_002 = load('items_mem_S002.mat');
itemMem_val_002 = itemMem_002.items_and_mem_sorted;
itemMem_005 = load('items_mem_S005.mat');
itemMem_val_005 = itemMem_005.items_and_mem_sorted;
itemMem_006 = load('items_mem_S006.mat');
itemMem_val_006 = itemMem_006.items_and_mem_sorted;
itemMem_008 = load('items_mem_S008.mat');
itemMem_val_008 = itemMem_008.items_and_mem_sorted;
itemMem_009 = load('items_mem_S009.mat');
itemMem_val_009 = itemMem_009.items_and_mem_sorted;
itemMem_010 = load('items_mem_S010.mat');
itemMem_val_010 = itemMem_010.items_and_mem_sorted;
itemMem_011 = load('items_mem_S011.mat');
itemMem_val_011 = itemMem_011.items_and_mem_sorted;
itemMem_013 = load('items_mem_S013.mat');
itemMem_val_013 = itemMem_013.items_and_mem_sorted;
itemMem_014 = load('items_mem_S014.mat');
itemMem_val_014 = itemMem_014.items_and_mem_sorted;
itemMem_015 = load('items_mem_S015.mat');
itemMem_val_015 = itemMem_015.items_and_mem_sorted;
itemMem_016 = load('items_mem_S016.mat');
itemMem_val_016 = itemMem_016.items_and_mem_sorted;
itemMem_018 = load('items_mem_S018.mat');
itemMem_val_018 = itemMem_018.items_and_mem_sorted;
itemMem_019 = load('items_mem_S019.mat');
itemMem_val_019 = itemMem_019.items_and_mem_sorted;
itemMem_021 = load('items_mem_S021.mat');
itemMem_val_021 = itemMem_021.items_and_mem_sorted;
itemMem_022 = load('items_mem_S022.mat');
itemMem_val_022 = itemMem_022.items_and_mem_sorted;
itemMem_023 = load('items_mem_S023.mat');
itemMem_val_023 = itemMem_023.items_and_mem_sorted;

% not all of these are the same size, so I have to find all the ID numbers
% that have values and add them. For the row that doesn't have a value for
% every subject, I'll have to do an average over a smaller number (so, not
% the total)

% sorted_IDs = sort(IDs);
% all_IDs = []; % match the 360 IDs in sorted_IDs. Each subject does a subset
% % of these. At most 300, but some are less
% for ID = sorted_IDs
%     for row = 1:length(itemMem_val_002)
%         if itemMem_val_002(row,1) == ID
%            all_IDs = [all_IDs,itemMem_val_002(row,2)];
%         else
%            all_IDs = [all_IDs,99]; 
%         end
%     end
%     
% end


% the subjects with 300 items are 002, 005, 006, 008, 009, 013, 014, 016,
% 021

full_memSubj = [mem_val_002,mem_val_005,mem_val_006,mem_val_008,mem_val_009,mem_val_013,mem_val_014,mem_val_016,mem_val_021];
memMean = mean(full_memSubj,2); % this is 300x1. Has a memorability score for all 300 items


%% PCs for each item 
% will be rows from the PCA

load 'all_score.mat' %this is a 995x994 double that contains the 995 score (coordinate) values
% for all 994 PCs. Probably won't use that many, but we have it. The var name is 'score'

itemIDs_tbl = readtable('itemIDs.xlsx'); % this has the item IDs and labels

% need the 300 IDs
IDs_300 = itemMem_val_002(:,1);

indices_inOrder = zeros(length(memMean),1);
for idNumber = 1:length(memMean)
    index = find(itemIDs_tbl{:,2}==IDs_300(idNumber)); %find the four-digit ID num in the second col of the table
    indices_inOrder(idNumber) = index;
end

score_subset = zeros(length(indices_inOrder),994); % all PCs
for row = 1:length(indices_inOrder)
    score_subset(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs

end

% score_subset will have all PCs, in order, with the IDs, which are in
% order in IDs_300

save('score_subset_IDsInOrder','score_subset')

% pc1 => score_subset(:,1)

%% Fit regression model
% between the PCs and the mem scores?

% score_subset(:,1:20); % first 20 PCs
mdl = fitlm(score_subset(:,1:20),memMean);


% R-squared value (proportion of variance explained)
% can tell you how well the model is doing

%% Re-do what's above
% 
% Not all subjects have mem values for all 300 items
% It would be better to look at each item and grab mem values if they're there.
% That way it doesn't matter if there are values for each subject. 
% I can do the average for each item, however many values there are
subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023'};
cmem_col = xlsread(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'AC:AC');
IDs = xlsread(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'Z:Z');

for item = 1:length(IDs)
   IDs(item) 
    
end

memorability = zeros(length(cmem_col),1);
for number = 1:length(cmem_col)
    if cmem_col(number) == 1 %0 for miss
        memorability(number) = 0;
    elseif cmem_col(number) == 2 
        memorability(number) = 0;
    elseif cmem_col(number) == 3 %1 for hit
        memorability(number) = 1;
    elseif cmem_col(number) == 4  %3 for hit
        memorability(number) = 1;
    else
        memorability(number) = NaN; % maybe add NaNs so I can remove them later
    end
end

items_and_cmem = [IDs,cmem_col];
    
items_and_cmem_sorted = sortrows(items_and_cmem,1);

% ****** HERE ******
% Need to go item by item and ask what the memorability scores are, if any



%% Procedure for subtracting
% subtract PCs and run the model again
% or subtract features from the raw featureMatrix and run PCA on that

%% subjects got different models





% these are structs
mem_002 = load('memorabilityInOrder_S002.mat');
mem_val_002 = mem_002.memorability;
mem_005 = load('memorabilityInOrder_S005.mat');
mem_val_005 = mem_005.memorability;
mem_006 = load('memorabilityInOrder_S006.mat');
mem_val_006 = mem_006.memorability;
mem_008 = load('memorabilityInOrder_S008.mat');
mem_val_008 = mem_008.memorability;
mem_009 = load('memorabilityInOrder_S009.mat');
mem_val_009 = mem_009.memorability;
mem_010 = load('memorabilityInOrder_S010.mat');
mem_val_010 = mem_010.memorability;
mem_011 = load('memorabilityInOrder_S011.mat');
mem_val_011 = mem_011.memorability;
mem_013 = load('memorabilityInOrder_S013.mat');
mem_val_013 = mem_013.memorability;
mem_014 = load('memorabilityInOrder_S014.mat');
mem_val_014 = mem_014.memorability;
mem_015 = load('memorabilityInOrder_S015.mat');
mem_val_015 = mem_015.memorability;
mem_016 = load('memorabilityInOrder_S016.mat');
mem_val_016 = mem_016.memorability;
mem_018 = load('memorabilityInOrder_S018.mat');
mem_val_018 = mem_018.memorability;
mem_019 = load('memorabilityInOrder_S019.mat');
mem_val_019 = mem_019.memorability;
mem_021 = load('memorabilityInOrder_S021.mat');
mem_val_021 = mem_021.memorability;
mem_022 = load('memorabilityInOrder_S022.mat');
mem_val_022 = mem_022.memorability;
mem_023 = load('memorabilityInOrder_S023.mat');
mem_val_023 = mem_023.memorability;

