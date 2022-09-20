function NetTMS_RETtask1_conceptual
% To Do
% - remove the copy of stimtbl that saves to main folder after running
% - fix run 1 stimuli presenting for all runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Screen('Preference', 'SkipSyncTests', 1); 

% color: choose a number from 0 (black) to 255 (white)
backgroundColor = 255;
textColor = 0;
textSize = 45;
numtrials = 40;
tmod = 1; % use this to modify object presentation time

% time of stimuli and ITI
ITIfixationDuration = jitterITI(numtrials);%3 + 2*rand(48,1); % Lengths of fixation in seconds before every trial, with jitter
while mean(ITIfixationDuration)>4.2 || mean(ITIfixationDuration)<3.8
   ITIfixationDuration = 3 + 2*rand(48,1); % limit the total ITI time between 144.4 ~ 159.6 secs
end
objectTimeout = 6 * tmod;

pdata=struct;
output = struct; % use this later to save as table
pdata.sub_no=input('Enter subject number (5xxx): ');
pdata.day_no=input('Enter day: ');
pdata.run_no=input('Enter run number (1-4): ');
subid = pdata.sub_no;
assert(isnumeric(pdata.run_no))

resultsFolder = num2str(subid);
if exist(fullfile(resultsFolder,[num2str(subid) '_day' num2str(pdata.day_no) '_run' num2str(pdata.run_no) 'CRET_output.mat']),'file')
    ButtonName = questdlg('do you wish to overwrite the data?', ...
        'existing file detected', ...
        'Yes', 'No','No');
    if strcmp(ButtonName,'No')
        return
    end
end

% make sure stimtbl file is ready
% %s forces subid to be loaded as a string. Day_no can be loaded as char
inputdata = sprintf('%d/%d_day%d_stimtbl_CRET.csv', subid, subid, pdata.day_no);
stimtbl = readtable(inputdata);
if stimtbl.Day ~= pdata.day_no
    disp(['Day number input doesn''t match. ' ...
        'Check to see if the stimtbl csv file has the correct day number in Day col'])
    return
end

% the csv file is imported with a header that older versions of matlab
% can't read (ex. "x___ID1")
% this fixes it
stimtbl.Properties.VariableNames(2) = {'ID1'};

% present only stimuli for correct run
stimtbl=stimtbl((1:numtrials)+(pdata.run_no-1)*numtrials,:);

pdata.timestamp = datestr(now,'yyyymmddTHHMMSS');disp(pdata.timestamp);
pdata.s_ID_n_Run=[num2str(subid) '_day' num2str(stimtbl.Day(pdata.day_no)) '_run' num2str(pdata.run_no)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%pdata.nTrials = size(stimtbl,1);

%% experiment setups
% Keyboard setup
KbName('UnifyKeyNames');
%rand('state', sum(100*clock)); % Initialize the random number generator
ButOne=KbName('1!');
ButTwo=KbName('2@');
ButThr=KbName('3#');
ButFour=KbName('4$');
ButEsc = KbName('ESCAPE');
ButLeft = KbName('LeftArrow');
ButRight = KbName('RightArrow');

KbCheckList = [KbName('space'),ButOne,ButTwo,ButThr,ButFour,ButEsc,ButLeft,ButRight];
RestrictKeysForKbCheck(KbCheckList);
% Screen setup
clear screen
%Screen('Preference', 'SkipSyncTests', 1);% !! REMOVE THIS LINE WHEN SCRIPT IS FINALIZED
whichScreen = max(Screen('Screens'));
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor);
slack = Screen('GetFlipInterval', window1)/2;% minor adjustment
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);

Screen('TextSize',window1,textSize) % set text size
Screen('Flip', window1);
disp('experiment setups done')
% Screen priority
Priority(MaxPriority(window1));
Priority(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start screen
Screen('DrawText',window1, ' ', (W/2-300), (H/2), textColor);
%maybe load the instruction image?

imgI = imread(fullfile('instructionPics','RET_Cinstructions.png'));
imageDisplayInstruction = Screen('MakeTexture', window1, imgI);
imageSizeI = size(imgI);

tmpscale=[W/imageSizeI(2),(H-2*textSize)/imageSizeI(1)];% NEW 11/01
tmpscale=min(tmpscale);disp(tmpscale);
imageSizeI=imageSizeI*tmpscale*0.95;

posI = [(W-imageSizeI(2))/2 (H-imageSizeI(1))/2 (W+imageSizeI(2))/2 (H+imageSizeI(1))/2];
Screen('DrawTexture', window1, imageDisplayInstruction, [], posI);

DrawFormattedText(window1, 'Press spacebar when ready','center', 900, textColor)
Screen('Flip',window1)
% Wait for subject to signal they are ready
while 1
   [~,~,keyCode] = KbCheck;
   if keyCode(KbName('space')) 
       break
   end
end
Screen('DrawTexture', window1, imageDisplayInstruction, [], posI);

% Blank screen
Screen(window1, 'FillRect', backgroundColor);
Screen('Flip', window1);

countdownScreen(window1); % wait 8 secs for magnetization to normalize 20210927

tStart=GetSecs; % when working within SPM, be aware that there's 8-sec difference between the start of fMRI and the start of task
pdata.tStart = tStart;


% Run experimental trials
for t = 1:numtrials %pdata.nTrials    % loop through trials (38 trials per run)
    disp(t)
    
    % Show fixation cross
    drawCross(window1,W,H);
    Screen('Flip', window1);
    WaitSecs(ITIfixationDuration(t)-0.55-slack);
    WaitSecs(1);
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1);
    
    %find object1 onset time
    tObject1Onset=GetSecs-tStart;
    abs1Onset = GetSecs;
    
    % Show the object images
    Screen(window1, 'FillRect', backgroundColor);
    DrawFormattedText(window1, stimtbl.Object1DisplayName{t},'center', H/2, textColor);%!!! REPLACE 'textstring'
    DrawFormattedText(window1, '<= Old       New =>', 'center', H-(H/6), textColor); % sy=='center'

    startTime = Screen('Flip', window1); % Start of trial   

    if keyCode(ButEsc)
            ShowCursor;
            output_tbl = struct2table(output); 
            save(fullfile(resultsFolder,[pdata.s_ID_n_Run '_CRET_output_esc.mat']), 'output_tbl')
            sca;
            return
    end 
    
    % Get keypress response
    rt = NaN;
    resp = NaN;
    
    while GetSecs - startTime < objectTimeout
        [~,secs, keyCode] = KbCheck;
        if keyCode(ButEsc)
            ShowCursor;
            output_tbl = struct2table(output); 
            save(fullfile(resultsFolder,[pdata.s_ID_n_Run '_CRET_output_esc.mat']), 'output_tbl')
            sca;
            return
        elseif keyCode(ButLeft)
            resp = 1;
            rt = secs - startTime;
            break
        elseif keyCode(ButRight)
            resp = 2;
            rt = secs - startTime;
            break
        end
    end %end while
    
   
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1);
    
    % output info
    output.sub_no{t,1} = pdata.sub_no;
    output.day_no{t,1} = pdata.day_no;
    output.run_no{t,1} = pdata.run_no;
    
    output.trial_no{t,1}=t;
    output.object{t,1}=stimtbl.Object1DisplayName{t};
    output.PairID{t,1}=stimtbl.PairID(t);% a unique 3-digit ID for the stimuli pair
    output.OldNew{t,1}=stimtbl.OldNew(t);
    % output.stimID{t,1}=stimtbl.x___ID1(t); %only use for testing on igunadon
    output.stimID{t,1}=stimtbl.ID1(t); 
    output.Similarity{t,1}=stimtbl.Similarity(t); %
    
    output.resp{t,1}=resp;
    output.rt{t,1}=rt;
    output.tObjOnset{t,1}=tObject1Onset;% this is the onset of object image
    output.abs1Onset{t,1} = abs1Onset;
    output.tStart{t,1} = pdata.tStart;
    output.Day{t,1}=stimtbl.Day(t);
    output.EncRun{t,1}=stimtbl.EncRun(t);
    output.RetRun{t,1}=stimtbl.RetRun(t);

end

DrawFormattedText(window1, 'End of Run', 'center', H/2, textColor); % sy=='center'
Screen('Flip', window1);

% WaitSecs(5); % at the end of the trials add some time of just blank screen
output_tbl = struct2table(output); 
save(fullfile(resultsFolder,[pdata.s_ID_n_Run '_CRET_output.mat']), 'output_tbl')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment (don't change anything in this section)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
Screen(window1,'Close');
close all
sca;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw a fixation cross (overlapping horizontal and vertical bar)
function drawCross(window,W,H)
barLength = 30; % in pixels
barWidth = 5; % in pixels
barColor = 0.3; % number from 0 (black) to 1 (white)
Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end

