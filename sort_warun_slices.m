% the goal here is to sort the warun slices by living type
% let's just do S005 for now

% if I want to do all subjects. One for now is fine
% subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

clear all
  
%% Run 1
cd '/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/run01';

addpath('/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/');
% load the file names for S005 runs
run01_warun = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/run01/*.nii.gz');
run02_warun = dir('/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/run02/*.nii.gz');

% get times
load /Users/matthewslayton/Documents/GitHub/STAMP/timeSeries/S011_timeSeries.txt;
onsets = S011_timeSeries(:,1); 
% remember the image is shown for 0.5s

addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/')
load livingType_S011.mat

second_counter = 14; %start at 12s, skipping the first 6 nwarun files
onset_index = 1; % I'll have to increment by 1 each time the second_counter is bigger than the current onset
beta_counter = 1;
for i=7:490 % skip first 6 because first onset in run 1 is 12.234
    source = run01_warun(i).name;
    livingDestination = '/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/living_nwarun/';
    nonlivingDestination = '/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/nonliving_nwarun/';
    
    if second_counter > onsets(onset_index,1)
        if livingType_enc(1,beta_counter) == 1 % living
            copyfile(source,livingDestination); %living
        else
            copyfile(source,nonlivingDestination); % non-living
        end
        beta_counter = beta_counter + 1;
        onset_index = onset_index +1;

    else
        if livingType_enc(1,beta_counter) == 1 % living
            copyfile(source,livingDestination); %living
        else
            copyfile(source,nonlivingDestination); % non-living
        end
        % don't go to next beta or next onset
    end
    second_counter = second_counter+2; % TR is 2
end

%% Run 2
cd '/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/run02';


second_counter = 14; %start at 12s, skipping the first 6 nwarun files
onset_index = 150; % for run 2, start at onset 150
beta_counter = 150; % for run 2, start at beta 150
for i=10:490 % skip first 8 because the first onset in run 2 is 17.343
    source = run02_warun(i).name;
    livingDestination = '/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/living_nwarun/';
    nonlivingDestination = '/Users/matthewslayton/Documents/GitHub/STAMP/Wang_subjectFolders/S011/nonliving_nwarun/';
    
    if second_counter > onsets(onset_index,1)
        if livingType_enc(1,beta_counter) == 1 % living
            copyfile(source,livingDestination); %living
        else
            copyfile(source,nonlivingDestination); % non-living
        end
        beta_counter = beta_counter + 1;
        onset_index = onset_index +1;

    else
        if livingType_enc(1,beta_counter) == 1 % living
            copyfile(source,livingDestination); %living
        else
            copyfile(source,nonlivingDestination); % non-living
        end
        % don't go to next beta or next onset
    end
    second_counter = second_counter+2; % TR is 2
end