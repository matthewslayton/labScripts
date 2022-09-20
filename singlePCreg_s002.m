% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/Users/matthewslayton/Documents/GitHub/STAMP/singlePCreg_s002_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
