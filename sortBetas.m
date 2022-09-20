% Sort subject-specific Enc betas into two bins: living and nonliving

% go to the correct folder and make sure I have access to what I need
cd('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/')
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed') % this has the betas, both smoothed and not smoothed
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Single_Trial_Betas_May_2020/Retrieval')
addpath('/Users/matthewslayton/Documents/GitHub/STAMP/')
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/spm12') %there are important SPM functions in spm12

subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

for subjects = 1:length(subjectNum)

    data_dir_enc = strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/'); % just folder, not content yet. 
    all_betas_enc = dir(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/*.nii')); % dir gives the file names

    for i = 1:300
            raw_filenames_enc{i} = [data_dir_enc all_betas_enc(i).name];
        end
        
        % sort the betas into living_betas and nonliving_betas folders
        cd(strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/betas/'));
        livingType_enc = zeros(2,300);
        for i=1:300 
            catNumCell = extractBetween(all_betas_enc(i).name,'Cat', '_Item'); %we want the category number
            catNum = cell2mat(catNumCell);
            source = all_betas_enc(i).name;
            livingDestination = strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/living_betas/');
            nonlivingDestination = strcat('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/S',subjectNum{subjects},'/nonliving_betas/');
            if ismember(catNum, ['1' '5' '8' '12']) == 1 % living
                copyfile(source,livingDestination); %living
            else
                copyfile(source,nonlivingDestination); % non-living
            end
        end

end