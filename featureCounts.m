% STAMP tasks

% feat mat with no taonomic features and re-do FA
% hist with how many feat per feat category
% some dimension reduction method

addpath '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/';

%% How many features of each category?
%fullFeatMat = readtable('featurematrix_4Cortney_withIDs.xlsx');
featCat_tbl = readtable('featureCategories_oneCol.xlsx');
featCat = table2array(featCat_tbl);
featNames_tbl = readtable('featureNames_oneCol.xlsx');
featNames = table2array(featNames_tbl);
load featurematrixOnly.mat

% uniqueCat = unique(featCat_tbl); % there are 10 diff feature categories

[C,ia,ic] = unique(featCat);
% C has the unique feat categories
% ia has the row indices of the first occurrence of each new cat
% ic has the cat number (1 through 10) in every position of the 5220-long array

counts = accumarray(ic,1);
%histogram(counts)
% figure out how this works later. Can just copy category labels and counts
% into excel and make a chart

%% Make feat mat with no taxonomic features for FA

indices = zeros(length(featCat),1);
for row = 1:length(featCat)
    if string(featCat{row}) == "taxonomic"
        indices(row) = 1;
    end
end

% how many non-zeros are there
numTax = nnz(indices);

load featurematrixOnly.mat % loads as featMat

featMatNoTax = zeros(995,length(featCat)-numTax);
noTax_labels = zeros(1,length(featCat)-numTax);
noTax_labels = string(noTax_labels);
counter = 1; % goes up to 4867
for taxCol = 1:length(featCat) % goes up to 5220
    if indices(taxCol) == 0
        featMatNoTax(:,counter) = featMat{:,taxCol};
        noTax_labels(counter) = string(featNames{taxCol});
        counter = counter + 1;
    end
end

save('featMatNoTax.mat','featMatNoTax')
save('noTax_labels.mat','noTax_labels')

%% make feature arrays with one type only
indices_tax = zeros(length(featCat),1);
indices_encycl = zeros(length(featCat),1);
indices_vis = zeros(length(featCat),1);
indices_fcn = zeros(length(featCat),1);
for row = 1:length(featCat)
    if string(featCat{row}) == "taxonomic"
        indices_tax(row) = 1;
    elseif string(featCat{row}) == "encyclopedic"
        indices_encycl(row) = 1;
    elseif string(featCat{row}) == "visual-color"
        indices_vis(row) = 1;
    elseif string(featCat{row}) == "visual-form_and_surface"
        indices_vis(row) = 1;
    elseif string(featCat{row}) == "visual-motion"
        indices_vis(row) = 1;
    elseif string(featCat{row}) == "function"
        indices_fcn(row) = 1;
    end
end

% now I have indices for where the features by type are in the 5520

% check how many non-zeros are there
numTax = nnz(indices_tax);
numEncycl = nnz(indices_encycl);
numVis = nnz(indices_vis);
numFcn = nnz(indices_fcn);

% make the type-specific feature mats
% featMat is 995 x 5520

% indices_tax etc are 5520x1. Need to find the zeros and then use those to
% cut away the non-tax feature cols. The cols with 1s are tax.
featMat_tax = featMatArray;
taxZeros = find(indices_tax==0);
featMat_tax(:,taxZeros) = [];
featNames_tax = featNames';
featNames_tax(:,taxZeros) = [];
save featMat_tax.mat featMat_tax
save featNames_tax.mat featNames_tax

featMat_encycl = featMatArray;
encyclZeros = find(indices_encycl==0);
featMat_encycl(:,encyclZeros) = [];
featNames_encycl = featNames';
featNames_encycl(:,encyclZeros) = [];
save featMat_encycl.mat featMat_encycl
save featNames_encycl.mat featNames_encycl

featMat_vis = featMatArray;
visZeros = find(indices_vis==0);
featMat_vis(:,visZeros) = [];
featNames_vis = featNames';
featNames_vis(:,visZeros) = [];
save featMat_vis.mat featMat_vis
save featNames_vis.mat featNames_vis

featMat_fcn = featMatArray;
fcnZeros = find(indices_fcn==0);
featMat_fcn(:,fcnZeros) = [];
featNames_fcn = featNames';
featNames_fcn(:,fcnZeros) = [];
save featMat_fcn.mat featMat_fcn
save featNames_fcn.mat featNames_fcn


%% Dimension reduction method?


% featureNames_oneCol.xlsx
% featureCategories_oneCol.xlsx
% featurematrixOnly.xlsx
