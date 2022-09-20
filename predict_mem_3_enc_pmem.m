% Not all subjects have mem values for all 300 items
% It would be better to look at each item and grab mem values if they're there.
% That way it doesn't matter if there are values for each subject. 
% I can do the average for each item, however many values there are

% wants me to be in /Documents/Github/STAMP
% should try to save things in STAMP_2 because STAMP won't seem to load 
subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

% cmem is pics at enc, words at ret
% pmem is pic, pic

% for newret nerCMEM is Z and newPMEM is AA

for subjects = 1:length(subjectNum) 
    
    %pmem_col = xlsread(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'AD:AD');
    %IDs = xlsread(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'Z:Z');
   
    pmem_col = xlsread(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'AD:AD');
    IDs = xlsread(strcat('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Behav/S',subjectNum{subjects},'/newencS', subjectNum{subjects},'_final2.xlsx'),'Z:Z');


% for newret nerCMEM is Z and newPMEM is AA

    % process CMEM. Want 0 for miss (1 and 2), 1 for hit (3 and 4), and NaN
    % for catch trial to be removed later
    
    memorability = zeros(length(pmem_col),1);
    for number = 1:length(pmem_col)
        if pmem_col(number) == 1 %0 for miss
            memorability(number) = 0;
        elseif pmem_col(number) == 2 
            memorability(number) = 0;
        elseif pmem_col(number) == 3 %1 for hit
            memorability(number) = 1;
        elseif pmem_col(number) == 4  %3 for hit
            memorability(number) = 1;
        else
            memorability(number) = NaN; % maybe add NaNs so I can remove them later
        end
    end
    
    items_and_pmemMem = [IDs,memorability];
    items_and_pmem_sorted = sortrows(items_and_pmemMem,1);
    
    save(strcat('items_pmem_S',subjectNum{subjects}),'items_and_pmem_sorted')
    
end

%% take average across subjects for each item
itemMem_002 = load('items_pmem_S002.mat'); %loads as a struct
itemMem_val_002_long = itemMem_002.items_and_pmem_sorted; %have to get the data out of the struct
itemMem_val_002 = itemMem_val_002_long(1:330,:);
% 002 has four values where every other subject has NaN. 
% must be an error. It's also keeping me from running the regression.
% I need 300 rows exactly. So, rows 109, 201, 241, 317 will change to NaN
itemMem_val_002(109,2) = NaN;
itemMem_val_002(201,2) = NaN;
itemMem_val_002(241,2) = NaN;
itemMem_val_002(317,2) = NaN;



% the rest of these have NaNs for rows 331-360. I'll cut them out
itemMem_005 = load('items_pmem_S005.mat');
itemMem_val_005_long = itemMem_005.items_and_pmem_sorted;
itemMem_val_005 = itemMem_val_005_long(1:330,:);
itemMem_006 = load('items_pmem_S006.mat');
itemMem_val_006_long = itemMem_006.items_and_pmem_sorted;
itemMem_val_006 = itemMem_val_006_long(1:330,:);
itemMem_008 = load('items_pmem_S008.mat');
itemMem_val_008_long = itemMem_008.items_and_pmem_sorted;
itemMem_val_008 = itemMem_val_008_long(1:330,:);
itemMem_009 = load('items_pmem_S009.mat');
itemMem_val_009_long = itemMem_009.items_and_pmem_sorted;
itemMem_val_009 = itemMem_val_009_long(1:330,:);
itemMem_010 = load('items_pmem_S010.mat');
itemMem_val_010_long = itemMem_010.items_and_pmem_sorted;
itemMem_val_010 = itemMem_val_010_long(1:330,:);
itemMem_011 = load('items_pmem_S011.mat');
itemMem_val_011_long = itemMem_011.items_and_pmem_sorted;
itemMem_val_011 = itemMem_val_011_long(1:330,:);
itemMem_013 = load('items_pmem_S013.mat');
itemMem_val_013_long = itemMem_013.items_and_pmem_sorted;
itemMem_val_013 = itemMem_val_013_long(1:330,:);
itemMem_014 = load('items_pmem_S014.mat');
itemMem_val_014_long = itemMem_014.items_and_pmem_sorted;
itemMem_val_014 = itemMem_val_014_long(1:330,:);
itemMem_015 = load('items_pmem_S015.mat');
itemMem_val_015_long = itemMem_015.items_and_pmem_sorted;
itemMem_val_015 = itemMem_val_015_long(1:330,:);
itemMem_016 = load('items_pmem_S016.mat');
itemMem_val_016_long = itemMem_016.items_and_pmem_sorted;
itemMem_val_016 = itemMem_val_016_long(1:330,:);
itemMem_018 = load('items_pmem_S018.mat');
itemMem_val_018_long = itemMem_018.items_and_pmem_sorted;
itemMem_val_018 = itemMem_val_018_long(1:330,:);
itemMem_019 = load('items_pmem_S019.mat');
itemMem_val_019_long = itemMem_019.items_and_pmem_sorted;
itemMem_val_019 = itemMem_val_019_long(1:330,:);
itemMem_021 = load('items_pmem_S021.mat');
itemMem_val_021_long = itemMem_021.items_and_pmem_sorted;
itemMem_val_021 = itemMem_val_021_long(1:330,:);
itemMem_022 = load('items_pmem_S022.mat');
itemMem_val_022_long = itemMem_022.items_and_pmem_sorted;
itemMem_val_022 = itemMem_val_022_long(1:330,:);
itemMem_023 = load('items_pmem_S023.mat');
itemMem_val_023_long = itemMem_023.items_and_pmem_sorted;
itemMem_val_023 = itemMem_val_023_long(1:330,:);

full_memSubj_pmem = horzcat(itemMem_val_002(:,2),itemMem_val_005(:,2),itemMem_val_006(:,2),itemMem_val_008(:,2),itemMem_val_009(:,2),itemMem_val_010(:,2),itemMem_val_011(:,2),itemMem_val_013(:,2),itemMem_val_014(:,2),itemMem_val_015(:,2),itemMem_val_016(:,2),itemMem_val_018(:,2),itemMem_val_019(:,2),itemMem_val_021(:,2),itemMem_val_022(:,2),itemMem_val_023(:,2)); %index second col, the memorability data

memMean = mean(full_memSubj_pmem,2,'omitnan');
memMean_300 = memMean(~isnan(memMean)); 

save('memorability_scores','memMean_300')


% for mem_betas.m where I have to find corr between the memorability
% scores and the single trial betas, I need one col of item IDs and then
% the average for that item. That means I need something with 330 rows. 

% take memMean which has the 330 memorability values and add the item IDs,
% so the first col of any itemMem_val_XXX

memMean_330_withIDs_pmem = [itemMem_val_021(:,1),memMean];
save('mem330_withIDs_pmem','memMean_330_withIDs_pmem')

% skip this next section if you want. You can just load the val it
% calculates
%% PCs for each item 

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





%% Fit regression model
% between the PCs and the mem scores?
load('score_subset_pmem_IDsInOrder.mat')

figure
num_PCs = 20; %%%% change this value. Can't use more than 300 PCs because I only have 300 memorability values
%score_subset(:,1:10); % first 20 PCs
mdl = fitlm(score_subset(:,1:num_PCs),memMean_300);

% Take the model with 20 PCs. Compare R-squared values for 19, 18, 17, etc. Plot as accuracy
% r-squared is the coefficient of determination -> how well do the inputs
% explain the outputs. Adjusted r-squared looks at whether additional
% inputs contribute to the model. The trouble is that ordinary keeps
% increasing as you add inputs.

% We want adjusted R-squared


adj_r_sqr = zeros(num_PCs,1);
r_sqr = zeros(num_PCs,1);
for pc_val = 1:num_PCs
    temp_mdl_struct = fitlm(score_subset_300(:,1:pc_val),memMean_300);
    adj_r_sqr(pc_val) = temp_mdl_struct.Rsquared.Adjusted;
    r_sqr(pc_val) = temp_mdl_struct.Rsquared.Ordinary;
end

y_val_adjRsqr = fliplr(adj_r_sqr);
y_val_Rsqr = fliplr(r_sqr);


% residual error (y_actual - y_predicted)^2
resid_error_calc = (memMean_300 - mdl.Fitted).^2;
resid_error = sum(resid_error_calc);

x = [1:num_PCs];
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

plot(x,y_val_adjRsqr)
hold on
plot(x,y_val_Rsqr)
xlabel('PCs as dimensions')
ylabel('Accuracy (Adj R-sqr)')
title('Prediction of Item Memorability')
legend('Adj-Rsqr','Ord-Rsqr')
text(2,max(y_val_Rsqr)/2,horzcat('residual error: ',num2str(resid_error)))
hold off

% max(y_val_Rsqr)/2 <- half the height of the y-axis
%% Next
% look at regression results to try to interpret the significance,
% especially for the first 10 PCs

%% Compare predicted y values with actual memorability (y-axis) values
mdl = fitlm(score_subset_300(:,6),memMean_300);
%ypred = predict(mdl,score_subset(:,1:20)); % <- don't need
% residual error (y_actual - y_predicted)^2

resid_error_calc = (memMean_300 - mdl.Fitted).^2; % .^ is element-wise exponent
resid_error = sum(resid_error_calc);

%% Wald test. <- not needed because fitlm() has tStat vals
r = score_subset(:,1); % PC1
R = 0;
EstCov = mdl.CoefficientCovariance;
h = waldtest(r,R,EstCov);
