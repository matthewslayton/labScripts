%%
% Simon RSA work. Started September 16, 2021    
% 
% Start with the PCA that was done
%
% 1) calculate the distance between the 400 items for which there are x and y values
% 
% 2) fill out the missing items with NaN rows/columns (so it has the same dimensions as one of the other RDMs)
% 
% 3) add in the IDs (remember all RDM nat files gave both the RDM and the IDs)
% 
% And then 4) run Ben’s script

% see mds_practice.m for a continuation of this work


%%
% For MDS_for_R
% Columns are: i, item, category, WC_category, ID, Title_category, domain, size, MeanD, NoF, col of 1s for some reason, cosine_X, cosine_Y, and then many many 
% 
% For the participant-specific tabs
% Columns are: [blank], ID, concept, MDSX, MDSY, ConcMem, Mem, beta_image, beta2


%/Users/matthewslayton/Documents/Duke/Simon_Lab/S002/Sess1/Run3_Trial1_Cat4_Item2320_EncTT3_CMEM2_PMEM2_1/st_regs.mat
%contains three cells: durations, names, onsets 

% itemList comes from featureMatrix.mat

set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
path(path,'/Users/matthewslayton/Documents/Duke/Simon_Lab') % <- I don't think this works


test = readtable('MDS_IDs_test.xlsx');
test_S002 = readtable('MDS_IDs_test_S002.xlsx');
%('MDS_test_noAvg.xlsx') %401 rows for 400 items
t = readtable('MDS_setup.xlsx');
%subject = readtable('S002_data.xlsx')

itemList = readtable('MDS_itemList');
load('/Users/matthewslayton/Documents/Duke/Simon_Lab/featureMatrix.mat')

scatter(test.('cosine_X'),test.('cosine_Y')) %this is like a data table. You can't just index it. The period helps you extract an array from the table
xlabel('First PC')
ylabel('Second PC')
title('MDS')
%
% Need to find Euc Distance between all points?
% 
D  = sqrt(sum((G - G2) .^ 2));

% If I do a array by array subtraction, I get a single value of 12.3549
dist = sqrt(sum((test.('cosine_X')-test.('cosine_Y')) .^2));


%% This makes the RDM
% Maybe Simon meant to find the Euc Dist between all points
x_val = test.('cosine_X'); % 360      
y_val = test.('cosine_Y'); % 360    
IDs = test.('ID'); % 360

store_distances = zeros(length(x_val),length(y_val)); 
x_counter = 1;
for value = 1:length(x_val)
    y_counter = 1;
    for value2 = 1:length(y_val)
        pairThePoints = [x_val(value),y_val(value);x_val(value2),y_val(value2)];
        %remember, bigger distance, less similar
        temp_distance = pdist(pairThePoints,'euclidean');
        store_distances(value,value2) = temp_distance;
        store_distances(value2,value) = temp_distance;
        y_counter = y_counter + 1; 
        if value == value2
            store_distances(value,value2) = NaN; % make the 1s NaNs to avoid 'biasing later computations'
        end
    end
    x_counter = x_counter + 1;
end


% need to rename to match what the RSA script is expecting
R = store_distances;
stim_ID_num = IDs;

%save these two variables into the mat file
save('combinedData.mat','R','stim_ID_num')


%% run PCA on featureMatrix
[coeff, score, latent] = pca(featureMatrix(:,2:end)');
% featureMatrix is 935 x 3281
% Dont' forget that there are 935 items. 
% pca outputs an observations x variables matrix (rows x col)
% For us, observations = concepts, variables = features
% coeff is 935 x 935. Columns are the PCs
% score is 3280 x 935. <- principal component scores / influence of that item on the PC
% latent is 935 x 1. <- these are variances (eigenvalues, meaning they are the scaling factor, of the covariance matrix of featureMatrix)

% let's assume the rows are the PCs since Simon kind of hinted that

x_pc1 = coeff(1,:)'; %transpose these because it makes R happy. It seems to want to work with columns
y_pc2 = coeff(2,:)';
data_pc = horzcat(x_pc1,y_pc2);

save('data_pc.mat','data_pc');
writematrix(data_pc,'data_pc.csv');
writematrix(x_pc1,'x_pc.csv');
writematrix(y_pc2,'y_pc.csv');

% I need to make one of these mat files. Turns out, they have a 300x300 RDM
% called R where the diagonal is 1s, not 0s. Also stim_ID_num is a 1x300
% double that has the ID numbers of the stimuli. (Remember, it's 1 row
% tall)

% Have to get item number list from MDS_setup. Can you access individual
% pages? It's in col B, so (:,2), then transpose to fit the format. Turns
% out there are two ID lists. One for S002 and one for everyone else. I
% made a separate xlsx file, though we really only need the one and to
% repeat it. 
all_IDs = readtable('subject_IDs.xlsx');

stim_ID_num = 


%save these two variables into the mat file
save('test_sep25.mat','R','stim_ID_num')

%% Run my own PCA and then make the RDM based on that
% so, combine the two things I did above

% ^another question. How can I do my own PCA. Is featureMatrix going to
% change? I think it's just what it is, so the PCA is just what it is

% for sure I will make sure we're making higher numbers mean similarity so
% it matches the data I saw in RSA_class_6.9
% That means my RDM has to be flipped with (1 - Euc Dist) and then I'll
% flip my PCA as well so it'll have lower numbers to reflect the lack of
% similarity between items

[coeff, score, latent] = pca(featureMatrix(:,2:end)');
% featureMatrix is 935 x 3281
% Dont' forget that there are 935 items. 
% pca outputs an observations x variables matrix (rows x col)
% For us, observations = concepts, variables = features
% coeff is 935 x 935. Columns are the PCs
% score is 3280 x 935. <- principal component scores / influence of that item on the PC
% latent is 935 x 1. <- these are variances (eigenvalues, meaning they are the scaling factor, of the covariance matrix of featureMatrix)
% cosine_x and cosine_y are 406x1. These come from MDS_setup -> MDS_for_R (first page in the multi-page spreadsheet)

% let's assume the rows are the PCs since Simon kind of hinted that

x_val = coeff(1,:)'; %transpose to make it many rows by 1 col. 
y_val = coeff(2,:)';

store_distances = zeros(length(x_val),length(y_val)); 
x_counter = 1;
for value = 1:length(x_val)
    y_counter = 1;
    for value2 = 1:length(y_val)
        pairThePoints = [x_val(value),y_val(value);x_val(value2),y_val(value2)];
        %remember, bigger distance, less similar
        temp_distance = pdist(pairThePoints,'euclidean');
        store_distances(value,value2) = temp_distance;
        store_distances(value2,value) = temp_distance;
        y_counter = y_counter + 1; 
        if value == value2
            store_distances(value,value2) = NaN; % make the 1s NaNs to avoid 'biasing later computations'
        end
    end
    x_counter = x_counter + 1;
end

% once I have the RDM, I have to make the ID list
% You can index tables by col name like a dataframe in R.
% just use table_name.('label') 

S002_IDs = all_IDs.('S002');  % 360x1






%% RECYCLING BIN %%


%this matrix doesn't look right. It is 406x406, but it doesn't have 1s (or
%I guess 0s for distance) when the same thing is compared. Or, is that not
%supposed to happen here? 
storeAllDist = zeros(length(x_val),length(y_val)); 
x_counter = 1;
for value = 1:length(x_val)
    y_counter = 1;
    for value2 = 1:length(y_val)
        storeAllDist(x_counter,y_counter) = sqrt(sum(x_val(value) - y_val(value2)) .^2);
        y_counter = y_counter + 1; 
    end
    x_counter = x_counter + 1;
end



