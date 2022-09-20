% This script reads the item x feature matrix to compute correlation
% matrices of different variations
close all
clear
clc

addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP'
%% import items x features matrix
if ~exist('data/itemFeatures.mat', 'file')
    itemFeatures = struct;
    %itemFeatures.all = readtable('../Behavior/featurematrix_4Cortney_withIDs.xlsx');
    itemFeatures.all = readtable('featurematrix_4Cortney_withIDs.xlsx');

    % rename first few columns
    itemFeatures.all.Properties.VariableNames(1:6) = {'concept','id','enc','ret','category','domain'};
    %save('data/itemFeatures.mat', 'itemFeatures')
    save('itemFeatures.mat', 'itemFeatures')
else
    %load('data/itemFeatures.mat')
    load('itemFeatures.mat')
end


%% decision 1: whether to use all 995 items or only the 300 in fmri
% 300 out of 995 items were used as 'old' items in STAMP fMRI
%fmri_stim = readtable('../Behavior/Data/final3/newretS026_final3.xlsx');
addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Behav/S026/'
fmri_stim = readtable('newretS026_final3.xlsx');
stim = fmri_stim.ID(logical(fmri_stim.old));
is_in_fmri = ismember(itemFeatures.all.id, stim);
itemFeatures.fmri = itemFeatures.all(is_in_fmri, :);

% also add another column of the image names for
fmri_stim_image_jpg = fmri_stim(logical(fmri_stim.old), ["ID" "image" "image_nojpg"]);
for items = ["all" "fmri"]
    itemFeatures.(items) = outerjoin(itemFeatures.(items), fmri_stim_image_jpg, ...
        "LeftKeys", "id", "RightKeys", "ID");
    itemFeatures.(items) = movevars(itemFeatures.(items), {'image' 'image_nojpg'}, 'After', 'id');
end



%% decision 2: thresholding the features
% Because subject are idiosyncratic, some features only showed up in very
% few items or were provided by very few subjects on the same item.
% Check this: D:\local\STAMP_Clustering\Behavior\New_Freq_Matrix_Thresholding.xlsx

% Two high-pass (inclusive) thresholds:
% 1st: number of people assigned feature X to each item (greater threshold -> more reliable feature)
% 2nd: number of items that were assigend feature X (greater threshold -> more common the feature)
thres_1st = 2;
thres_2nd = 3;
fprintf('thresholds applied: %d %d \n\n', thres_1st, thres_2nd)

for items = ["all" "fmri"]
    % array of #items x #features
    feat_array = table2array(itemFeatures.(items)(:, 9:end));

    thres_1st_pass = max(feat_array) >= thres_1st;
    thres_2nd_pass = sum(feat_array>0) >= thres_2nd;
    thres_pass = find(thres_1st_pass & thres_2nd_pass) + 8;

    thres_table = itemFeatures.(items);
    thres_table = thres_table(:, ([1:8 thres_pass]));
    itemFeatures_thres.(items) = thres_table;
end



%% item-feature matrix to compute correlation matrix
justFeatures = struct;
for items = ["all" "fmri"]
    colnames = itemFeatures_thres.(items).Properties.VariableNames;
    justFeatures.(items).vis = table2array(itemFeatures_thres.(items)(:, startsWith(colnames, 'visual')))';
    justFeatures.(items).tax = table2array(itemFeatures_thres.(items)(:, startsWith(colnames, 'taxonomic')))';
    justFeatures.(items).tax_encycl = table2array(itemFeatures_thres.(items)(:, startsWith(colnames, 'taxonomic') | startsWith(colnames, 'encyclopedic')))';

    % descriptives
    fprintf('%s items:\t #features = %d visual, %d taxonomic, %d tax_encycl \n', ...
        items, ...
        size(justFeatures.(items).vis, 1), ...
        size(justFeatures.(items).tax, 1), ...
        size(justFeatures.(items).tax_encycl, 1))
    fprintf('\t\t\t #items NOT covered by features = %d visual, %d taxonomic, %d tax_encycl \n\n', ...
        sum(sum(justFeatures.(items).vis)==0), ...
        sum(sum(justFeatures.(items).tax)==0), ...
        sum(sum(justFeatures.(items).tax_encycl)==0))
end
% Aside: understanding the column names
sort(colnames');
% all prefixes:
% encyclopedic
% smelld
% sound
% taste
% tactile
% taxonomic
% visual_color
% visual_form_and_surface
% visual_motion
% xFunction ('function' in original excel)


%% compute correlation matrices
close all
corr_feat = struct;
corr_feat.table.all = itemFeatures_thres.all(:, 1:8);
corr_feat.table.fmri = itemFeatures_thres.fmri(:, 1:8);
for feat = ["vis" "tax" "tax_encycl"]
    corrmat = corr(justFeatures.all.(feat), 'type', 'Pearson', 'rows', 'pairwise');
    corrmat(logical(eye(size(corrmat)))) = nan;
    corr_feat.all.(feat) = corrmat;
    figure;
    subplot(1,2,1)
    imAlpha=ones(size(corrmat));
    imAlpha(isnan(corrmat))=0;
    imagesc(corrmat,'AlphaData',imAlpha);
    set(gca,'color', [1 0 0]);
    colorbar;
    title(sprintf('all %s', feat), 'Interpreter', 'none')

    corrmat = corrmat(is_in_fmri, is_in_fmri);
    corr_feat.fmri.(feat) = corrmat;
    subplot(1,2,2)
    imAlpha=ones(size(corrmat));
    imAlpha(isnan(corrmat))=0;
    imagesc(corrmat,'AlphaData',imAlpha);
    set(gca,'color', [1 0 0]);
    colorbar;
    title(sprintf('fmri %s', feat), 'Interpreter', 'none')
end

%%
cfg = struct;
cfg.corr_feat = corr_feat;
cfg.thres_1st = thres_1st;
cfg.thres_2nd = thres_2nd;

%addpath 'D:\local\resources\BCT'
addpath '/Users/matthewslayton/BCT'

for items = ["all" "fmri"]
    for feat = ["vis" "tax" "tax_encycl"]
        for gamma = [0.75 1 1.25]
            % thres_1st and thres_2nd are defined upfront to visualize the
            % corr_mat, and they should not be change here
%             [M, Q, T] = modularity_job(cfg, items, feat, 1000, gamma);
            batch(@modularity_job, 0, {cfg, items, feat, 1000, gamma});
        end
    end
end


% declare function
function [M, Q, T] = modularity_job(cfg, items, feat, nIter, gamma)
arguments
    cfg struct;
    items (1,:) char;
    feat (1,:) char;
    nIter (1,1) double {mustBeFinite} = 1000;
    gamma (1,1) double {mustBeFinite} = 1;
end
tic
corr_feat = cfg.corr_feat;
thres_1st = cfg.thres_1st;
thres_2nd = cfg.thres_2nd;
fprintf('Running louvain on %s items %s features with thresholds %d %d and gamma=%d \n\n', items, feat, thres_1st, thres_2nd, gamma)

% table containing all items, to be used to interpret the communities
T = corr_feat.table.(items);

% adjacency matrix
W = corr_feat.(items).(feat);
W(isnan(W)) = 0; % louvain doesn't take nan

% iteratively apply louvain algorithm

Q = -inf;
fprintf('Total iterations = %d \n', nIter)
fprintf('Updating based on iterations: ')
for iter = 1:nIter
    [M_iter, Q_iter] = community_louvain(W, gamma, [], 'negative_asym');
    if Q_iter > Q
        % update
        Q = Q_iter;
        M = M_iter;
        fprintf('%d ', iter)
    end
end
T.M = M;

% visualize detected communities
close all
fig = figure;
[X,Y,INDSORT] = grid_communities(M); % function from BCT
imagesc(W(INDSORT, INDSORT));        % ordered correlation matrix
axis square
title(sprintf('Communities based on: %s items %s feat', items, feat), ...
    'Interpreter', 'none')
% label every k items
switch items
    case 'fmri'; k = 7;
    case 'all'; k = 25;
end
label_ind = 1:k:length(M);
label_item = corr_feat.table.(items).concept(INDSORT(label_ind));
label_cat = corr_feat.table.(items).category(INDSORT(label_ind));
label = strcat(label_item, ' -- ', label_cat);
set(gca, ...
    'YTick', label_ind, ...
    'YTickLabel', label, ...
    'YTickLabelRotation', 0)
% overlay community structure
hold on;
plot(X,Y,'r','linewidth',2);
hold off;


%% write output - figure and table
saveas(fig, sprintf('data/louvain/%sItems_%sFeat_thres_%d_%d_gamma%s.bmp', items, feat, thres_1st, thres_2nd, num2str(gamma)))
writetable(T, sprintf('data/louvain/%sItems_%sFeat_thres_%d_%d_gamma%s.csv', items, feat, thres_1st, thres_2nd, num2str(gamma)))
toc

end