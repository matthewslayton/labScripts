function Master_Network_STAMP_fxn
%(condString, condDir)

% make sure to clear global when you run this 

% this gives the Rs, TMPs, and design (which gives the per-person trial
% info) which I'll need for multiple regression

%% add paths
%rootDir = '/Users/cortneyhoward/Documents/RSA_Rotation/';
rootDir = '/Users/matthewslayton/Documents/GitHub/STAMP/';
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/Scripts/spm12');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/function_files')

% code_dir{1}=fullfile([rootDir 'Scripts/']);
% % code_dir{1} = fullfile([rootDir, 'Geib/Scripts/Public/mfMRI_v2']);
% for ii=1:length(code_dir)
%     addpath(genpath(code_dir{ii}));
% end

%%

% Master_RSA.m mfMRI_v1
% Matlab 2015a 
% Winter 2016
% Karl (Searchlight) & BRG updates
%
% Description
%   Searchlight script. Performs searchlight style analysis of any
%   arbitrary function. The searchlight volume is a 'cube' by default.
%   Searchlight volumes can also be defined as ROIs e.g. multivariate
%   analyses can be run discretely. Finally, the script is designed to
%   function with Master_Network_Maker.m. It does so by saving beta-series
%   with respect to an ROI. 
%
% clear existing variables
% clc; clear all;

% declare SL
global SL;
    
% Update log
% 3/28/2016  -> added comments and fixed custom models
% 6/23/2017  -> code for distance computations and SVM classifier
%            * still needs better documentation
% 10/26/2017 -> added code for multiple RDMs
%            * QA doesn't work with this yet             

%rootDir = '/Users/cortneyhoward/Documents/RSA_Rotation/';
%wrk_dir=[rootDir, '/New_Stamp_Single_Trial/'];
wrk_dir = [rootDir '/Encoding_renamed/'];
%wrk_dir='/Stivers/projects/STAMP/';
%=========================================================================%
%% SL.dir
%=========================================================================%
% Variables:
%   .stpath (string)     => Location of single trials to use
%   .subjects (cell)     => Each element is a subject ID (folder)
%   .outpath (string)    => Where to save the analysis
%   .overwrite (logical) => Determines if files should be overwritten, if
%                           is set to 0, will skip over any existing
%                           output (still testing...)
%   .QA (string)         => Quality assurance directory

% where to grab data
%SL.dir.stpath = fullfile(wrk_dir,'/Analysis/Retrieval/');
SL.dir.stpath = fullfile(wrk_dir); %,'/betas/'); %don't need smoothed betas for this analysis

% subject directory names
SL.dir.subjects={'S002' 'S005' 'S006' 'S008' 'S009' 'S010' 'S011' 'S013'  'S014' 'S015' 'S016' 'S018' 'S019' 'S021' 'S022' 'S023' 'S024'  'S025' 'S026'};

SL.dir.QA='QA'; 
SL.dir.QAcheck=0;

%*Expected directory of 1st SPM.mat file is...
%  SPM=fullfile(SL.dir.stpath,SL.dir.subjects{1},'SPM.mat');
%=========================================================================%
%% SL.design & SL.ID & SL.run
%=========================================================================%
% Varaibles
%   .mumford (binary)       => if ==1 indicates that a mumford style
%                              analysis was run. Meaning that beta_xxxx.img
%                              files do not exist and that file names must
%                              be processed as opposed to SPM.mat files
%   .mumford_dir (string)   => subject sub-directory indicating where the
%                              brain volumes have been saved
%   .mumford_str (string)   => wildcard string indicating the file type of
%                              the saved volumes
SL.design.mumford=1; % = true
SL.design.mumford_dir='betas';
SL.design.mumford_str='nii';
%*Expected directory of volumes if mumford==1
% Files=fullfile(SL.dir.stpath,SL.dir.subjects{1},SL.design.mumford_dir,...
%  ['*' SL.design.mumford_str]);
% There is direct link between the file description in the SPM.mat file and
% the beta volumes. When Mumford is turned on, it skips the SPM.mat
% reference and directly analyzes the file names
%
% Variables
%   .SSL (num)              => Size of the searchlight (must be odd)
SL.design.SSL=5; % size of search light: 3x3x3 USE ODD NUMBERS
%   .cond_str (cell)        => Conditions to include in RDM
%       => 1* Order determines order of sorted matrix
%       => 2* Order determined by ID match, if exist (should)
%       => Requires nicely defined (descriptive) Vbeta fields, works by
%       performing an & conjunction on any strings within a cell within a
%       Vbeta.descrip string. If all strings found, then included in said
%       condition. Overlaps must never occur. A single '|' statement is
%       permitted

%SL.dir.outpath =  fullfile('/Users/cortneyhoward/Documents/RSA_Rotation/New_Stamp_Single_Trial/Ret_Rs_ROIs_for_LME');
SL.dir.outpath = fullfile('/Users/matthewslayton/Documents/GitHub/STAMP/Encoding_renamed/Enc_Rs_Combined_ROIs');
SL.dir.overwrite=1;

%ERS_conjRecomb
% Phase 1 - Encoding; Phase 2 - Retrieval
% %on function call, i.e. Master_Network_STAMP_fxn_CH({{'Phase2','cMEM1'},{'Phase2','cMEM3','|','cMEM4'})
% SL.design.cond_str = {...
%     condString{:}
%     };

SL.design.cond_str = {{'TT3'}}; %all valid trials};
    

%   .check (num)      => Determines if IDs should be checked, if this ==0
%                        then IDs are not checked MUST BE 1
%   .match (cell x2)  => Which strings to look between for the ID, the
%                        string being examined is in Vbeta
%   .overlap{x}(array)=> Determines number of overlaps to look for. An
%                        overlap array consists of zeros with a 1 and 2
%                        used to indicate which conditions (deterimined by
%                        SL.design.cond_str) should have aligned IDs 
%   .setcheck (array) => Determines which type of overlap to look for, one
%                        condition must exist for each overlap defined
%                           0 : 1 == 2
%                           1 : maximum overlap between 1 and 2
SL.ID.check=0;
% SL.ID.match={'ID' '_cMEM'}; 
% SL.ID.overlap{1}=[1 0 2 0]; % Overlap set1
% SL.ID.overlap{2}=[0 1 0 2]; % Overlap set2
% SL.ID.overlap{3}=[1 0 2 0]; % Overlap set3
% SL.ID.overlap{4}=[0 1 0 2]; % Overlap set4
% SL.ID.setcheck=[0 0 0 0];
% Variables
%   SL.run.include (bin)  => determines if within run items should be
%                            excluded from the analysis, if ==1, then this
%                            is so
%   SL.run.match {cell x2}=> Same as SL.ID.match, it determines the strings
%                            to look between in order to determine what run
%                            each beta belongs to
%   * in the below formulation, it suggests we should not include items
%   within runs, and that the run number is found in vbeta
%   '...Run1_Tri60...' e.g. run #1 in this case
SL.run.include=0;
SL.run.match={'Sess','_Run'};
%=========================================================================%
%% SL.region
%=========================================================================%
%   .use_mask (num)   => Determines if a mask should be used 
%   .mask (cell)      => Exact location of the mask to use - if MVPA is
%                        being done, then this must be set to a valid mask.
%                        As it is used in the initialization of the
%                        toolbox.
%   .noSL (num)       => If set ==1 then searchlight is turned OFF. This is
%                        true of MVPA or RSA analyses
%   .noModel (logical)=> ==0 if you want to run no models, this is
%                        typically true if you're just trying to save beta
%                        series or such
SL.region.use_mask=1;
SL.region.noSL=1;
SL.region.noModel=1;

%addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/');
addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/combined_masks/');

%mask_dir=fullfile(wrk_dir, 'Analysis/brainnetome/indiv_masks_resliced/');
%mask_dir=fullfile('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/');
mask_dir=fullfile('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/combined_masks/');
X=dir([mask_dir '*.nii']);
for ii=1:length(X)
    SL.region.mask{ii}=fullfile(mask_dir,X(ii).name);
end

%*Typically use_mask and no_SL are set equal. For example, while you could
% run a searchlight within a mask, this seems a bit odd
%=========================================================================%
%% SL
%=========================================================================%
%   .fisher (logical)       => controls fisher transformation correlation
%                              values, by defualt this is set ==0
%   .analysis.sd_trim (num) => number of standard deviations to windsorize
%                              the time series by
%=========================================================================%
%% SL.design
%=========================================================================%
%*Not needed for beta series analysis
%   .calc{#} (string)  => Multiple types of calculations are possible, the
%                         most common is 'Identity1'
%       Identity1 => examines the difference between identical items and
%                    mismatched items
%           .interactions{X}=[a b; c d]   => conditions to include the model in a row column format.
%           .save_str{#} (string)         => name of model for output
%           .custom(#) (logical)          => 0
%           .Identity1{#}.regress.on (logical)=> 0 (in testing atm)
%           .Identity1{#}.type (string)       => Identity1
%           .Identity1{#}.names (cell)        => Names of on/off diag
%           .Identity1{#}.diag=[a,b]          => defines the on diag cells
%           .Identity1{#}.row (logical)       => zscore rows (2=both,1=row,0=col)
%           .Identity1{#}.FourD (logical)     => save 4D output
%       Spear, Euclid, Mean or Kendall => for custom models only
%           .interactions{X}              => same as above
%           .save_str{#}                  => same as above
%           .custom(#)=1                  => says to include custom model
%       MRegression => for custom models only
%           .interactions{X}              => same as above
%           .save_str{#}                  => same as above
%           .custom(#)=1                  => says to include custom model
%           .ortho(#)=1                   => says to orthogonalize to first model    
%   .model{X} (file string)               => indicates data file to load
%       *loaded data file should be a .mat with 2 variables R &
%       stim_ID_num. R is a cross correlation matrix. stim_ID_num maps the
%       rows/columns of the matrix to SL.ID.match s.t. numbers pulled from
%       the Vbeta descriptions can match matrix R
%       *only needs set if this is an Spear, Euclid or Kendall analysis
%           design.interactions{X} => cells to compute average over
%           design.save_str{X}     => name of the output volume
%           custom(X)              => ==1 if design is a custom matrix
%       *if MRegression then this should be a cell list of models
%=========================================================================%
%% Examples of all three models
%=========================================================================%
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/mfMRI_v2-master/');
addpath('/Users/matthewslayton/Documents/Duke/Simon_Lab/mfMRI_v2-master/RSA');
RSA_shell_v2;
%=========================================================================%
%% Output Structure
%=========================================================================%
% ROI (beta-series) analysis
%  Data is saved to SL.dir.outpath. Each subject is given a single folder
%  in which the folder 'data' is present. The data folder will have one
%  file for each ROI. Files will named [SL.dir.QA '_' SL.region.mask{#}].
%  
%  Data files have three variables 'R', 'tmp' and 'design'
%   R      => cross-correlation matrix from the given region
%   tmp    => data matrix from ROI i.e. (voxel X beta)
%   design => Information on the general design structure
%
% QA directory (SL.dir.QA)
%  This folder will be located in SL.dir.outpath and named SL.dir.QA. A
%  single folder will exist for each model run. These folders will have
%  contrast maps for each condition. The folder will also have .csv files
%  detailing which beta files have been included in each condition.

clear global
end























