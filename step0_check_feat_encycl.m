% This script reads the item x feature matrix to compute correlation
% matrices of different variations
close all
clear
clc


% import items x features matrix
if ~exist('data/itemFeatures.mat', 'file')
    itemFeatures = struct;
    itemFeatures.all = readtable('featurematrix_4Cortney_withIDs.xlsx');

    % rename first few columns
    itemFeatures.all.Properties.VariableNames(1:6) = {'concept','id','enc','ret','category','domain'};
    save('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/itemFeatures.mat', 'itemFeatures')
else
    load('data/itemFeatures.mat')
end

% 
% % get the feature names
% %feature_names = readcell('../Behavior/featurenames.xlsx');
% feature_names = readcell('featureNames_oneCol.xlsx');
% feature_types = itemFeatures.all.Properties.VariableNames(7:end);
% % change header to feature names
% itemFeatures.all.Properties.VariableNames(7:end) = feature_names';


% subset only the 300 out of 995 items
% which were used as 'old' items in STAMP fMRI

% re-do for S002, S005, S013, S023
fmri_stim = readtable('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/Behav/S023/newretS023_final3.xlsx');
stim = fmri_stim.ID(logical(fmri_stim.old));
is_in_fmri = ismember(itemFeatures.all.id, stim);
itemFeatures.fmri = itemFeatures.all(is_in_fmri, :);


% some features are all empty in itemFeatures.fmri
feature_fmri_sum = sum(table2array(itemFeatures.fmri(:, 7:end)), 1);
itemFeatures.fmri = itemFeatures.fmri(:, [1:6, 6+find(feature_fmri_sum)]);


itemFeature_names_fmri = feature_names(feature_fmri_sum > 0);
featName.encycl = itemFeature_names_fmri(startsWith(feature_types(feature_fmri_sum>0), 'encyclopedic'));
featName.encycl


%% check possible matches to a specific feature
clc
ifeat_prev = 1;
while true
    % input feature number
    ifeat = input(sprintf('feature number (last: %d)? ', ifeat_prev));
    if isempty(ifeat)
        %         continue
        ifeat = ifeat_prev;
    elseif strcmpi(ifeat, 'esc')
        break
    elseif ~isnumeric(ifeat)
        continue
    end
    ifeat_prev = ifeat;

    % print feature
    featname = featName.encycl(ifeat);
    fprintf('%d %s \n', ifeat, featname{1})
    % print concepts
    featind = find(strcmpi(feature_names, featname));
    related_concepts = itemFeatures.all(:, [1, featind+6]);
    related_concepts = related_concepts(table2array(related_concepts(:,2))>0, :);
    related_concepts = sortrows(related_concepts, 2, 'descend');
    related_concepts
    fprintf('%d %s \n', ifeat, featname{1})

    check_contain = input('feature contains: ');
    if isempty(check_contain) | isnumeric(check_contain)
        continue
    end

    ind_contains = find(contains(featName.encycl, check_contain));

    % print features
    relevant_feats = table(ind_contains', featName.encycl(ind_contains)')
    %     for feat = sort(relevant_feats.Var2)'
    %         fprintf('%s\n', feat{1})
    %     end
    %     fprintf('\n')

end


%% use information from the excel sheet to merge encyclopedic features
clc
to_merge_cell = readcell('merge_encycl_feat.xlsx', 'Sheet', 'merge_encycl_feat');
merged_feat_class = to_merge_cell(1,:);
merged_feats = to_merge_cell(2, :);
% disregard the first row and use the second row as the header
to_merge_table = cell2table(to_merge_cell(3:end, :));
to_merge_table.Properties.VariableNames = merged_feats;

% to_merge_table


% make a record of features that are NOT used in merge - they should be
% preserved as individual features
unused_feat = featName.encycl;
feat_fmri_merged_encycl = itemFeatures.fmri(:, 1:6);

for i = 1:length(merged_feats)
    merged_feat = merged_feats{i};
    merged_feat_count = zeros(height(feat_fmri_merged_encycl), 1);
    % component sub features
    component_type = 0;
    component_feats = to_merge_table.(merged_feat);
    for component_feat = component_feats'
        component_feat = component_feat{1};
        if ismissing(component_feat)
            break
        end

        if strcmpi(component_feat, '------------------------')
            component_type = component_type + 1;
            continue
        elseif ~ismember(component_feat, featName.encycl)
            if ismember(component_feat, feature_names)
                % component_feat is not relevant to fmri objects but
                % relevant to the entire set of 995 -- ignore for now
                continue
            else
                fprintf('feature %s NOT found \n', component_feat)
            end
        end

        % merge based on component_type
        component_feat_count = itemFeatures.fmri.(component_feat);
        switch component_type
            case 1 % + feature, flag for deletion
                merged_feat_count = merged_feat_count + component_feat_count;
                unused_feat = setdiff(unused_feat, component_feat);

            case 2 % + feature, don't flag for deletion
                merged_feat_count = merged_feat_count + component_feat_count;

            case 3 % - feature, flag for deletion
                merged_feat_count = merged_feat_count - component_feat_count;
                unused_feat = setdiff(unused_feat, component_feat);

            case 4 % - feature, don't flag for deletion
                merged_feat_count = merged_feat_count - component_feat_count;
        end

    end % component_feat
    feat_fmri_merged_encycl.(merged_feat) = merged_feat_count;

    if ~all(ismissing(merged_feat_class{i}))
        fprintf("********************\n********************\n********************\n * %s *\n", ...
            merged_feat_class{i})
    end
    fprintf("merged %d: '%s' \n", i, merged_feat)

end % merged_feat


%% check remaining individual features
clc
unused_feat'


%% add individual features
for feat = unused_feat
    feat = feat{1};
    feat_fmri_merged_encycl.(feat) = itemFeatures.fmri.(feat);
end
% save unthresholded version
save('data/feat_fmri_merged_encycl.mat', 'feat_fmri_merged_encycl')

%%
clear
clc
load('data/feat_fmri_merged_encycl.mat')
feat_fmri_merged_encycl
