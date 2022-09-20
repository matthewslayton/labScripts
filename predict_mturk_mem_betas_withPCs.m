%% Normative study memory data
% can still use with PC code below

% this makes adj R^2 Hebart-style prediction plots for PCs and Factors predicting memorability
% go to adj_r2_PCs_F_betas.m for PCs and Factors predicting custom ROI-specific activity

% to use SPM
% addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
% on laptop
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');

% on velociraptor
addpath '/Users/matthewslayton/spm12';

% The PCs are in item-level alphabetical order. Same with memData.xlsx
% All I have to do is match the rows between the two and we're all set
% no need to sort like with STAMP. I just use the two mem cols from
% memData.xlsx and that's it
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/'
load 'all_score.mat' %this is a 995x994 double that contains the 995 score (coordinate) values
% for all 994 PCs. 



%%%% skip all this stuff and go down to line 314

load 'tenFactors.mat' %this is 995x10, the factor scores
load 'twentyFactors.mat' %this is 995x20, the factor scores
load 'thirtyFactors.mat' %this is 995x30, the factor scores

load tenFactors_500feat_noTax.mat


memData = readtable('memData.xlsx'); % this is the MTurk data from 566 raters

% these are in alphabetical order
visMem = memData{:,'visual_HR'};
lexMem = memData{:,'lexical_HR'};

% Corrected Recognition (CR) = HR - FAR
load visMem_CR
load lexMem_CR
% these will have NaNs. Will the models run or do I have to remove them?
visMem = visMem_CR;
lexMem = lexMem_CR;

% PCs
num_PCs = 40; %%%% change this value. Can't use more than 300 PCs because I only have 300 memorability values
%score_subset(:,1:10); % first 20 PCs
%score_subset is 300x994. What to do with 301-330?

vis_model = fitlm(score(:,1:num_PCs),visMem);
lex_model = fitlm(score(:,1:num_PCs),lexMem);

% Factors
num_F = 10;
vis_model = fitlm(F(:,1:num_F),visMem);
lex_model = fitlm(F(:,1:num_F),lexMem);

% correlation matrix
vis_model = fitlm(score_corr(:,1:num_PCs),visMem);
lex_model = fitlm(score_corr(:,1:num_PCs),lexMem);

% covariance matrix
vis_model = fitlm(score_cov(:,1:num_PCs),visMem);
lex_model = fitlm(score_cov(:,1:num_PCs),lexMem);



%% add PCs one at a time to see how well they predict memory
% ^this is based on the PCA on the raw feature matrix
num_PCs = 20;


vis_adj_r_sqr = zeros(num_PCs,1);
vis_r_sqr = zeros(num_PCs,1);
lex_adj_r_sqr = zeros(num_PCs,1);
lex_r_sqr = zeros(num_PCs,1);
for pc_val = 1:num_PCs

    vis_mdl_struct = fitlm(score(:,1:pc_val),visMem);
    vis_adj_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Adjusted;
    vis_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Ordinary;

    lex_mdl_struct = fitlm(score(:,1:pc_val),lexMem);
    lex_adj_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Adjusted;
    lex_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Ordinary;

end

% flip array left and right
y_val_vis_adjRsqr = fliplr(vis_adj_r_sqr);
y_val_vis_Rsqr = fliplr(vis_r_sqr);

y_val_lex_adjRsqr = fliplr(lex_adj_r_sqr);
y_val_lex_Rsqr = fliplr(lex_r_sqr);

% residual error (y_actual - y_predicted)^2
vis_resid_error_calc = (visMem - vis_mdl_struct.Fitted).^2;
% remove the rows with NaN
vis_resid_error_calc(any(isnan(vis_resid_error_calc), 2), :) = [];
vis_resid_error = sum(vis_resid_error_calc);

% residual error (y_actual - y_predicted)^2
lex_resid_error_calc = (lexMem - lex_mdl_struct.Fitted).^2;
% remove the rows with NaN
lex_resid_error_calc(any(isnan(lex_resid_error_calc), 2), :) = [];
lex_resid_error = sum(lex_resid_error_calc);

x = 1:num_PCs;
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
figure

plot(x,y_val_vis_adjRsqr,'LineWidth',2)
hold on
plot(x,y_val_vis_Rsqr,'LineWidth',2)

plot(x,y_val_lex_adjRsqr,'LineWidth',2)
plot(x,y_val_lex_Rsqr,'LineWidth',2)

xlabel('PCs as dimensions')
ylabel('Variance Explained')
title('Prediction of Item Memorability')
legend('Adj-Rsqr-Vis','Ord-Rsqr-Vis','Adj-Rsqr-Lex','Ord-Rsqr-Lex')
text(4,max(y_val_vis_Rsqr)/2,horzcat('residual error: ',num2str(vis_resid_error)))
text(12,max(y_val_lex_Rsqr)/2,horzcat('residual error: ',num2str(lex_resid_error)))
hold off


%%% factors
num_F = 30;

vis_adj_r_sqr = zeros(num_F,1);
vis_r_sqr = zeros(num_F,1);
lex_adj_r_sqr = zeros(num_F,1);
lex_r_sqr = zeros(num_F,1);
for pc_val = 1:num_F

    vis_mdl_struct = fitlm(F(:,1:pc_val),visMem);
    vis_adj_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Adjusted;
    vis_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Ordinary;

    lex_mdl_struct = fitlm(F(:,1:pc_val),lexMem);
    lex_adj_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Adjusted;
    lex_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Ordinary;

end

% flip array left and right
y_val_vis_adjRsqr = fliplr(vis_adj_r_sqr);
y_val_vis_Rsqr = fliplr(vis_r_sqr);

y_val_lex_adjRsqr = fliplr(lex_adj_r_sqr);
y_val_lex_Rsqr = fliplr(lex_r_sqr);

% residual error (y_actual - y_predicted)^2
vis_resid_error_calc = (visMem - vis_mdl_struct.Fitted).^2;
% remove the rows with NaN
vis_resid_error_calc(any(isnan(vis_resid_error_calc), 2), :) = [];
vis_resid_error = sum(vis_resid_error_calc);

% residual error (y_actual - y_predicted)^2
lex_resid_error_calc = (lexMem - lex_mdl_struct.Fitted).^2;
% remove the rows with NaN
lex_resid_error_calc(any(isnan(lex_resid_error_calc), 2), :) = [];
lex_resid_error = sum(lex_resid_error_calc);

x = 1:num_F;
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
figure

plot(x,y_val_vis_adjRsqr,'LineWidth',2)
hold on
plot(x,y_val_vis_Rsqr,'LineWidth',2)

plot(x,y_val_lex_adjRsqr,'LineWidth',2)
plot(x,y_val_lex_Rsqr,'LineWidth',2)

xlabel('Factors as dimensions')
ylabel('Variance Explained')
title('Prediction of Item Memorability')
legend('Adj-Rsqr-Vis','Ord-Rsqr-Vis','Adj-Rsqr-Lex','Ord-Rsqr-Lex')
text(4,max(y_val_vis_Rsqr)/2,horzcat('residual error: ',num2str(vis_resid_error)))
text(7,max(y_val_lex_Rsqr)/2,horzcat('residual error: ',num2str(lex_resid_error)))
hold off


%% Correlation matrix
vis_adj_r_sqr = zeros(num_PCs,1);
vis_r_sqr = zeros(num_PCs,1);
lex_adj_r_sqr = zeros(num_PCs,1);
lex_r_sqr = zeros(num_PCs,1);
for pc_val = 1:num_PCs

    vis_mdl_struct = fitlm(score_corr(:,1:pc_val),visMem);
    vis_adj_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Adjusted;
    vis_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Ordinary;

    lex_mdl_struct = fitlm(score_corr(:,1:pc_val),lexMem);
    lex_adj_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Adjusted;
    lex_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Ordinary;

end

% flip array left and right
y_val_vis_adjRsqr = fliplr(vis_adj_r_sqr);
y_val_vis_Rsqr = fliplr(vis_r_sqr);

y_val_lex_adjRsqr = fliplr(lex_adj_r_sqr);
y_val_lex_Rsqr = fliplr(lex_r_sqr);

% residual error (y_actual - y_predicted)^2
vis_resid_error_calc = (visMem - vis_mdl_struct.Fitted).^2;
% remove the rows with NaN
vis_resid_error_calc(any(isnan(vis_resid_error_calc), 2), :) = [];
vis_resid_error = sum(vis_resid_error_calc);

% residual error (y_actual - y_predicted)^2
lex_resid_error_calc = (lexMem - lex_mdl_struct.Fitted).^2;
% remove the rows with NaN
lex_resid_error_calc(any(isnan(lex_resid_error_calc), 2), :) = [];
lex_resid_error = sum(lex_resid_error_calc);

x = 1:num_PCs;
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
figure

plot(x,y_val_vis_adjRsqr,'LineWidth',2)
hold on
plot(x,y_val_vis_Rsqr,'LineWidth',2)

plot(x,y_val_lex_adjRsqr,'LineWidth',2)
plot(x,y_val_lex_Rsqr,'LineWidth',2)

xlabel('PCs as dimensions')
ylabel('Variance Explained')
title('Prediction of Item Memorability -- Corr Mat')
legend('Adj-Rsqr-Vis','Ord-Rsqr-Vis','Adj-Rsqr-Lex','Ord-Rsqr-Lex')
text(4,max(y_val_vis_Rsqr)/2,horzcat('residual error: ',num2str(vis_resid_error)))
text(10,max(y_val_lex_Rsqr)/2,horzcat('residual error: ',num2str(lex_resid_error)))
hold off


%% Covariance Matrix
vis_adj_r_sqr = zeros(num_PCs,1);
vis_r_sqr = zeros(num_PCs,1);
lex_adj_r_sqr = zeros(num_PCs,1);
lex_r_sqr = zeros(num_PCs,1);
for pc_val = 1:num_PCs

    vis_mdl_struct = fitlm(score_cov(:,1:pc_val),visMem);
    vis_adj_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Adjusted;
    vis_r_sqr(pc_val) = vis_mdl_struct.Rsquared.Ordinary;

    lex_mdl_struct = fitlm(score_cov(:,1:pc_val),lexMem);
    lex_adj_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Adjusted;
    lex_r_sqr(pc_val) = lex_mdl_struct.Rsquared.Ordinary;

end

% flip array left and right
y_val_vis_adjRsqr = fliplr(vis_adj_r_sqr);
y_val_vis_Rsqr = fliplr(vis_r_sqr);

y_val_lex_adjRsqr = fliplr(lex_adj_r_sqr);
y_val_lex_Rsqr = fliplr(lex_r_sqr);

% residual error (y_actual - y_predicted)^2
vis_resid_error_calc = (visMem - vis_mdl_struct.Fitted).^2;
% remove the rows with NaN
vis_resid_error_calc(any(isnan(vis_resid_error_calc), 2), :) = [];
vis_resid_error = sum(vis_resid_error_calc);

% residual error (y_actual - y_predicted)^2
lex_resid_error_calc = (lexMem - lex_mdl_struct.Fitted).^2;
% remove the rows with NaN
lex_resid_error_calc(any(isnan(lex_resid_error_calc), 2), :) = [];
lex_resid_error = sum(lex_resid_error_calc);

x = 1:num_PCs;
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
figure

plot(x,y_val_vis_adjRsqr,'LineWidth',2)
hold on
plot(x,y_val_vis_Rsqr,'LineWidth',2)

plot(x,y_val_lex_adjRsqr,'LineWidth',2)
plot(x,y_val_lex_Rsqr,'LineWidth',2)

xlabel('PCs as dimensions')
ylabel('Variance Explained')
title('Prediction of Item Memorability -- Cov Mat')
legend('Adj-Rsqr-Vis','Ord-Rsqr-Vis','Adj-Rsqr-Lex','Ord-Rsqr-Lex')
text(6,max(y_val_vis_Rsqr)/2,horzcat('residual error: ',num2str(vis_resid_error)))
text(10,max(y_val_lex_Rsqr)/2,horzcat('residual error: ',num2str(lex_resid_error)))
hold off



%% Get PC score subset for each subject

% ** the groups are:
% S002
% 005, 006, 008, 009, 010, 011
% 013, 014, 015, 016, 018, 019, 021, 022
% 023, 024, 025, 026

% load 'all_score.mat' %this is a 995x994 double that contains the 995 score (coordinate) values
% for all 994 PCs. 

load 'all_score.mat'
load visMem_CR
load lexMem_CR
% these will have NaNs. Will the models run or do I have to remove them?
visMem = visMem_CR;
lexMem = lexMem_CR;

%% Get score subsets for the four item presentation groups


% load factor mat files

addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/;

load 250feat_encycl_F.mat
load 200feat_noTax_F.mat
load 200feat_vis_F.mat
load 140feat_tax_F.mat
load 150feat_fcn_F.mat
%load tenFactors_200feat_shenyang_F.mat needs to be 995x10, not 300

% clear F in between

%%% can load score, visMem, and lexMem above but that's it

% ~~~ % S002 group

% IDs_enc has the IDs in presentation order
% PCs_S002 is in ascending numerical order just like score
% PCs are in item-name ascending order, just like itemIDs

% I need to grab the PC rows whose name matches the row in itemIDs that
% matches the ID number in IDs_enc

addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/spm12');

% itemIDs has the IDs in item-name alphabetical order
itemIDs = readtable('itemIDs.xlsx');

%betas_S002 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S002/betas_smoothed/*.nii');
betas_S002 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S002/betas_smoothed/*.nii');

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
factor_subset_S002 = zeros(length(indices_inOrder),10); % all ten factors
for row = 1:length(indices_inOrder)
    score_subset_S002(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    visMem_subset_S002(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S002(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs
    factor_subset_S002(row,:) = F(indices_inOrder(row),:); % the entire row which is all ten factors

end


% save(strcat('PCs_subset_S002_Group'),'score_subset_S002')
%save('factor_subset_S002.mat','factor_subset_S002')

cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/;
save('factor_noTax_subset_S002.mat','factor_subset_S002')
save('factor_encycl_subset_S002.mat','factor_subset_S002')
save('factor_vis_subset_S002.mat','factor_subset_S002')
save('factor_tax_subset_S002.mat','factor_subset_S002')
save('factor_fcn_subset_S002.mat','factor_subset_S002')



%betas_S005 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S005/betas_smoothed/*.nii');
betas_S005 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S005/betas_smoothed/*.nii');

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
factor_subset_S005 = zeros(length(indices_inOrder),10); % all ten factors
for row = 1:length(indices_inOrder)
    score_subset_S005(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    factor_subset_S005(row,:) = F(indices_inOrder(row),:); % the entire row which is all ten factors
    visMem_subset_S005(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S005(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs

end


%save(strcat('PCs_subset_S005_Group'),'score_subset_S005')

%save('factor_subset_S005.mat','factor_subset_S005')

cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/;
save('factor_noTax_subset_S005.mat','factor_subset_S005')
save('factor_encycl_subset_S005.mat','factor_subset_S005')
save('factor_vis_subset_S005.mat','factor_subset_S005')
save('factor_tax_subset_S005.mat','factor_subset_S005')
save('factor_fcn_subset_S005.mat','factor_subset_S005')

%betas_S013 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S013/betas_smoothed/*.nii');
betas_S013 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S013/betas_smoothed/*.nii');

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
factor_subset_S013 = zeros(length(indices_inOrder),10); % all ten factors
for row = 1:length(indices_inOrder)
    score_subset_S013(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    visMem_subset_S013(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S013(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs
    factor_subset_S013(row,:) = F(indices_inOrder(row),:); % the entire row which is all ten factors

end

%save('factor_subset_S013.mat','factor_subset_S013')
%save(strcat('PCs_subset_S013_Group'),'score_subset_S013')
cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/;
save('factor_noTax_subset_S013.mat','factor_subset_S013')
save('factor_encycl_subset_S013.mat','factor_subset_S013')
save('factor_vis_subset_S013.mat','factor_subset_S013')
save('factor_tax_subset_S013.mat','factor_subset_S013')
save('factor_fcn_subset_S013.mat','factor_subset_S013')


%betas_S023 = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S023/betas_smoothed/*.nii');
betas_S023 = dir('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Encoding_renamed/S023/betas_smoothed/*.nii');

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
factor_subset_S023 = zeros(length(indices_inOrder),10); % all ten factors
for row = 1:length(indices_inOrder)
    score_subset_S023(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    visMem_subset_S023(row,:) = visMem(indices_inOrder(row),:); % the entire row which is all the PCs
    lexMem_subset_S023(row,:) = lexMem(indices_inOrder(row),:); % the entire row which is all the PCs
    factor_subset_S023(row,:) = F(indices_inOrder(row),:); % the entire row which is all ten factors

end

%save(strcat('PCs_subset_S023_Group'),'score_subset_S023')
%save('factor_subset_S023.mat','factor_subset_S023')

cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/FA_results/;
save('factor_noTax_subset_S023.mat','factor_subset_S023')
save('factor_encycl_subset_S023.mat','factor_subset_S023')
save('factor_vis_subset_S023.mat','factor_subset_S023')
save('factor_tax_subset_S023.mat','factor_subset_S023')
save('factor_fcn_subset_S023.mat','factor_subset_S023')

%% everything below here grabbed the PCs in ascending order
% I thought I wanted to match the PCs to item presentation order, which I
% did above.
% Now I think I should use the PC that I used to predict memorability, and
% that is in ascending order. 


% ~~~ % S002 group
load items_cmem_S002.mat
% remove the rows with NaN
items_and_cmem_sorted(any(isnan(items_and_cmem_sorted),2),:)= [];
PCs_S002 = items_and_cmem_sorted(:,1);
clear items_and_cmem_sorted

% ~~~ % S005 group
load items_cmem_S005.mat
items_and_cmem_sorted(any(isnan(items_and_cmem_sorted),2),:)= [];
PCs_S005 = items_and_cmem_sorted(:,1);
clear items_and_cmem_sorted

% ~~~ % S013 group
load items_cmem_S013.mat
items_and_cmem_sorted(any(isnan(items_and_cmem_sorted),2),:)= [];
PCs_S013 = items_and_cmem_sorted(:,1);
clear items_and_cmem_sorted

% ~~~ % S023 group --- use S025 because that file has all 300
load items_cmem_S025.mat
items_and_cmem_sorted(any(isnan(items_and_cmem_sorted),2),:)= [];
PCs_S025 = items_and_cmem_sorted(:,1);
clear items_and_cmem_sorted

load 'all_score.mat' 
itemIDs = readtable('itemIDs.xlsx');

% ~~~ % S002 group

indices_inOrder = zeros(300,1);
for itemNum = 1:300

    index = find(itemIDs{:,2}==PCs_S002(itemNum)); %find the four-digit ID num in the second col of the table
    indices_inOrder(itemNum) = index;

end

score_subset_S002_ascending = zeros(length(indices_inOrder),994); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S002_ascending(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs

end

save(strcat('PCs_subset_S002_Group_ascending'),'score_subset_S002_ascending')

% ~~~ % S005 group

indices_inOrder = zeros(300,1);
for itemNum = 1:300

    index = find(itemIDs{:,2}==PCs_S005(itemNum)); %find the four-digit ID num in the second col of the table
    indices_inOrder(itemNum) = index;

end

score_subset_S005_ascending = zeros(length(indices_inOrder),994); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S005_ascending(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs

end

save(strcat('PCs_subset_S005_Group_ascending'),'score_subset_S005_ascending')


% ~~~ % S013 group
indices_inOrder = zeros(300,1);
for itemNum = 1:300

    index = find(itemIDs{:,2}==PCs_S013(itemNum)); %find the four-digit ID num in the second col of the table
    indices_inOrder(itemNum) = index;

end

score_subset_S013_ascending = zeros(length(indices_inOrder),994); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S013_ascending(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs

end

save(strcat('PCs_subset_S013_Group_ascending'),'score_subset_S013_ascending')


% ~~~ % S023 group
indices_inOrder = zeros(300,1);
for itemNum = 1:300

        % remember I'm using S025 because for some reason S023 doesn't have
        % all 300
    index = find(itemIDs{:,2}==PCs_S025(itemNum)); %find the four-digit ID num in the second col of the table
    indices_inOrder(itemNum) = index;

end

score_subset_S023_ascending = zeros(length(indices_inOrder),994); % all PCs
for row = 1:length(indices_inOrder)
    score_subset_S023_ascending(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs

end

save(strcat('PCs_subset_S023_Group_ascending'),'score_subset_S023_ascending')

