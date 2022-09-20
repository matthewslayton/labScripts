%% now try compute distance/dissimilarity by hand and do MDS
% PCA results should be equivalent to MDS with Euclidean distance
% other distance metrics: correlation, cosine, avg |log fold changes| for
% each variable, manhattan dist, hamming dist, etc.
% requires variable from mds_practice.m
%% first compute distance matrix
itemDist_euclidean = dist_metric(justFeaturesArray, 'euclidean');
itemDist_corr = dist_metric(justFeaturesArray, 'correlation');
itemDist_cos = dist_metric(justFeaturesArray, 'cosine');
%% then try mds on those
[Y,stress] = mdscale(itemDist_euclidean, 3); % reduce to 10 dimensions, quite arbitrary
%%
[Y,stress] = cmdscale(itemDist_euclidean, 3);

scatter3(Y(:,1),Y(:,2),Y(:,3))
xlabel('dim 1')
ylabel('dim 2')
zlabel('dim 3')
title('MDS — Euclidean')

figure
[Y,stress] = mdscale(itemDist_corr, 3);
scatter3(Y(:,1),Y(:,2),Y(:,3))
xlabel('dim 1')
ylabel('dim 2')
zlabel('dim 3')
title('MDS — Corr')

figure
[Y,stress] = mdscale(itemDist_cos, 3);
scatter3(Y(:,1),Y(:,2),Y(:,3))
xlabel('dim 1')
ylabel('dim 2')
zlabel('dim 3')
title('MDS — Cosine')

%% distance function
function dist_mat = dist_metric(mat, metric_name)
n_items = size(mat, 1);
dist_mat = nan(n_items, n_items);
for i=1:n_items
    vec_i = mat(i,:);
    for j=i:n_items
        vec_j = mat(j,:);
        switch metric_name
            case 'euclidean'; d = sqrt(sum((vec_i-vec_j).*(vec_i-vec_j)));
            case 'correlation'; r = corrcoef(vec_i, vec_j); d = 1 - r(1,2);
            case 'cosine'; d = 1 - dot(vec_i,vec_j)/(norm(vec_i)*norm(vec_j));
        end
        dist_mat(i,j) = d;
        dist_mat(j,i) = d;
    end
end
end









