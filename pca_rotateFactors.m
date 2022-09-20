% don't forget that mds_practice.m in ../STAMP/STAMP_scripts has the PCA
% stuff
% [coeff, score, latent, tsquared, explained, mu] = pca(featureMat);

% explained tells you the % variance that each PC captures
% coeff has the coefficients. Coeff matrix gives coeffs of the linear
% combination for each PC
% score has the coordinates. Score is linear combo of original features

% in coeff matrix, value in position row i, col j tells you the contribution of
% feature i to PC j.


load 'all_score.mat' %this is a 995x994 double that contains the 995 score (coordinate) values
% for all 994 PCs. Probably won't use that many, but we have it. The var name is 'score'

first_three = score(:,1:3);

% default (normalized varimax) rotation
[L1,T] = rotatefactors(first_three);

% equamax rotation
[L2,T] = rotatefactors(first_three,'method','equimax');

% promax rotation
[L3,T] = rotatefactors(first_three,'method','promax','power',2);

% find correlation matrix of the rotated factors
inv(T*T')

