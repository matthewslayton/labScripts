% I have to make a time series text file to use with ICA
% The sample has three columns separated by three spaces
% first col is stimulus time in (s)
% second col is for how long (s)
% third col is all 1

% In STAMP, Ps see:
% fixation cross for 500ms
% single letter probe for 250ms
% object image for 500ms
% blank screen for 2 to 7 s
% I need to get the subject-wise onsets and then write text files.
cd '/Users/matthewslayton/Documents/GitHub/STAMP/Behav/'

subjectNum = {'002' '005' '006' '008' '009' '010' '011' '013' '014' '015' '016' '018' '019' '021' '022' '023' '024' '025' '026'};

for subjects = 1:length(subjectNum)

    % import items newenc_final2 file for each subject
    addpath(strcat('S',subjectNum{subjects}));
    newEnc = readtable(strcat('newencS',subjectNum{subjects},'_final2.xlsx'));
    onsets = newEnc{:,'onset'};

    % at this point onsets has 360. Need to remove the catch trials.

    % to do that, remove the rows where newCMEM is 0
    % note: newCMEM and newPMEM have 0s in the same rows. I'm just
    % arbitrarily picking newCMEM to be my source of 0s
    catchAreZeros = newEnc{:,'newCMEM'};

    for row = 1:numel(onsets)
        if catchAreZeros(row) == 0
            onsets(row) = NaN;
        end
    end

    % remove the catch trials
    onsets_300 = onsets(~isnan(onsets)); 
    secondCol = zeros(numel(onsets_300),1) + 0.5;
    thirdCol = zeros(numel(onsets_300),1) + 1;

    % write that table now

    threeCol_tbl = table(onsets_300,secondCol,thirdCol);
        
    writetable(threeCol_tbl,strcat('S',subjectNum{subjects},'_timeSeries.txt'));
  

end