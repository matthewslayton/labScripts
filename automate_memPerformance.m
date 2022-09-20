% calculate mem performance for NetTMS

% HR = H / (H + M)
% FAR = FA / (FA + CR)
% d'  = HR - FAR (make sure to do norminvs) ---> normsinv(HR) - normsinv(FAR)
% c = -0.5 * (HR + FAR) (again, do norminvs) —> normsinv(HR)
% excel normsinv "Returns the inverse of the standard normal cumulative
% distribution." Is that the same as matlab norminv()?

% H = hit
% M = miss
% FA = false alarm
% CR = correction rejection

% Old = YES, New = NO
% Old said old: 1, 1 H
% Old said new: 1, 2 M
% New said old: 2, 1 FA
% New said new: 2, 2 CR

addpath /Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/5006/


subdir = '/Users/matthewslayton/Library/CloudStorage/Box-Box/ElectricDino/Projects/NetTMS/NetTMS_task/5006/';
cd (subdir)
output_files = dir('*.mat');
output_list = {output_files.name}.';


for curr = 1:length(output_list)
    currOutputCell = output_list(curr);
    currOutputMat = cell2mat(currOutputCell);
    strPos = strfind(currOutputMat,'_output');
    type = currOutputMat(strPos-4:strPos); % will be 'CRET_' or 'PRET_' or '_ENC_' there's probably a better way to do this
    if type == '_ENC_' % we only want CRET and PRET
        break
    end
    load(currOutputMat);

    oldNewCol = output_tbl.('OldNew');
    respCol = output_tbl.('resp');


    hit = 0;
    miss = 0;
    falseAlarm = 0;
    correctRej = 0;
    for row = 1:length(oldNewCol)
        if oldNewCol{row} == 2 && respCol{row} == 2
            correctRej = correctRej + 1; % do I have these right?
        elseif oldNewCol{row} == 2 && respCol{row} == 1
            falseAlarm = falseAlarm + 1;
        elseif oldNewCol{row} == 1 && respCol{row} == 1
            hit = hit + 1;
        else
            miss = miss + 1;
        end
    end

    % next calculate HR and FAR
    % HR = H / (H + M)
    % FAR = FA / (FA + CR)

    % calculate d' and c
    %%% I 'think' norminv() in matlab is the same thing
    % d'  = HR - FAR (make sure to do norminvs) ---> normsinv(HR) - normsinv(FAR)
    % c = -0.5 * (HR + FAR) (again, do norminvs) —> normsinv(HR)

    

end


