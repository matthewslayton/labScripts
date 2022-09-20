% List of open inputs
% Factorial design specification: Vector - cfg_entry
% Factorial design specification: Name - cfg_entry
% Factorial design specification: Vector - cfg_entry
% Factorial design specification: Name - cfg_entry
nrun = 1; % enter the number of runs here
jobfile = {'/Users/matthewslayton/Documents/GitHub/STAMP/cortney_test_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);
for crun = 1:nrun
    
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
