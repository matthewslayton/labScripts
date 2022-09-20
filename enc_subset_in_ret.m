% these are notes that go with slayton_mvpa



% Encoding had 300 items, so 300 betas.
% Retrieval has 400 items, the 300 from Enc and 100 new ones.
% In order to compare like with like, we have to take out the betas that
% correspond with items that the Ps didn't see on the Enc trial.
% I really should just make a function that does this, but for now
% it'll be plenty to save the betas that I need. No need to run them
% in slayton_mvpa.m I can just load them


subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};
% can use subjects = 1 and subjectNum = '002' for testing
data_dir_ret = '/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S002/betas/'; % just folder, not content
all_betas_ret = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S002/betas/*.nii');
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/')
itemIDs_tbl = readtable('itemIDs.xlsx'); % this has all 995 item IDs and labels
empty_struct = struct;


for subjects = 1:length(subjectNum) 

    all_betas_ret = dir('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval/S',subjectNum{subjects},'/betas/*.nii');
    load(strcat('IDs_S',subjectNum{subjects},'withNaN')) % load the IDs of enc items. IDs_old
   
    % need to cut the 400 IDs down to 300 and do the same to the
    % corresponding betas
    for i = 1:400
        %%%% need to make this thing 300 long, only adding filenames when
        %%%% IDs equals a number
        if isnan(IDs(i))
            raw_filenames_ret{i} = NaN;
        
        else
        raw_filenames_ret{i} = [data_dir_ret all_betas_ret(i).name]; 
        end
    end

    % remove the values with NaN and you get a 1x300 cell
    raw_filenames_ret(cellfun(@(raw_filenames_ret) any(isnan(raw_filenames_ret)),raw_filenames_ret)) = [];


    betas = load_spm_pattern(empty_struct, '300_pattern',~,raw_filenames_ret);



    load_spm_pattern

    % put all 400 betas in struct
    % use indices_inOrder to tell me which files to put into a new struct
    % to do that I have to load the filenames of the 300 I want

    % use load_spm_pattern to read values from the betas, but only save values
% within the mask. Call the saved pattern (within the mask) 'epi'
subj = load_spm_pattern(subj, 'epi', 'OcG_L', raw_filenames_enc);
% the pattern should be a matrix with dims nVox x nTRs


    currFileName = all_betas_ret(subjects).name;
    
    for row = 1:length(indices_inOrder)
        all_betas_ret(row,:) = score(indices_inOrder(row),:); % the entire row which is all the PCs
    
    end
    
    % score_subset will have all PCs, in order, with the IDs, which are in
    % order in IDs_300
    
    save('score_subset_pmem_IDsInOrder','score_subset')

end 