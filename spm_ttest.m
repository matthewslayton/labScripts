% List of open inputs
% Factorial design specification: Scans - cfg_files
nrun = 1; % enter the number of runs here
jobfile = {'/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/spm_ttest_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Factorial design specification: Scans - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
