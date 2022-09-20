% Feature distinctiveness (1/[number of concepts feature occurs in])
% sharedness is 1- sqrt(mean distinctiveness of the concept’s features)
% 
% Next, Correlation x Distinctiveness => slope of the regression of correlational 
% strength on distinctiveness values over all features in the concept. They exclude 
% features that occur in only one or two concepts.


%% feature distinctiveness
% Want a count of the number of items a feature has a non-zero value in.
% Then we do 1/[that count] to get the distinctiveness score for that
% feature
load 'justFeaturesArray.mat' % 995x5520. 995 items 5520 features. Also a variable in mds_practice.m

store_NumFeatures = zeros(1,size(justFeaturesArray,2)); % 1x5520, the number of features
for col=1:size(justFeaturesArray,2)
    not_zero = sum(justFeaturesArray(:,col)~=0);
    store_NumFeatures(col) = not_zero;
end

% now store_NumFeatures has the counts of the number of items the feature
% occurs in. Now we can find the distinctiveness of each item

% 1/store_NumFeatures Count

featureDistinctiveness = zeros(1,size(store_NumFeatures,2));
for number=1:size(store_NumFeatures,2)
    featureDistinctiveness(number) = 1/store_NumFeatures(1,number);

end

save('featureDistinctiveness.mat','featureDistinctiveness') 

%% sharedness
% now that I have distinctiveness scores for each feature, I can ask for 
% the distinctiveness of each item's features, so, whichever features are
% non-zero in a particular row
% sharedness is 1- sqrt(mean distinctiveness of the concept’s features)


% Go back to justFeaturesArray, go one row at a time, and ask which
% positions are non-zero. Then use those indices to grab distinctiveness
% scores from featureDistinctiveness, find their average, and do 1 -
% sqrt(mean(distinctiveness))

% get non-zero positions in justFeaturesArray
store_featuresPerItem = cell(size(justFeaturesArray,1),1);
for row=1:size(justFeaturesArray,1)
    not_zero = justFeaturesArray(row,:)~=0;
    store_featuresPerItem{row}= not_zero;
end

% store_featuresPerItem is a cell array that contains the 5520 arrays of 0s
% and 1s, where 1 is a feature that has a non-zero value. Do store_featuresPerItem{number} 
onlyPosDist = cell(size(justFeaturesArray,1),1);

for row=1:size(justFeaturesArray,1)
    currentIndices = store_featuresPerItem{row};
    posFeaturesOnly = []; %declare this as an empty array to be used for each new row
    for index=1:length(currentIndices)
        if currentIndices(index) == 1
            posFeaturesOnly = [posFeaturesOnly,featureDistinctiveness(index)];
        end
        onlyPosDist{row} = posFeaturesOnly; 
    end
end

% now onlyPostDist contains all of the feature distinctiveness values for
% the non-zero features for each item. The only thing left to do is to do 1
% - sqrt(mean)

sharedness = [];
for row=1:length(onlyPosDist)
    shareVal = [];
    shareVal = 1-sqrt(mean(onlyPosDist{row}));
    sharedness = [sharedness, shareVal];
end

%sharedness is 995 long, with the sharedness value for each of the 995
%items
save('sharedness.mat','sharedness')

% Next, Correlation x Distinctiveness => slope of the regression of 
% correlational strength on distinctiveness values over all features in the concept. 
% They exclude features that occur in only one or two concepts.
% The reason to do this is that it reflects relative correlational strength of 
% shared vs distinctive features within a concept. So, a low Corr x Dist value 
% have comparatively weaker correlated distinctive features vs shared features, 
% so these concepts place a higher demand on neural processes that bind the parts of a concept together.

% I have distinctiveness values for each feature in featureDistinctiveness
% How do we find the correlational strength? Just a linear regression. And
% I can find all features that have non-zero values for a concept, but how
% does this relate? Do I take the average of something to do with all
% features in the concept? We did that to fin sharedness

