% makes the Hebart-style adj R^2 prediction plots.
% copied from predict_mturk_mem_betas_withPCs.m
% that script uses PCs and Factors to predict memorability scores
% This script is focused on predicting activity in custom ROIs.
% go to PCs_betas_lmer_customROIs.m to get the code that prepares 
% the table of subject IDs, item IDs, PCs, Factors, and average activity per ROI
% activityPerTrialPerCustomCluster_cortney.m makes the custom ROIs based on the masks
% that I make using fsl

cd '/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP';
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/STAMP_scripts;


% custom ROI activity
load subjInfo_customROIs.mat
subjInfo_c = subjInfo;

% custom ROI activity but they're shortened to the same length
%load subjInfo_short.mat % this has the PCs and Fs I need but activity not averaged
load subjInfo_short_m40.mat

load activityMean_allSubj.mat % this has averaged activity

% atlas ROI activity
load subjInfo.mat


% fugL = 3
% fugR = 4
% hippL = 5
% hippR = 6
% phgL = 17
% phgR = 18

% need PCs, Factors and ROI-specific activity
% the one is for subject 1
% subjInfo(1).activityVal
% subjInfo(1).PCval 
% subjInfo(1).Fval
% ^the PCs and Factors will be the same for all subjects

% because of the false alarms, the subject-specific activity values are not
% the same length. The smallest is S021 at 249. I can use their TT3/4
% values to cut the others




% subjInfo.activityVal(:,ROI)
% ROI = 7 for fusiform/cerebellum cluster
% ^do I need to average these for all subjects?

% I need average activity for all subjects AND I need the lengths to match
% so, I need to cut the PCs, Factors, and activity values to the length of
% the shortest one

% Or, I do one subject's activity and add one PC or Factor at a time.
% Can even plot the curves for all 19 subjects


%% add PCs one at a time to see how well they predict memory
% ^this is based on the PCA on the raw feature matrix
num_PCs = 200;
subjNum = 1;
% custom ROIs
% activity = subjInfo_c(subjNum).activityVal(:,7);
% PC_mat = subjInfo_c(subjNum).PCval;

% custom ROIs plus averaged activity
activity = activityMean_allSubj(:,7);
PC_mat = subjInfo_short(1).PCval; %doesn't matter what subj because PCs the same

% atlas ROIs
% activity = cell2mat(subjInfo(subjNum).tmpVal(18))';
% PC_mat = subjInfo(subjNum).PCval;

adj_r_sqr = zeros(num_PCs,1);
r_sqr = zeros(num_PCs,1);
for pc_val = 1:num_PCs

    mdl_struct = fitlm(PC_mat(:,1:pc_val),activity);
    adj_r_sqr(pc_val) = mdl_struct.Rsquared.Adjusted;
    r_sqr(pc_val) = mdl_struct.Rsquared.Ordinary;

end

% flip array left and right
y_val_adjRsqr = fliplr(adj_r_sqr);
y_val_Rsqr = fliplr(r_sqr);

% residual error (y_actual - y_predicted)^2
resid_error_calc = (activity - mdl_struct.Fitted).^2;
% remove the rows with NaN
resid_error_calc(any(isnan(resid_error_calc), 2), :) = [];
resid_error = sum(resid_error_calc);


x = 1:num_PCs;
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
figure

plot(x,y_val_adjRsqr,'LineWidth',2)
hold on
plot(x,y_val_Rsqr,'LineWidth',2)

xlabel('PCs as dimensions')
ylabel('Variance Explained')
title('Prediction of Activity in Mem-related cluster in Fusiform/Cerebellum')
legend('Adj-Rsqr','Ord-Rsqr')
text(4,max(y_val_Rsqr)/2,horzcat('residual error: ',num2str(resid_error)))
hold off



%% PCs, plot all subjects separately

num_PCs = 10;
figure

for subjNum = 1:19

    % custom ROIs
%     activity = subjInfo_c(subjNum).activityVal(:,7);
%     PC_mat = subjInfo_c(subjNum).PCval;
    % atlas ROIs
    activity = cell2mat(subjInfo(subjNum).tmpVal(4))';
    PC_mat = subjInfo(subjNum).PCval;
    adj_r_sqr = zeros(num_PCs,1);
    r_sqr = zeros(num_PCs,1);
    for pc_val = 1:num_PCs
    
        mdl_struct = fitlm(PC_mat(:,1:pc_val),activity);
        adj_r_sqr(pc_val) = mdl_struct.Rsquared.Adjusted;
        r_sqr(pc_val) = mdl_struct.Rsquared.Ordinary;
    
    end
    
    % flip array left and right
    y_val_adjRsqr = fliplr(adj_r_sqr);
    y_val_Rsqr = fliplr(r_sqr);
    
    % residual error (y_actual - y_predicted)^2
    resid_error_calc = (activity - mdl_struct.Fitted).^2;
    % remove the rows with NaN
    resid_error_calc(any(isnan(resid_error_calc), 2), :) = [];
    resid_error = sum(resid_error_calc);
    
    x = 1:num_PCs;
    set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
    
    plot(x,y_val_adjRsqr,'LineWidth',2)
    hold on
    plot(x,y_val_Rsqr,'LineWidth',2)

end
xlabel('PCs as dimensions')
ylabel('Variance Explained')
title('Prediction of Activity in Right Fusiform Gyrus')
%legend('Adj-Rsqr','Ord-Rsqr')
%text(4,max(y_val_Rsqr)/2,horzcat('residual error: ',num2str(resid_error)))
hold off


%% add factors one at a time
num_Fs = 40;
subjNum = 1;
% custom ROIs
% activity = subjInfo_c(subjNum).activityVal(:,7);
% F_mat = subjInfo_c(subjNum).Fval;

% custom ROIs plus averaged activity
activity = activityMean_allSubj(:,7);
F_mat = subjInfo_short(1).Fval; %doesn't matter what subj because PCs the same

% atlas ROIs
% activity = cell2mat(subjInfo(subjNum).tmpVal(18))';
% F_mat = subjInfo(subjNum).Fval;

adj_r_sqr = zeros(num_Fs,1);
r_sqr = zeros(num_Fs,1);
for f_val = 1:num_Fs

    mdl_struct = fitlm(F_mat(:,1:f_val),activity);
    adj_r_sqr(f_val) = mdl_struct.Rsquared.Adjusted;
    r_sqr(f_val) = mdl_struct.Rsquared.Ordinary;

end

% flip array left and right
y_val_adjRsqr = fliplr(adj_r_sqr);
y_val_Rsqr = fliplr(r_sqr);

% residual error (y_actual - y_predicted)^2
resid_error_calc = (activity - mdl_struct.Fitted).^2;
% remove the rows with NaN
resid_error_calc(any(isnan(resid_error_calc), 2), :) = [];
resid_error = sum(resid_error_calc);


x = 1:num_Fs;
set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
figure

plot(x,y_val_adjRsqr,'LineWidth',2)
hold on
plot(x,y_val_Rsqr,'LineWidth',2)

xlabel('Factors as dimensions')
ylabel('Variance Explained')
title('Prediction of Activity in Mem-related cluster in Fusiform/Cerebellum')
legend('Adj-Rsqr','Ord-Rsqr')
text(4,max(y_val_Rsqr)/2,horzcat('residual error: ',num2str(resid_error)))
hold off

%% Factors, plot all subjects separately

num_Fs = 10;
figure

for subjNum = 1:19

    % custom ROIs
%     activity = subjInfo_c(subjNum).activityVal(:,7);
%     F_mat = subjInfo_c(subjNum).Fval;
    % atlas ROIs
    activity = cell2mat(subjInfo(subjNum).tmpVal(4))';
    F_mat = subjInfo(subjNum).Fval;
    adj_r_sqr = zeros(num_Fs,1);
    r_sqr = zeros(num_Fs,1);
    
    for f_val = 1:num_Fs
    
        mdl_struct = fitlm(F_mat(:,1:f_val),activity);
        adj_r_sqr(f_val) = mdl_struct.Rsquared.Adjusted;
        r_sqr(f_val) = mdl_struct.Rsquared.Ordinary;
    
    end
    
    % flip array left and right
    y_val_adjRsqr = fliplr(adj_r_sqr);
    y_val_Rsqr = fliplr(r_sqr);
    
    % residual error (y_actual - y_predicted)^2
    resid_error_calc = (activity - mdl_struct.Fitted).^2;
    % remove the rows with NaN
    resid_error_calc(any(isnan(resid_error_calc), 2), :) = [];
    resid_error = sum(resid_error_calc);
    
    
    x = 1:num_Fs;
    set(0,'defaultfigurecolor',[1 1 1]) %set background of plot to white
    
    plot(x,y_val_adjRsqr,'LineWidth',2)
    hold on
    plot(x,y_val_Rsqr,'LineWidth',2)

end

xlabel('Factors as dimensions')
ylabel('Variance Explained')
title('Prediction of Activity in Right Fusiform Gyrus')
%legend('Adj-Rsqr','Ord-Rsqr')
%text(4,max(y_val_Rsqr)/2,horzcat('residual error: ',num2str(resid_error)))
hold off


