%This script calculates the CSA statistics for a concept frequency matrix 

cd /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/;

%% Full Matrix 

featMat = readtable('featurematrixOnly.xlsx'); % only feature counts. no col or rownames
% save('featurematrixOnly.mat','featMat')
load featurematrixOnly.mat
% note that col 4083 still has 4 features. 4084 has 3.
% this count is per col/object, not total.
%featMat_greaterThan4 = featMat{:,1:4083};

% shenyang's combined encycl feat mat
load feat_fmri_merged_encycl.mat

featCounts = feat_fmri_merged_encycl{:,7:end};
featNames_allCol = feat_fmri_merged_encycl.Properties.VariableNames;
featNames = featNames_allCol(7:end);
% make it match the existing code
featMatArray = featCounts;

% this is 995x5520
featMatArray = table2array(featMat);

% 995x5520 but separated by feature category
load featMat_tax.mat %double
load featNames_tax.mat %cell
load featMat_encycl.mat
load featNames_encycl.mat
load featMat_vis.mat
load featNames_vis.mat
load featMat_fcn.mat
load featNames_fcn.mat

% make it match the existing code
featMatArray = featMat_tax;
featNames = featNames_tax;
featMatArray = featMat_encycl;
featNames = featNames_encycl;
featMatArray = featMat_vis;
featNames = featNames_vis;
featMatArray = featMat_fcn;
featNames = featNames_fcn;


%featMat = xlsread('featurematrixOnly.xlsx');
%save featureMatrix_92820_3up.mat featMat

%load('featureMatrix_3up_noTax_92820.mat') %load feature matrix with features that occur 3 or more times (in entire dataset not for one concept) and no taxonomic features
%C=noTaxFreqMatrix(2:end,:); %excluding first row which has numbers that indicate the feature type (i.e. visual, tactile,etc.)

%feature must occur in more than 2 concepts 
for i = 1:size(featMatArray,2) 
    counter(i)= nnz(featMatArray(:,i)); % nnz is number of non-zero elements
    [vect1] = counter>1;   %vect1 = 0 or 1 where a feature occurs for 2 or more concepts 
    [vect2] = counter<=1;
end 

indx=find(vect1); 
indx_less2 = find(vect2); %just to check that this indx and the above  add up
feats_in_matrix = featMatArray(:,indx);
%featNames_in_matrix = featNames(indx);

%save featureMat_greaterThan3obj.mat feats_in_matrix
%load featureMat_greaterThan3obj.mat


%correlational strength for features 

Cf=featMatArray(:,indx); %Cf = only features in more than two concepts 
[rsf1,pval]=corrcoef(Cf); %get average significant pairwise correlations (pearson correlation p<0.05)
p=pval<0.05;
q=p .* rsf1;
out = q; 
out(out==0) = NaN;
CSF=nanmean(out); 

%plot(CSF)


%feature distinctiveness 
%1/the number of concepts in which a feature occured 
for i=1:size(Cf,2) 
    FD(i)= 1/(nnz(Cf(:,i))); 
end


%mean distinctiveness & correlational strength for concepts 
for ii = 1:size(Cf,1) 
    index1 = find(Cf(ii,:) > 0); %for each concept find the location of all features where a feature exists 
    MD(ii) = mean(FD(index1)); %using the index1 from above to find those feature distinctiveness values in FD and take the mean across for that concept (we're getting small values)
    ror = rsf1(index1,index1); %get the correct correlational strength R values from features CS calculation above
    pop = pval(index1,index1); %get the p vals
    pop = pop < 0.05;          % only use R values that are below p val of 0.05
    qqq = pop .* ror;          %get the matrix of R vals for this concept 
    qqq(qqq==0)=NaN;           %NaN all of the zeros 
    CSC(ii) = nanmean(nanmean(qqq)); %take the mean of the above values to get a CS value for the current concept
    clear index1
end

%save variables to mat file
%save featureStatsAll.mat FD CSF MD CSC
%load featureStatsAll.mat

%save encyclShenyangMerged_featStats.mat FD CSF MD CSC
% featNames_in_matrix uses the same index used to cut featMatArray 
% to cut down featNames

% use the cell method from below
onesArr = ones(length(CSF),1);
CSF_cell = mat2cell(CSF',onesArr); % you have to tell mat2cell how many rows you want
FD_cell = mat2cell(FD', onesArr);
combinedData = horzcat(featNames_in_matrix', CSF_cell, FD_cell); % semicolons vertically concat cells

encyclShenyangFeatData = combinedData;
taxOnlyFeatData = combinedData;
encyclOnlyFeatData = combinedData;
visOnlyFeatData = combinedData;
fcnOnlyFeatData = combinedData;


% note: feats_in_matrix which has the features that appear in 3 or more
% objects is 995x3547
% CSF is corr strength for features and is 1x3547
% FD is feature distinctiveness and is 1x3547
% MD is mean distinctiveness per object and is 1x995
% CSC is corr strength for objects and is 1x995

%% feature names
%now get the features names that were indexed above and concatenate them
%with their distinnctiveness and correlational strength values
%[num,txt,raw] = xlsread('featMatrix_noTax_wFeatConceptLabels.xlsx');
%featNames = readtable('featureNames_oneCol.xlsx');
featNames = readtable('featNamesAndType.xlsx');

featNamesLong = table2array(featNames);
% cut featNamesMat down to 3547 
featNamesShortCell = featNamesLong(1:3547);
featNamesShort = string(featNamesShortCell);

% add labels to the feature and object arrays
% feature labels go with CSF corr strength and FD feature distinctiveness
featData = [featNamesShort CSF' FD'];

% Trouble with cells, matrices, and string arrays
% I wanted to leave some notes from tests I've been doing. I have the
% feature names in a table and table2array turns them into a cell. I would
% like to turn that into a string array, but cell2mat doesn't work. It
% thinks that each object is a string and because they have different
% lengths, it won't concatenate them.
% There are two work-arounds: (1) keep everything as cell arrays and
% concatenate them instead: C4 = [C1; C2; C3]
% (2) Matlab doesn't really have "string arrays." It looks like it has
% strings that can have more than one dimension. So, just to string(cell)
% and you get what I'd call a string array. Might be better than trying to
% do everything with matrices/doubles. They might not have the flexibility
% I expect them to have. 
% You can concatenate strings with doubles. You just end up with a string

% what about the cell method?
onesArr = ones(3547,1);
CSF_cell = mat2cell(CSF',onesArr); % you have to tell mat2cell how many rows you want
FD_cell = mat2cell(FD', onesArr);
dataCell = [featNamesShortCell'; CSF_cell'; FD_cell']; % semicolons vertically concat cells
featDataCell = dataCell'; % transpose to have features as rows

save featData.mat featData
save featDataCell.mat featDataCell

%% object names
objNames = readtable('itemNames_oneCol.xlsx');
objNamesCell = table2array(objNames);
objNamesMat = string(objNamesCell);
% object labels go with MD mean dist per obj and CSC corr strength per obj
objData = [objNamesMat CSC' MD'];

onesArrObj = ones(995,1);
CSC_cell = mat2cell(CSC', onesArrObj);
MD_cell = mat2cell(MD', onesArrObj);
objCell = [objNamesCell'; CSC_cell'; MD_cell'];
objDataCell = objCell';

save objData.mat objData
save objDataCell.mat objDataCell


%% can I automate finding the corr strength and distinctiveness of features?
load tenFactors_500features.mat % loads var F
load tenFactors_500features_lambda.mat % loads var lambda

load tenFactors_440features.mat % loads var F
load tenFactors_440features_lambda.mat % loads var lambda
load featData

% featNamesLong is a cell with all 5520 features
featNamesFA = featNamesLong(1:length(lambda));
% convert lambda to cell so it can be more easily combined with feat names
onesFA = ones(length(featNamesFA),1);
ones10 = ones(10,1);
ones2 = ones(2,1);
lambdaCell = mat2cell(lambda,onesFA,ones10);
%featLambdaTransposed = [featNames500'; lambdaCell'];
%featLambda = featLambdaTransposed';

factorStats = cell(1,20);

% I'm not really sure how to do this. Add two cols at a time in a loop?
% just use col as an index in colNumbers
colNumbers = [1,3,5,7,9,11,13,15,17,19];

for col = 1:size(lambdaCell,2)

    % grab one lambda col at a time and horzcat with feature names subset
    currFeatLambdaMatTransposed = [featNamesFA'; lambdaCell(:,col)'];
    currFeatLambdaMat = currFeatLambdaMatTransposed';
    % sort rows by lambda values in descending order
    sortedCell = sortrows(currFeatLambdaMat,2,'descend');
    sortedMatNames = string(sortedCell(:,1));

    % I have to do the threshold because otherwise the mean stats will all
    % be the same because it's the same 500 features
    thresholdMat = strings(size(sortedCell,1), 1);
    for row = 1:size(sortedCell,1)
        if sortedCell{row,2} > .3
            thresholdMat(row) = sortedCell{row,2};
        else
            thresholdMat(row) = NaN;
        end
    
    end

    % remove the missing rows
    factorFeatures = rmmissing(thresholdMat);

    % now that the feat are sorted by lambda, 
    % find the indices in featData where the 500 factor feat strings are
    index = zeros(length(factorFeatures),1);
    for name = 1:length(sortedMatNames(1:length(factorFeatures)))
        index(name) = find(strcmp(featData(:,1),sortedMatNames(name)));
    end
    
    featStats = zeros(length(factorFeatures),2);
    for row = 1:length(index)
        featStats(row,:) = featData(index(row),2:3);
    end

    % featStats has 2 cols, corr strength and distinctiveness
    factorStats{:,colNumbers(col)} = featStats(:,1);
    factorStats{:,colNumbers(col)+1} = featStats(:,2);
 
end

% factorStats is a 1x20 cell. It contains corr strength and distinctiveness
% for all ten factors. It goes F01 corr, F01 dist, F02 corr, F02 dist, etc

save factorStats.mat factorStats
factorStats400 = factorStats;
save factorStats440.mat factorStats

% find the mean
meanStats = zeros(1,20);
for col = 1:length(factorStats)
    
    meanStats(1,col) = mean(factorStats{:,col});

end

%% what are the CS and D values for the features on each factor?
% maybe I can multiply across by the abs of the lambda values so 
% they're weighted by how strongly the features load on each factor

load featDataCell.mat % this has CS and D for the non-tax features
% the goal is to get the lambda values per feature 
factors = readtable('fa_encyclShenyang_lambda.xlsx');
featureNames = factors{:,1};

firstCol = featDataCell(:,1);

% featureNames has extra apostrophes, so I need to clean
cleanNames = cell(length(featureNames),1);
for rows = 1:length(featureNames)
    uncleanVal = featureNames{rows};
    cleanVal = uncleanVal(2:end-1);
    cleanNames{rows} = cleanVal;
end

index_lambda=[];
for name = 1:length(firstCol)
    % strcmp all of featureNames against each cell of firstCol
    anyStr = cellfun(@(x) strcmp(x,firstCol(name)),cleanNames);
    % find the indices of non-zero elements
    index_lambda = [index_lambda find(anyStr)];
end

% index has 191 values, meaning 9 of the 200 aren't on the list.
% makes sense since those came from Shenyang's combined features
% it helps us find the lambda values

% i need a second index to help me find the CS and D values in
% featDataCell. That requires the opposite

index_feats=[];
for name = 1:length(cleanNames)
    % strcmp all of featureNames against each cell of firstCol
    anyStr = cellfun(@(x) strcmp(x,cleanNames(name)),firstCol);
    % find the indices of non-zero elements
    index_feats = [index_feats find(anyStr)];
end

% I want 200x20 values. CS and D for each of the 10 factors.
% maybe two separate mats to start
% To do that, I need to multiply the CS and D that match the 200 features
% by the corresponding lambda value

factorLambdas = factors{:,2:end};

% featDataCell has the CS and D values
% factorLambdas has the lambdas
% index_feats tells me where in featDataCell each of the 200 features is

CS_factor_mat = [];
D_factor_mat = [];
for row = 1:length(index_feats) % 191, not all 200
    CS_val = featDataCell(index_feats(row),2);
    D_val = featDataCell(index_feats(row),3);
    % multiply by all 10 factors
    new_CS = cell2mat(CS_val) * abs(factorLambdas(row,:));
    new_D = cell2mat(D_val) * abs(factorLambdas(row,:));
    CS_factor_mat = vertcat(CS_factor_mat,new_CS);
    D_factor_mat = vertcat(D_factor_mat,new_D);

end

colMean_CS = mean(CS_factor_mat);
colMean_D = mean(D_factor_mat);








%% resume mariam code

T_raw = raw(2:end,4:end);
featMatrix_3upConcepts = T_raw(:,indx);

featuresLabelsStats = [featMatrix_3upConcepts(3,:); num2cell(FD); num2cell(CSF) ];

T_concepts = raw(5:end,1);
T_concept_cat = raw(5:end,2);
T_concept_dom = raw(5:end,3);

conceptLabelStats = [T_concepts T_concept_cat  T_concept_dom   num2cell(MD)' num2cell(CSC)'];

X = cell2table(conceptLabelStats);
Y = cell2table(featuresLabelsStats);

%save feature stats
%xlswrite('concepts+MD+CS.xlsx',conceptLabelStats);
%xlswrite('feature+FD+CS.xlsx',featuresLabelsStats);
writetable(X,'concepts+MD+CS.xlsx');
writetable(Y,'feature+FD+CS.xlsx');

xlswrite('noTax_3upConcepts_CSF.xlsx', CSF);
xlswrite('noTax_3upConcepts_FD.xlsx', FD);
xlswrite('noTax_3upConcepts_MD.xlsx', MD);
xlswrite('noTax_3upConcepts_CSC.xlsx', CSC);



%calculate slope

%[num,txt,fullfile] = xlsread('Feats4Slope_92820.xlsx');

%save Feats4Slope_92820.mat fullfile

load('Feats4Slope_92820.mat')
load('itemlist.mat')
itemList = table2cell(read_item);
fullList = fullfile(2:end,:);

%removing NaNs
indx2delete=[];
 for a = 1:size(fullList,1)
     if any(strcmp(fullList(a,:),'NaN'))
        indx2delete = [indx2delete, a];
     else 
         continue
     end
 end
 

 fullList(indx2delete,:)=[];


%for every item in the list calculate the beta vals between distinctiveness
%and CS 
[~,~,concept_ind]=unique(fullList(:,1)); %gets the index for every concept

for i=1:size(read_item,1)
  C = fullList(concept_ind==i,:);  
  slope_stat = regstats(cell2mat(C(:,3)), cell2mat(C(:,4)), 'linear'); betas(i,:) = slope_stat.beta(2:end); 
end 

save slope_betas.mat betas







