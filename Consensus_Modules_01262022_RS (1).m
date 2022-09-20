%% Script information
% Script (1) gets data from the server (optional), (2) creates group and individual matrices, and (3) gets consensus modules
% Madden Script (Get Data) : Ragini 1/19/2022
% Consensus modularity & partition distance functions added by MDR 01/20/2021
% Note: Script currently assumes using Brainnetome atlas for comparison; edit as needed


%% User Setup
skip_load = 1; % If saved matrices, no need to regenerate them; Set to 0 otherwise.
    connectome_data = 'connectomes.mat';  % Set if not skipping and have matrices already
    datapath = 'O:\Analysis\Resting\RestingPipeline\Graph_theory\zr_matrices_32p\*.csv'; % Set if not skipping
    %datapath = '/Volumes/Data/Madden/VisAtten.03/Analysis/Resting/RestingPipeline/Graph_theory/zr_matrices_32p/*.csv';  %Local setting
gammas=[1,1.1,1.15,1.2,1.25,1.3,1.35,1.4,1.45,1.5,1.55,1.6,1.65,1.7,1.75];
cutoff = .5; %threshold the agreement matrix; default = 0.5 (proportion >= 50%)
iters = 150; % number of times to perform community detection (e.g. 150 or higher)
parcellation = 'Yeo7'; % name of parcellation/atlas to use
load('brainnetome_labels.mat'); % Assumes you have a master file with all network partitions; Brainnetome atlas



%% Begin Script

% Get files from server or load matrices
if skip_load == 0
    dir_files = dir(datapath);
    
    for f=1:length(dir_files); PatientTable{1,1,f} = load([dir_files(f).folder filesep dir_files(f).name]); end
    PatientTable3d = double(cell2mat(PatientTable));
    for n = 1:size(PatientTable3d,1); PatientTable3d(n,n,:) = 0; end; % Set Diagonal to Zero
    
    %% Create 3D Matrix of All Subjects with No Negatives (row x column x patient)
    PatientTable3d_positive = cell2mat(PatientTable);
    
    % Set Diagonal to Zero
    for n = 1:size(PatientTable3d_positive,1)
        PatientTable3d_positive(n,n,:) = 0;
    end
    
    % Delete Necessary ROIs for With All Partitions
    ROIs_with_zeroes = [211:246];
    %     206,237,239,245,246,251,263,274:300]; % CHANGE PER STUDY
    
    PatientTable3d_positive(ROIs_with_zeroes,:,:) = [];
    PatientTable3d_positive(:,ROIs_with_zeroes,:) = [];
    
    MasterMatrix_positive_values = PatientTable3d_positive;
    
    % Make Negative Values Equal to Zero
    MasterMatrix_positive_values(MasterMatrix_positive_values < 0) = 0;
    %% Settings to change per run (see notes above)
    master_connectome(:,:,:)=MasterMatrix_positive_values;% Change master_connectome to connectome matrix
    numSubs=size(master_connectome,3); % Number of participants, for VisAtten.03 it should be 68
    AtlasSize=size(master_connectome,1); % Ensure this value is connectome size
    
    %% Create Average Connectome
    for i=1:AtlasSize
        for j=1:AtlasSize
            master_avg_connectome(i,j)=mean(master_connectome(i,j,:),3);
        end
    end
    clear i j
    
else
    
    % Load existing data
    load(connectome_data);
    numSubs=size(master_connectome,3); % Number of participants, for VisAtten.03 it should be 68
    AtlasSize=size(master_connectome,1); % Ensure this value is connectome size

end


%% Get Parcellation Modules
% Used to compute partition distance (e.g. compare data-driven consensus modules to existing partition
switch parcellation
    case 'Brainnetome'
        apriori_coms = brainnetome_mods(1:AtlasSize,1);
    case 'Yeo7'
        apriori_coms = yeo_7networks(1:AtlasSize,1);
    case 'Yeo17'
        apriori_coms = yeo_17networks(1:AtlasSize,1);
end


%% Get Group Consensus Modules
% This section is getting the group average, data-driven modules for all N participants
% Key ouput consensus_partition, number_of_modules, & partition_distance_groupMods
% Data saved to .mat file and modules output to xlsx file

clear U Consensus_partition number_of_modules
clear K agreement_value_thresholded agreement_value_proportion agreement_value_thresholded U Q_Group M_Group M Q
nGammas = length(gammas);

for g=1:nGammas
    for i = 1:iters % Run this 150 plus times
        [M, Q] = community_louvain(master_avg_connectome(:,:),gammas(g));
        Q_Group(i,g) = Q; M_Group(:,i,g) = M;
        clear M Q
        
    end
    K = agreement(M_Group(:,:,g));
    agreement_value_thresholded(:,:)=[ K]./iters;
    agreement_value_thresholded(agreement_value_thresholded < cutoff) = 0;
    
    %% Consensus partition for average
    U = consensus_und(agreement_value_thresholded,cutoff,iters);
    Consensus_partition(:,g) =[U];
    
    %% Maximum number of modules
    number_of_modules(g,1) = max(Consensus_partition(:,g));
    
    clear K agreement_value_thresholded agreement_value_proportion agreement_value_thresholded U
    
end

modularity_group_average = mean(Q_Group); % Group modularity (Q) across all iterations 

% Partition Distance
for i=1:nGammas
    [VIn,MIn] = partition_distance(apriori_coms, Consensus_partition(:,i));
    partition_distance_groupMods(i,1) = VIn;
    partition_distance_groupMods(i,2) = MIn;
end
clear VIn MIn
%figure('Color','white'); plot(partition_distance_groupMods); legend;

% Save results & parameters
writematrix(Consensus_partition,'Group_Consensus_partition_byGamma_2.xlsx')
save('group_consensus_results.mat','partition_distance_groupMods', 'Consensus_partition', 'number_of_modules', 'modularity_group_average', 'Q_Group', 'M_Group', 'iters','cutoff', 'gammas');



%% Individual Modules

modularity_individual_average = zeros(numSubs,nGammas);
clear U Consensus_partition_ind number_of_modules_ind K agreement_value_thresholded agreement_value_proportion agreement_value_thresholded U Q_temp_OA M_temp_OA M Q
for g=1:nGammas
    for s=1:numSubs
        for i=1:iters % iters % Runs this 150 plus times
            [M, Q] = community_louvain(master_connectome(:,:,s),gammas(g));
            Q_temp_OA(s,i,g) = Q; M_temp_OA(:,i) = M;
            clear M Q
        end
        K = agreement(M_temp_OA);
        agreement_value_thresholded(:,:)=[K]./iters;
        agreement_value_thresholded(agreement_value_thresholded < cutoff) = 0;
        
        %% Consensus partition for average
        disp(i)
        U = consensus_und(agreement_value_thresholded,cutoff,iters);
        Consensus_partition_ind(:,s,g) =[U];
        
        %% Maximum number of modules
        number_of_modules_ind(s,g,:) = max(Consensus_partition_ind(:,s,g));
        
        clear K agreement_value_thresholded agreement_value_proportion agreement_value_thresholded U M_temp_OA
    end
end

% Average Q & Number of Mods
averageQ_indMods = squeeze(mean(Q_temp_OA(:,:,:),2));   %figure; imagesc(averageQ_indMods); colormap jet(30);
number_of_modules_indMods = number_of_modules_ind';     %figure; imagesc(number_of_modules_ind); colormap jet(30);

% Partition Distance
partition_distance_indMods = zeros(numSubs,nGammas*2);
for s=1:numSubs
    for g=1:nGammas
        [VIn,MIn] = partition_distance(Consensus_partition(:,g), Consensus_partition_ind(:,s,g));
        partition_distance_indMods(s,g) = VIn;
        partition_distance_indMods(s,nGammas+g) = MIn;
    end
end
clear VIn MIn

% figure;
% subplot(1,2,1); boxplot(squeeze(partition_distance_indMods(:,1,:))); ylim([0 .8]); title('VIN : INDIVIDUAL CONSENSUS MODULES');
% subplot(1,2,2); boxplot(squeeze(partition_distance_indMods(:,2,:))); ylim([0 .8]); title('MIN : INDIVIDUAL CONSENSUS MODULES');

% Save results & parameters
xlswrite('individual_modules_by_gamma.xlsx',Consensus_partition_ind,'gamma','A1',3); % write to excell
save('individual_consensus_results.mat',...
    'partition_distance_indMods',...
    'Consensus_partition_ind', 'number_of_modules_ind','number_of_modules_indMods', 'modularity_individual_average', 'Q_ind',...
    'M_ind', 'iters','cutoff', 'gammas');


