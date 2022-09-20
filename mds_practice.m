% prep_for_RSA.m has many related functions and work

set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white

% import items x features matrix
itemFeatures = readtable('featurematrix_4Cortney_withIDs.xlsx');

% need to remove the columns and rows that don't matter
featureMat = removevars(itemFeatures,{'Var2','Var3','Var4','Var6'}); %remove unneeded columns, leaving only 'item' and 'category'
% top row has "visual-form_and_surface, visual-color, encyclopedia, tactile, taxonomic, function, taste, sound"
% It'd be good to remove this row leaving the features (e.g. "has_legs")

% featureMat is 995x5522. First col is item, second col is category, the rest of the cols are feature hits
% need to make a separate item col before removing it and making justFeatures
itemList = featureMat(:,1);
categoryList = featureMat(:,2);
justFeatures = removevars(featureMat,{'Var1','Var5'}); % remove item and category cols
justFeaturesArray = table2array(justFeatures);
% justFeaturesTable = array2table(justFeaturesArray);
%
% change folder from Simon_Lab to sparsePCA-master
%p = sparsePCA(justFeaturesArray,3,3,0,1);
%sparsePCA(justFeatures,3,3,0,1);
%[F,adj_var,cum_var] = sparsePCA(justFeaturesArray,995,3,0,1);


%% top 1000 features
% justFeaturesArray is 995x5520, 995 objects and 5520 features
% I need to see how many hits each feature got. So, I need to sum
% the cols and get a 1x5520 array that I can then rank

sumFeatures = sum(justFeaturesArray);
% ahh!! Turns out the cols are already ranked.

topFeatures = justFeaturesArray(:,1:827); %827 is the last 20 hits. 828 is 19, and it keeps going

%topCorr = corrcoef(topFeatures);
%[F,adj_var,cum_var] = sparsePCA(topCorr,3,3,0,1);


%[coeff, score, latent, tsquared, explained, mu] = pca(justFeaturesArray);
[coeff, score, latent, tsquared, explained, mu] = pca(topFeatures);
% explained tells you the % variance that each PC captures

% ~~~ % coefficients/loadings are coeffs on variables. It's the linear combination of the original variables
% from which the PCs are calculated.
% ~~~ % score are the coordinates of the variables in PC space (where the axes are the PCs)

% coeff has the coefficients. Coeff matrix gives coeffs of the linear
% combination for each PC
% score has the coordinates. Score is linear combo of original features

% in coeff matrix, value in position row i, col j tells you the contribution of
% feature i to PC j.

% change current directory to sparsePCA-master
%[F,adj_var,cum_var] = sparsePCA(topFeatures,827,3,0,1);

% pc1_sparse = F(:,1);
% pc2_sparse = F(:,2);
% pc3_sparse = F(:,3);
% 
% scatter(pc1_sparse,pc2_sparse)
% title 'Sparse PCA';
% xlabel 'PC1';
% ylabel 'PC2'; 


x_pc1 = score(:,1); %transpose when I plan to export this to R. It seems to want to work with columns
y_pc2 = score(:,2);
z_pc3 = score(:,3);

save('x_pc1.mat','x_pc1') 
save('y_pc2.mat','y_pc2') 
save('z_pc3.mat','z_pc3') 

x_pc1_coeff = coeff(:,1); %transpose when I plan to export this to R. It seems to want to work with columns
y_pc2_coeff = coeff(:,2);
z_pc3_coeff = coeff(:,3);

save('x_pc1_coeff.mat','x_pc1_coeff') 
save('y_pc2_coeff.mat','y_pc2_coeff') 
save('z_pc3_coeff.mat','z_pc3_coeff') 

%%% I NEED TO SORT SCORE FOR EACH PC to match the word order
[x_pc1_sorted, order1] = sort(x_pc1);
itemList_array = table2array(itemList);
itemCell_sorted_pc1 = itemList_array(order1);
%itemArray_sorted_pc1 = cell2mat(itemCell_sorted_pc1);

%iwant = cellfun(@str2num,itemCell_sorted_pc1);

[y_pc2_sorted, order2] = sort(y_pc2);
itemCell_sorted_pc2 = itemList_array(order2);
%itemArray_sorted_pc2 = cell2mat(itemCell_sorted_pc2);

[z_pc3_sorted, order3] = sort(z_pc3);
itemCell_sorted_pc3 = itemList_array(order3);
%itemArray_sorted_pc3 = cell2mat(itemCell_sorted_pc3);

%words_pcOrder = horzcat(itemListArray_sorted_pc1,itemListArray_sorted_pc2,itemListArray_sorted_pc3);
% data_sorted = horzcat(x_pc1_sorted, y_pc2_sorted, z_pc3_sorted);
%csvwrite('firstThreePC_words.csv', words_pcOrder)
% csvwrite('firstThreePC_coeffs.csv', data_sorted)

save('x_pc1_sorted.mat','x_pc1_sorted') 
save('y_pc2_sorted.mat','y_pc2_sorted') 
save('z_pc3_sorted.mat','z_pc3_sorted') 

%%%%%%%%%%%%%
%% Sparse
[pc1_sparse_sorted, order1] = sort(pc1_sparse);
itemList_array = table2array(itemList);
itemCell_sorted_pc1 = itemList_array(order1);

[pc2_sparse_sorted, order2] = sort(pc2_sparse);
itemCell_sorted_pc2 = itemList_array(order2);

[pc3_sparse_sorted, order3] = sort(pc3_sparse);
itemCell_sorted_pc3 = itemList_array(order3);

scatter(pc1_sparse_sorted, pc2_sparse_sorted)
title 'PCs 1 and 2 Sorted in order'
xlabel 'PC1';
ylabel 'PC2'; 

%%%%%%
%% k-means on data_sorted

justTwo = horzcat(x_pc1_sorted, y_pc2_sorted);
justTwo_unsorted = horzcat(x_pc1, y_pc2);


%%% this finds distance between cluster centroids and points on a grid
%idx = kmeans(justFeaturesArray,3);
[idx,C] = kmeans(justTwo,3);
x1 = min(justTwo(:,1)):0.01:max(justTwo(:,1));
x2 = min(justTwo(:,2)):0.01:max(justTwo(:,2));
[x1G,x2G] = meshgrid(x1,x2);
XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the plot

idx2Region = kmeans(XGrid,3,'MaxIter',1,'Start',C);

figure;
gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
    [0,0.75,0.75;0.75,0,0.75;0.75,0.75,0],'..');
hold on;
plot(justTwo(:,1),justTwo(:,2),'k*','MarkerSize',5);
title 'Dist between points on grid and region centroids';
xlabel 'PC1';
ylabel 'PC2'; 
legend('Region 1','Region 2','Region 3','Data','Location','SouthEast');
hold off;


%%% color the clusters
% justTwo is sorted
opts = statset('Display','final');
[idx,C] = kmeans(justTwo,3,'Distance','cityblock',...
    'Replicates',5,'Options',opts);
figure;
plot(justTwo(idx==1,1),justTwo(idx==1,2),'r.','MarkerSize',12)
hold on
plot(justTwo(idx==2,1),justTwo(idx==2,2),'b.','MarkerSize',12)
plot(justTwo(idx==3,1),justTwo(idx==3,2),'g.','MarkerSize',12)
plot(C(:,1),C(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids'
xlabel 'PC1';
ylabel 'PC2'; 
hold off


% justTwo_unsorted is not sorted
opts = statset('Display','final');
[idx,C] = kmeans(justTwo_unsorted,3,'Distance','cityblock',...
    'Replicates',5,'Options',opts);
figure;
plot(justTwo_unsorted(idx==1,1),justTwo_unsorted(idx==1,2),'r.','MarkerSize',12)
hold on
plot(justTwo_unsorted(idx==2,1),justTwo_unsorted(idx==2,2),'b.','MarkerSize',12)
plot(justTwo_unsorted(idx==3,1),justTwo_unsorted(idx==3,2),'g.','MarkerSize',12)
plot(C(:,1),C(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3) 
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'PCs-unsorted Clusters'
xlabel 'PC1';
ylabel 'PC2'; 
hold off


%%%%%
%% regular plot of sorted PCs as a reference

scatter(x_pc1_sorted, y_pc2_sorted)
title 'PCs 1 and 2 Sorted in order'
xlabel 'PC1';
ylabel 'PC2'; 
figure
scatter(x_pc1, y_pc2)
title 'PCs 1 and 2 not sorted'
xlabel 'PC1';
ylabel 'PC2'; 



%%%%%%%%%%%%%%%% 
x_pc1 = score(:,1); %transpose when I play to export this to R. It seems to want to work with columns
y_pc2 = score(:,2);
z_pc3 = score(:,3);
data_pc = horzcat(x_pc1,y_pc2,z_pc3);

scatter(x_pc1,y_pc2)
xlabel('pc1')
ylabel('pc2')


itemListArray = table2array(itemList);
text(x_pc1,y_pc2,itemListArray)



%% sparse PCA
justFeaturesArrayTransposed = justFeaturesArray.';
% change folder to Simon_Lab -> sparsePCA-master
[F, adj_var, cum_var] = sparsePCA(justFeaturesArrayTransposed, 3, 3, 0);

%% Same but 3D
scatter3(x_pc1, y_pc2, x_pc3)
xlabel('pc1')
ylabel('pc2')
zlabel('pc3')
text(x_pc1,y_pc2,z_pc3,itemListArray)

% categoryList has the categories
% itemList has the items

% Something goes after %CategoryVariable  --- another 
% approach might be to make some array for the colors 
% where we just make a quick for loop and assign the colors

categoryArray = table2array(categoryList);

colorList = zeros(size(category,1));
for category = 1:size(categoryList,1) %first dimension, which is 995
    if categoryList[category] == 'furniture';
        colorList(categry) = [1 0 0];
    end
    if categoryList[category] == 'musical instruments';
        colorList.append([0 1 0]);
    end
    if categoryList[category] == 'plant';
        colorList.append([0 0 1]);
    end
    if categoryList[category] == 'street items';
        colorList.append([0 1 1]);
    end
    if categoryList[category] == 'household items';
        colorList.append([1 0 1]);
    end
    if categoryList[category] == 'food';
        colorList.append([1 1 0]);
    end
    if categoryList[category] == 'street items';
        colorList.append([0 0 0]);
    end
    if categoryList[category] == 'electronics';
        colorList.append([1 1 1]);
    end
     if categoryList[category] == 'tool';
        colorList.append([0.5 0 0]);
     end
     if categoryList[category] == 'body part';
        colorList.append([0 0.5 0]);
     end
     if categoryList[category] == 'insects';
        colorList.append([0 0 0.5]);
     end
     if categoryList[category] == 'mammal';
        colorList.append([0 0.5 0.5]);
     end
     if categoryList[category] == 'fruit';
        colorList.append([0.5 0 0.5]);
     end
     if categoryList[category] == 'building';
        colorList.append([0.5 0.5 0]);
     end
     if categoryList[category] == 'clothing';
        colorList.append([0.5 0.5 0.5]);
     end
     if categoryList[category] == 'military';
        colorList.append([0.75 0.25 0]);
     end
     if categoryList[category] == 'vegetable';
        colorList.append([0.25 0.75 0]);
      end
      if categoryList[category] == 'baby';
        colorList.append([.025 0 0.75]);
      end
      if categoryList[category] == 'kitchen items';
        colorList.append([0.25 1 1]);
      end
      if categoryList[category] == 'toys';
        colorList.append([1 0.5 1]);
      end     
      if categoryList[category] == 'sea';
        colorList.append([1 1 0.25]);
      end
      if categoryList[category] == 'fruit';
        colorList.append([0.25 0 0]);
      end
      if categoryList[category] == 'decorative';
        colorList.append([0.75 0.75 0.75]);
      end  
end



%% scatter with color
tbl = readtable('pcs_inOrder.xlsx');
scatter(x_pc1,y_pc2,'filled','ColorVariable',categoryList);
s = scatter(tbl,'Weight','Height','filled','ColorVariable','Diastolic');



[x_pc1_sorted, order] = sort(x_pc1);
y_pc2_sorted = y_pc2(order);
z_pc3_sorted = z_pc3(order);
itemListArray = table2array(itemList);
itemListArray_sorted = itemListArray(order);
showidx = 1:40:length(x_pc1_sorted);
itemListArray_short = cell(size(itemListArray_sorted));
itemListArray_short(showidx) = itemListArray_sorted(showidx);
% plot
figure
scatter3(x_pc1_sorted, y_pc2_sorted, z_pc3_sorted)
xlabel('pc1')
ylabel('pc2')
zlabel('pc3')
text(x_pc1_sorted, y_pc2_sorted, itemListArray_short)


%% back to 2D
[x_pc1_sorted, order] = sort(x_pc1);
y_pc2_sorted = y_pc2(order);
itemListArray = table2array(itemList);
itemListArray_sorted = itemListArray(order);
itemTable_sorted = array2table(itemListArray_sorted);
%showidx = 1:40:length(x_pc1_sorted);
%itemListArray_short = cell(size(itemListArray_sorted));
%itemListArray_short(showidx) = itemListArray_sorted(showidx);
% plot
figure
scatter(x_pc1_sorted, y_pc2_sorted)
xlabel('pc1')
ylabel('pc2')
text(x_pc1,y_pc2,z_pc3,itemListArray_short)


tbl = readtable('patients.xls');
s = scatter(tbl,'Weight','Height','filled','ColorVariable','Diastolic');



% sort the items in order of a particular pc
[x_pc1_sorted, order_pc1] = sort(x_pc1);
itemListArray_sorted = itemListArray(order_pc1);

[y_pc2_sorted, order_pc2] = sort(y_pc2);
itemListArray_sorted_pc2 = itemListArray(order_pc2);


[x_pc3_sorted, order_pc3] = sort(x_pc3);
itemListArray_sorted_pc3 = itemListArray(order_pc3);




% shenyang
[x_pc1_sorted, order] = sort(x_pc1);
y_pc2_sorted = y_pc2(order);
itemListArray = table2array(itemList);
itemListArray_sorted = itemListArray(order);
showidx = 1:90:length(x_pc1_sorted);
itemListArray_short = cell(size(itemListArray_sorted));
itemListArray_short(showidx) = itemListArray_sorted(showidx);
% plot
figure
scatter(x_pc1_sorted, y_pc2_sorted)
xlabel('pc1')
ylabel('pc2')
text(x_pc1_sorted, y_pc2_sorted, itemListArray_short)

% need to compute the distances and then run MDS on that distance matrix
store_distances = zeros(length(x_pc1),length(y_pc2)); 
x_counter = 1;
for value = 1:length(x_pc1)
    y_counter = 1;
    for value2 = 1:length(y_pc2)
        pairThePoints = [x_pc1(value),y_pc2(value);x_pc1(value2),y_pc2(value2)];
        %remember, bigger distance, less similar
        temp_distance = pdist(pairThePoints,'euclidean');
        store_distances(value,value2) = temp_distance;
        store_distances(value2,value) = temp_distance;
        y_counter = y_counter + 1; 
        if value == value2
            store_distances(value,value2) = 0; % make the diagonal 0 because that's what mdscale() expects
        end
    end
    x_counter = x_counter + 1;
end

% store_distances is now 995x995
% This is the n-by-n dissimilarity matrix to feed into mdscale()

Y = mdscale(store_distances,10);
scatter(Y(:,1),Y(:,2))
xlabel('x pc1')
ylabel('y pc2')


% Shenyang
%% now try compute distance/dissimilarity by hand and do MDS
% PCA results should be equivalent to MDS with Euclidean distance
% other distance metrics: correlation, cosine, avg |log fold changes| for
% each variable, manhattan dist, hamming dist, etc.
%% first compute distance matrix
itemDist_euclidean = dist_metric(justFeaturesArray, 'euclidean');
itemDist_corr = dist_metric(justFeaturesArray, 'correlation');
itemDist_cos = dist_metric(justFeaturesArray, 'cosine');
%% then try mds on those
[Y,stress] = mdscale(itemDist_euclidean, 10); % reduce to 10 dimensions, quite arbitrary
%%
[Y,stress] = cmdscale(itemDist_euclidean, 10);
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


%% Factor Analysis
%justFeaturesArray just the features, no labels

%corrMat = corrcoef(justFeaturesArray);

%[lambda,psi,T,stats,F] = factoran(corrMat,3);

%lambda = factoran(corrMat,3);

%% Load the item list but the multi-word ones have been replaced with single words
% the trouble is that when I replaced the word in excel, the initial single
% quotation mark kept disappearing, and it did not load. The format is
% "'lamp'" so I have to identify the cells that contain a str that does not
% begin with a single quote and add one
oneWordFeatures = readtable('pcs_inOrder.xlsx'); % load the item list words
oneWord_featureMat = removevars(oneWordFeatures,{'pc1','pc2','pc3'}); % remove the PC info that's in that spreadsheet
oneWord = table2array(oneWord_featureMat); 
oneWordCell = cell(1,length(oneWordCell)); % this will contain the fixed strings
apostrophe = "'";
for word = 1:length(oneWordCell)
    indivWordCell = oneWord(word); % one word at a time
    indivWord = cell2mat(indivWordCell); % convert to array so we can access the string (item name)
    if indivWord(1) ~= "'" % if it doesn't start with a single quotation mark, it's a cell I changed to be one word, and for some reason it's missing the quote 
        oneWordCell{word} = apostrophe.append(indivWord);
    else
        oneWordCell{word} = indivWord;
    end
end

xlswrite('singleWords.xls',oneWordCell)

%% Next I have to re-do the word orders for the three PCs, using the new one-word versions


itemListCell = cell(1,length(oneWordCell));
for word=1:length(oneWordCell)
    indivWord = oneWordCell{word}; % one word at a time
    itemListCell{word} = indivWord;
end


[x_pc1_sorted, order] = sort(x_pc1);
y_pc2_sorted = y_pc2(order);
z_pc3_sorted = z_pc3(order);
%itemListArray = table2array(itemList);
%itemListArray = cell2mat(itemListCell);
itemListArray_sorted = itemListCell(order);
showidx = 1:40:length(x_pc1_sorted);
itemListArray_short = cell(size(itemListArray_sorted));
itemListArray_short(showidx) = itemListArray_sorted(showidx);
% plot
figure
scatter3(x_pc1_sorted, y_pc2_sorted, z_pc3_sorted)
xlabel('pc1')
ylabel('pc2')
zlabel('pc3')
text(x_pc1_sorted, y_pc2_sorted, itemListArray_short)

% PC1 order
[x_pc1_sorted, order1] = sort(x_pc1);
pc1_itemList = itemListCell(order1);

% PC 2 order
[y_pc2_sorted, order2] = sort(y_pc2);
pc2_itemList = itemListCell(order2);

% PC 3 order
[z_pc3_sorted, order3] = sort(z_pc3);
pc3_itemList = itemListCell(order3);

all_pcItems = horzcat(pc1_itemList',pc2_itemList',pc3_itemList');

writecell(all_pcItems,'singleWords.xlsx');

xlswrite('singleWords.xls',all_pcItems_table);


       







