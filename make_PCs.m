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
% https://www.mathworks.com/help/stats/factoran.html
% https://www.mathworks.com/matlabcentral/answers/196574-factor-analysis-a-covariance-matrix-is-not-positive-definite
% lambda: the factor loadings matrix lambda for the data matrix X with m common factors.
% psi: maximum likelihood estimates of the specific variances.
% T: the m-by-m factor loadings rotation matrix T.
% stats: the structure stats containing information relating to the null hypothesis H0 that the number of common factors is m.
% F: predictions of the common factors (factor scores). 
nfeatures = 200; % running all 5000+ features result in a covariance matrix that is not positive definite
m = 10; % number of factors 
% use oblique rotation to allow correlated factors
% https://www.youtube.com/watch?v=nIv8h4rQ7K4
[lambda, psi, T, stats, F] = factoran(justFeaturesArray(:, 1:nfeatures), m, 'rotate', 'promax');
%%
clc
F_to_examine = 2;
[Fsorted, orderF] = sort(F(:, F_to_examine), 'descend');
T = table(Fsorted, items(orderF));
