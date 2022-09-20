% this comes from mds_practice.m It's the top and only useful part


set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

%addpath('/Users/matthewslayton/Documents/GitHub/STAMP/STAMP_scripts/');
addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts/');
addpath('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/');



% import items x features matrix
itemFeatures = readtable('featurematrix_4Cortney_withIDs.xlsx');

% need to remove the columns and rows that don't matter
featureMat = removevars(itemFeatures,{'Var2','Var3','Var4','Var6'}); %remove unneeded columns, leaving only 'item' and 'category'
% top row has "visual-form_and_surface, visual-color, encyclopedia, tactile, taxonomic, function, taste, sound"
% It'd be good to remove this row leaving the features (e.g. "has_legs")

% featureMat is 995x5522. First col is item, second col is category, the rest of the cols are feature hits
% need to make a separate item col before removing it and making justFeatures
itemList = featureMat(:,1);
items = table2array(itemList);
categoryList = featureMat(:,2);
justFeatures = removevars(featureMat,{'Var1','Var5'}); % remove item and category cols
justFeaturesArray = table2array(justFeatures);

save('justFeaturesArray.mat','justFeaturesArray')
save('items.mat','items')
%%%% stop here and skip down to factor analysis if I need





% justFeaturesTable = array2table(justFeaturesArray);
%
% change folder from Simon_Lab to sparsePCA-master
%p = sparsePCA(justFeaturesArray,3,3,0,1);
%sparsePCA(justFeatures,3,3,0,1);
%[F,adj_var,cum_var] = sparsePCA(justFeaturesArray,995,3,0,1);


%%%% this is the one I want
% makes 5520x994 coeff, 995x994 score
[coeff, score, latent, tsquared, explained, mu] = pca(justFeaturesArray);

% makes 995x995 coeff, 5520x995 score
%[coeff, score, latent, tsquared, explained, mu] = pca(justFeaturesArray');


[coeff, score, latent, tsquared, explained, mu] = pca(corrMatTransposed);

coeff_corr = coeff;
score_corr = score;
save('coeff_corr.mat','coeff_corr')
save('score_corr.mat','score_corr')

[coeff, score, latent, tsquared, explained, mu] = pca(covMatTransposed);

coeff_cov = coeff;
score_cov = score;
save('coeff_cov.mat','coeff_cov')
save('score_cov.mat','score_cov')

% corrcoef first, gives 5520x5520
corrMat = corrcoef(justFeaturesArray);
% 995x995
corrMatTransposed = corrcoef(justFeaturesArray');


save('corrMat_5520.mat','corrMat')
save('corrMat_995.mat','corrMatTransposed')

% 5520x5520
covMat = cov(justFeaturesArray);
% 995x995
covMatTransposed = cov(justFeaturesArray');


% explained tells you the % variance that each PC captures

% ~~~ % coefficients/loadings are coeffs on variables. It's the linear combination of the original variables
% from which the PCs are calculated.
% ~~~ % score are the coordinates of the variables in PC space (where the axes are the PCs)

% coeff has the coefficients. Coeff matrix gives coeffs of the linear
% combination for each PC
% score has the coordinates. Score is linear combo of original features




%% try factor analysis
cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/';
load justFeaturesArray.mat
load items.mat


% https://www.mathworks.com/help/stats/factoran.html
% https://www.mathworks.com/matlabcentral/answers/196574-factor-analysis-a-covariance-matrix-is-not-positive-definite
% lambda: the factor loadings matrix lambda for the data matrix X with m common factors.
% psi: maximum likelihood estimates of the specific variances.
% T: the m-by-m factor loadings rotation matrix T.
% stats: the structure stats containing information relating to the null hypothesis H0 that the number of common factors is m.
% F: predictions of the common factors (factor scores). 
nfeatures = 823; % running all 5000+ features result in a covariance matrix that is not positive definite
m = 10; % number of factors 
% use oblique rotation to allow correlated factors
% https://www.youtube.com/watch?v=nIv8h4rQ7K4
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');
%%
clc
F_to_examine = 2;
[Fsorted, orderF] = sort(F(:, F_to_examine), 'descend');
T = table(Fsorted, items(orderF));

save('tenFactors_500features.mat','F')
save('tenFactors_500features_lambda.mat','lambda')
save('fortyFactors_200features.mat','F')
save('fortyFactors_200features_lambda.mat','lambda')

% take lambda and list of features
% take first col of lambda and the col of features. sort by first col
% largest to smallest
% get the rows that have a value > 0.3
% print/export the features that are on the rows where lambda is above
% threshold
% then take second col of lambda and repeat

load feat_fmri_merged_encycl.mat

% feature mats
load featMat_encycl.mat
load featMat_fcn.mat
load featMat_tax.mat
load featMat_vis.mat
load featMatNoTax.mat % though I think this one is done and subsetted already

% feature names
load featNames_encycl.mat
load featNames_fcn.mat
load featNames_tax.mat
load featNames_vis.mat


itemNamesCell = feat_fmri_merged_encycl{:,1};
% isolate the feature data
featCounts = feat_fmri_merged_encycl{:,7:end};

% for other feature matrices, just do:
featCounts = featMat_encycl;
featCounts = featMat_fcn;
featCounts = featMat_tax;
featCounts = featMat_vis;
featCounts = featMatNoTax;

% FA won't run if there are too many cols where the numbers are the same. 
colSum = sum(featCounts,1);
indices = find(colSum==0); % where are the zeros
% remove zeros from itemNamesCell and featCounts
featCounts_nozero = featCounts;
featCounts_nozero(:, indices) = []; %----- can remove altogether
colSum_nozero = sum(abs(featCounts_nozero), 1);
[~, colSum_nozero_order] = sort(colSum_nozero, 'descend');
featCounts_nozero_ordered = featCounts_nozero(:, colSum_nozero_order); 
% no threshold, has 802 cols
% 1st level threshold of 3, has 357 cols
 

nfeatures = 200; % or 100
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(featCounts_nozero_ordered(:, 1:nfeatures), m, 'rotate', 'promax');

% to get the feature names, we need the table col labels
featNames = feat_fmri_merged_encycl.Properties.VariableNames;
featNames_nozero = featNames(7:end);
featNames_nozero(:,indices) = [];
featNames_nozero_ordered = featNames_nozero(:,colSum_nozero_order);
% now grab top 200 or 100
featNames_top200 = featNames_nozero_ordered(1:200)';

save 200feat_encycl_F.mat F
save 200feat_encycl_lambda.mat lambda
save 250feat_encycl_F.mat F
save 250feat_encycl_lambda.mat lambda

save 150feat_fcn_F.mat F
save 150feat_fcn_lambda.mat lambda

save 140feat_tax_F.mat F
save 140feat_tax_lambda.mat lambda

save 200feat_vis_F.mat F
save 200feat_vis_lambda.mat lambda

save 200feat_noTax_F.mat F
save 200feat_noTax_lambda.mat lambda


% Cortney uses the following 2 thresholds:
% Two high-pass (inclusive) thresholds:
% 1st: number of people assigned feature X to each item (greater threshold -> more reliable feature)
% ---- cells with values below the threshold are changed to zeros
% 2nd: number of items that were assigend feature X (greater threshold -> more common the feature)
% ---- feature columns below the threshold are excluded

featCounts(abs(featCounts) < 2) = 0; % 1st level
thres_pass = find(sum(abs(featCounts) > 0) >= 3) + 8; % 2nd level


save tenFactors_200feat_shenyang_F.mat F
save tenFactors_200feat_shenyang_lambda.mat lambda

save tenFactors_100feat_shenyang_thresh2_F.mat F
save tenFactors_100feat_shenyang_thresh2_lambda.mat lambda


%% start down here to run automated feature sorting
% all 995x5520
%load justFeaturesArray.mat

% no taxonomic features
load featMatNoTax.mat

load items.mat

% read in feature names
% featureNamesTbl = readtable('featureNames_oneCol.xlsx');
% featureNamesCell = table2array(featureNamesTbl);
% featureNames = strings(5520,1);
% for row = 1:numel(featureNamesCell)
%     featureNames(row) = cell2mat(featureNamesCell(row));
% end

% no tax labels
load 'noTax_labels.mat'

% re-label so it matches the code below

justFeaturesArray = featMatNoTax;
featureNames = noTax_labels';

%% start here (don't forget to computer featureNames above)
nfeatures = 500; 
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');

% need string array to output the factor features to
% lambda and m are calculated above in FA

factorFeatures_strArr = strings(length(lambda),m);

% cut featureNames to length of lambda

featureNamesSubset = featureNames(1:size(lambda,1));

for col = 1:size(lambda,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatureLambdaMat = [featureNamesSubset lambda(:,col)];
    % sort rows by lambda values in descending order
    sortedMat = sortrows(currFeatureLambdaMat,2,'descend');

    thresholdMat = strings(size(sortedMat,1), 1);
    for row = 1:size(sortedMat,1)
        if str2double(sortedMat(row,2)) > .3
            thresholdMat(row) = sortedMat(row,1);
        else
            thresholdMat(row) = NaN;
        end
    
    end
    % remove the missing rows
    %factorFeatures = rmmissing(thresholdMat);

    factorFeatures_strArr(:,col) = thresholdMat; 
end

% make sure to copy and paste featureNamesSubset into excel to analyze with
% lambda
save tenFactors_500feat_noTax.mat F
save tenFactors_500feeat_noTax_lambda lambda

save tenFactors_440features.mat F % loads var F
save tenFactors_440features_lambda.mat lambda % loads var lambda

% start here
nfeatures = 470; 
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');

% need string array to output the factor features to
% lambda and m are calculated above in FA

factorFeatures_strArr2 = strings(length(lambda),m);

% cut featureNames to length of lambda

featureNamesSubset = featureNames(1:size(lambda,1));

for col = 1:size(lambda,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatureLambdaMat = [featureNamesSubset lambda(:,col)];
    % sort rows by lambda values in descending order
    sortedMat = sortrows(currFeatureLambdaMat,2,'descend');

    thresholdMat = strings(size(sortedMat,1), 1);
    for row = 1:size(sortedMat,1)
        if str2double(sortedMat(row,2)) > .3
            thresholdMat(row) = sortedMat(row,1);
        else
            thresholdMat(row) = NaN;
        end
    
    end
    % remove the missing rows
    %factorFeatures = rmmissing(thresholdMat);

    factorFeatures_strArr2(:,col) = thresholdMat; 
end


% start here
nfeatures = 480; 
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');

% need string array to output the factor features to
% lambda and m are calculated above in FA

factorFeatures_strArr3 = strings(length(lambda),m);

% cut featureNames to length of lambda

featureNamesSubset = featureNames(1:size(lambda,1));

for col = 1:size(lambda,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatureLambdaMat = [featureNamesSubset lambda(:,col)];
    % sort rows by lambda values in descending order
    sortedMat = sortrows(currFeatureLambdaMat,2,'descend');

    thresholdMat = strings(size(sortedMat,1), 1);
    for row = 1:size(sortedMat,1)
        if str2double(sortedMat(row,2)) > .3
            thresholdMat(row) = sortedMat(row,1);
        else
            thresholdMat(row) = NaN;
        end
    
    end
    % remove the missing rows
    %factorFeatures = rmmissing(thresholdMat);

    factorFeatures_strArr3(:,col) = thresholdMat; 
end

% start here
nfeatures = 490; 
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');

% need string array to output the factor features to
% lambda and m are calculated above in FA

factorFeatures_strArr4 = strings(length(lambda),m);

% cut featureNames to length of lambda

featureNamesSubset = featureNames(1:size(lambda,1));

for col = 1:size(lambda,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatureLambdaMat = [featureNamesSubset lambda(:,col)];
    % sort rows by lambda values in descending order
    sortedMat = sortrows(currFeatureLambdaMat,2,'descend');

    thresholdMat = strings(size(sortedMat,1), 1);
    for row = 1:size(sortedMat,1)
        if str2double(sortedMat(row,2)) > .3
            thresholdMat(row) = sortedMat(row,1);
        else
            thresholdMat(row) = NaN;
        end
    
    end
    % remove the missing rows
    %factorFeatures = rmmissing(thresholdMat);

    factorFeatures_strArr4(:,col) = thresholdMat; 
end


% start here
nfeatures = 500; 
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');

% need string array to output the factor features to
% lambda and m are calculated above in FA

factorFeatures_strArr5 = strings(length(lambda),m);

% cut featureNames to length of lambda

featureNamesSubset = featureNames(1:size(lambda,1));

for col = 1:size(lambda,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatureLambdaMat = [featureNamesSubset lambda(:,col)];
    % sort rows by lambda values in descending order
    sortedMat = sortrows(currFeatureLambdaMat,2,'descend');

    thresholdMat = strings(size(sortedMat,1), 1);
    for row = 1:size(sortedMat,1)
        if str2double(sortedMat(row,2)) > .3
            thresholdMat(row) = sortedMat(row,1);
        else
            thresholdMat(row) = NaN;
        end
    
    end
    % remove the missing rows
    %factorFeatures = rmmissing(thresholdMat);

    factorFeatures_strArr5(:,col) = thresholdMat; 
end


% start here
nfeatures = 510; 
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');

% need string array to output the factor features to
% lambda and m are calculated above in FA

factorFeatures_strArr6 = strings(length(lambda),m);

% cut featureNames to length of lambda

featureNamesSubset = featureNames(1:size(lambda,1));

for col = 1:size(lambda,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatureLambdaMat = [featureNamesSubset lambda(:,col)];
    % sort rows by lambda values in descending order
    sortedMat = sortrows(currFeatureLambdaMat,2,'descend');

    thresholdMat = strings(size(sortedMat,1), 1);
    for row = 1:size(sortedMat,1)
        if str2double(sortedMat(row,2)) > .3
            thresholdMat(row) = sortedMat(row,1);
        else
            thresholdMat(row) = NaN;
        end
    
    end
    % remove the missing rows
    %factorFeatures = rmmissing(thresholdMat);

    factorFeatures_strArr6(:,col) = thresholdMat; 
end

% start here
nfeatures = 520; 
m = 10; % number of factors 
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');

% need string array to output the factor features to
% lambda and m are calculated above in FA

factorFeatures_strArr7 = strings(length(lambda),m);

% cut featureNames to length of lambda

featureNamesSubset = featureNames(1:size(lambda,1));

for col = 1:size(lambda,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatureLambdaMat = [featureNamesSubset lambda(:,col)];
    % sort rows by lambda values in descending order
    sortedMat = sortrows(currFeatureLambdaMat,2,'descend');

    thresholdMat = strings(size(sortedMat,1), 1);
    for row = 1:size(sortedMat,1)
        if str2double(sortedMat(row,2)) > .3
            thresholdMat(row) = sortedMat(row,1);
        else
            thresholdMat(row) = NaN;
        end
    
    end
    % remove the missing rows
    %factorFeatures = rmmissing(thresholdMat);

    factorFeatures_strArr7(:,col) = thresholdMat; 
end

