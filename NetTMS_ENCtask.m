function NetTMS_ENCtask
%% NetTMS experiment 
%
% ToDo List:
% -X- change the input folders from the "results" folders to the subject-specific folder
% -X- change pdata from a struct to a big table (true across all 3 scripts)
% -X- do checks to make sure the scene/object scheme is overwritten
% -X- make sure the results check for overwriting are correct ('day')
% -X- can numTrials and nTrials be combined? Guess it doesn't really matter
% -X- remove the copy of stimtbl that saves to main folder after running 
% -X- fix run 1 stimuli presenting for all runs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% color: choose a number from 0 (black) to 255 (white)
backgroundColor = 255;
textColor = 0;
textSize=43;

object1Timeout = 2;
object2Timeout = 2;
respTimeout = 4;
%numtrials = 2; %remove after tesing save
numtrials = 20;         % number of trials per run
tmod = 1; % use this to modify object presentation time

% time of stimuli and ITI
ITIfixationDuration = jitterITI(numtrials); % Lengths of fixation in seconds before every trial, with jitter
objectTimeout = 4 * tmod;

pdata=struct;
output = struct; % use this later to save as table
pdata.sub_no=input('Enter subject number (5xxx): ');
pdata.day_no=input('Enter day: ');
pdata.run_no=input('Enter run number: ');
subid = pdata.sub_no;
assert(isnumeric(pdata.run_no))


resultsFolder = num2str(subid);
if exist(fullfile(resultsFolder,[num2str(subid) '_day' num2str(pdata.day_no) '_run' num2str(pdata.run_no) 'ENC_output.mat']),'file')
    ButtonName = questdlg('do you wish to overwrite the data?', ...
        'existing file detected', ...
        'Yes', 'No','No');
    if strcmp(ButtonName,'No')
        return
    end
end

% make sure stimtbl file is ready
inputdata = sprintf('%d/%d_day%d_stimtbl_ENC.csv', subid, subid, pdata.day_no);
stimtbl = readtable(inputdata);
if stimtbl.Day ~= pdata.day_no
    disp(['Day number input doesn''t match. ' ...
        'Check to see if the stimtbl csv file has the correct day number in Day col'])
    return
end

% the csv file is imported with a header that older versions of matlab
% can't read (ex. "x___ID1")
stimtbl.Properties.VariableNames(2) = {'ID1'};

%selecting the right stim for the run by deleting the first 20 or 40 rows
%of stimtbl. Line below solved this. 

stimtbl=stimtbl((1:numtrials)+(pdata.run_no-1)*numtrials,:);

pdata.timestamp = datestr(now,'yyyymmddTHHMMSS');disp(pdata.timestamp);
pdata.s_ID_n_Run=[num2str(subid) '_day' num2str(stimtbl.Day(pdata.day_no)) '_run' num2str(pdata.run_no)];
%return% for testing the first cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the image files for the experiment
imageFolder = 'DinoLabObjects';
imgList1 = stimtbl.Object1File;
imgList2 = stimtbl.Object2File;
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
KbCheckList = [KbName('space'),ButOne,ButTwo,ButThr,ButFour,ButEsc];
RestrictKeysForKbCheck(KbCheckList);
% Screen setup
clear screen
 Screen('Preference', 'SkipSyncTests', 1);% !! REMOVE THIS LINE WHEN SCRIPT IS FINALIZED
whichScreen = max(Screen('Screens'));
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor); % 
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
%maybe load the instruction image?
imgI = imread(fullfile('instructionPics','ENCinstructions.png'));
imageDisplayInstruction = Screen('MakeTexture', window1, imgI);
imageSizeI = size(imgI);

tmpscale=[W/imageSizeI(2),(H-2*textSize)/imageSizeI(1)];% NEW 11/01
tmpscale=min(tmpscale);disp(tmpscale);
imageSizeI=imageSizeI*tmpscale*0.95;

posI = [(W-imageSizeI(2))/2 (H-imageSizeI(1))/2 (W+imageSizeI(2))/2 (H+imageSizeI(1))/2];
Screen('DrawTexture', window1, imageDisplayInstruction, [], posI);

DrawFormattedText(window1, 'Press any button to begin','center', 800, textColor)
Screen('Flip',window1)
disp('start task screen')


%Wait for subject to press key
while 1
   [~,~,keyCode] = KbCheck;
   if keyCode(ButOne) || keyCode(ButTwo) || keyCode(ButThr) || keyCode(ButFour) 
       break
   end
end

Screen('DrawTexture', window1, imageDisplayInstruction, [], posI);
DrawFormattedText(window1, 'Waiting for MR technologist to start','center', 800, textColor)
Screen('Flip',window1)


%Wait for tech to start scanning
while 1
    [~,~,keyCode] = KbCheck;
   if keyCode(KbName('space'))
       break
   end
   if keyCode(ButEsc)
       sca;
       return
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
for t = 1:numtrials 
   %pdata.nTrials    % loop through trials 
    disp(t)
            
    % Load image
    file1 = imgList1{t};
    img1 = imread(fullfile(imageFolder,file1));
    imageDisplayObject1 = Screen('MakeTexture', window1, img1);
    
    file2 = imgList2{t};
    img2 = imread(fullfile(imageFolder,file2));
    imageDisplayObject2 = Screen('MakeTexture', window1, img2);
    
    % Calculate image position (center of the screen)
    imageSize1 = size(img1)*0.75;
    posO1 = [(W-imageSize1(2))/2 (H-imageSize1(1))/2 (W+imageSize1(2))/2 (H+imageSize1(1))/2];
    imageSize2 = size(img2);
    imageSize2 = imageSize2*0.75;
    posO2 = [(W-imageSize2(2))/2 (H-imageSize2(1))/2 (W+imageSize2(2))/2 (H+imageSize2(1))/2];
    
    % Show fixation cross
    drawCross(window1,W,H);
    Screen('Flip', window1);
    WaitSecs(ITIfixationDuration(t)+1-0.05-slack);

    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1);
    
    %find object1 onset time
    tObject1Onset=GetSecs-tStart;
    abs1Onset = GetSecs;
    
    % Show the first object
    Screen(window1, 'FillRect', backgroundColor);
    Screen('FrameRect', window1, 0, [posO1(1)-5,posO1(2)-5,posO1(3)+5,posO1(4)+5], 5);% NEW 10/30
    Screen('DrawTexture', window1, imageDisplayObject1, [], posO1);
    %Screen('DrawText', window1, 'this needs to be replaced', (W/2), posO1(4), textColor);%!!! REPLACE 'textstring'
    DrawFormattedText(window1, stimtbl.Object1DisplayName{t},'center', textSize+posO1(4), textColor);
    Screen('Flip', window1); % Start of trial
    WaitSecs(object1Timeout-slack);
    
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('FrameRect', window1, 0, [posO1(1)-5,posO1(2)-5,posO1(3)+5,posO1(4)+5], 5);% NEW 10/30
    Screen('Flip', window1);
    WaitSecs(ITIfixationDuration(numtrials+1-t)+1-slack); 
    %WaitSecs(ITIfixationDuration(pdata.nTrials+1-t)+1-slack); % 

    % find object2 image onset time
    tObject2Onset=GetSecs-tStart;
    abs2Onset = GetSecs;
    
    % Show the second object
    Screen(window1, 'FillRect', backgroundColor);
    Screen('FrameRect', window1, 0, [posO1(1)-6,posO1(2)-6,posO1(3)+6,posO1(4)+6], 5);% NEW 10/30
    Screen('DrawTexture', window1, imageDisplayObject2, [], posO2);
    DrawFormattedText(window1, stimtbl.Object2DisplayName{t},'center', textSize+posO2(4), textColor);%!!! REPLACE 'textstring'
    startTime = Screen('Flip', window1); % Start of trial
    WaitSecs(object2Timeout-slack);
        
    % Response window (w/ cues)
    DrawFormattedText(window1, '1 = Related\n\n 2 = Unrelated', 'center', H/3, textColor); % sy=='center'
    Screen('Flip',window1)
    
    
    % Get keypress response
    rt = NaN;
    resp = NaN;
    while GetSecs - startTime < respTimeout
        [~,secs, keyCode] = KbCheck;
        if keyCode(ButEsc)
            ShowCursor;
            output_tbl = struct2table(output); 
            save(fullfile(resultsFolder,[pdata.s_ID_n_Run '_ENC_output_esc.mat']), 'output_tbl')
            sca;
            return
        elseif keyCode(ButOne)
            resp = 1;
            rt = secs - startTime;
            DrawFormattedText(window1, '1 = Related', 'center', H/3, textColor);
            Screen('Flip', window1);
        elseif keyCode(ButTwo)
            resp = 2;
            rt = secs - startTime;
            DrawFormattedText(window1, '\n\n 2 = Unrelated', 'center', H/3, textColor);
            Screen('Flip', window1);
        elseif keyCode(ButThr)
            resp = 3;
            rt = secs - startTime;
        elseif keyCode(ButFour)
            resp = 4;
            rt = secs - startTime;
        end
    end %end while
    
    
    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1);

    % output info
    output.sub_no{t,1} = pdata.sub_no;
    output.day_no{t,1} = pdata.day_no;
    output.run_no{t,1} = pdata.run_no;
    
    output.imageFolder{t,1}=imageFolder;
    output.trial_no{t,1}=t;
    output.object1{t,1}=stimtbl.Object1DisplayName{t};
    output.object2{t,1}=stimtbl.Object2DisplayName{t};
    output.Similarity{t,1}=stimtbl.Similarity(t);
    output.PairID{t,1}=stimtbl.PairID(t);% a unique 3-digit ID for the stimuli pair
    output.ID1{t,1}=stimtbl.ID1(t);
    output.ID2{t,1}=stimtbl.ID2(t);
    output.Day{t,1}=stimtbl.Day(t);
    output.EncRun{t,1}=stimtbl.EncRun(t);

    output.resp{t,1}=resp;
    output.rt{t,1}=rt;
    output.tObj1Onset{t,1}=tObject1Onset;% this is the onset of scene image
    output.abs1Onset{t,1} = abs1Onset;
    output.abs1Onset{t,1} = abs2Onset;
    output.tObj2Onset{t,1}=tObject2Onset;% this is the onset of object image
    
    % Clear textures
    Screen(imageDisplayObject1,'Close');
    Screen(imageDisplayObject2,'Close');
    
end

DrawFormattedText(window1, 'End of Run', 'center', H/2, textColor); % sy=='center'
Screen('Flip', window1);

% WaitSecs(5); % at the end of the trials add some time of just blank screen
output_tbl = struct2table(output); 
save(fullfile(resultsFolder,[pdata.s_ID_n_Run '_ENC_output.mat']), 'output_tbl')




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