clear 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Folder with Matlab functions
addpath('functions', 'models');

% Folder and filename for saving results and plots 
savFolder = "results/";
fNameOut = "results_userdata";

% Filename containing user-supplied data
dataFName = "data/SEIR_data.csv";

% Global numerical settings
nMesh = 41;            % number of points in parameter mesh for profiles
Alpha = 0.05;   % significance level for calculating CIs

% User-supplied model specification file (see README)
mdl = specifyModelSEIR(0);

% Read in user-supplied data
obs = readmatrix(dataFName);
       
% Threshold value on normalised log likelihood for (1-Alpha)% confidence intervals 
thresholdValue = -0.5*chi2inv(1-Alpha, 1);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE and profile each parameter using basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MLE
[ThetaMLE, parMLE, solMLE, LLMLE, countMLE] = doMLE(mdl, obs);

% Profiling
[ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, LLMLE, nMesh);
logLikNorm = logLik - LLMLE;

% Find CIs
CIs = findCIs(ThetaProfile, logLikNorm, thresholdValue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE and profile each (non-optimised) parameter with structured inference method
% NB variables with 'Structured" suffix relate to output from the structured inference method as opposed to the basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% MLE
[ThetaMLEStructured, parMLEStructured, solMLEStructured, LLMLEStructured, countMLEStructured] = doMLEStructured(mdl, obs);

% Profiling    
[ThetaProfileStructured, logLikStructured, countProfileStructured] = doProfilingStructured(mdl, obs, ThetaMLEStructured, LLMLEStructured, nMesh);
logLikStructuredNorm = logLikStructured - LLMLEStructured;

% Find CIs
CIsStructured = findCIs(ThetaProfileStructured, logLikNormStructured, thresholdValue);

% Store results in a structure
results.obs = obs;
results.solMLE = solMLE;
results.LLMLE = LLMLE;
results.ThetaMLE = ThetaMLE;
results.ThetaProfile = ThetaProfile;
results.logLik = logLik;
results.logLikNorm = logLikNorm;
results.CIs = CIs;

results.solMLEStructured = solMLEStructured;
results.LLMLEStructured = LLMLEStructured;
results.ThetaMLEStructured = ThetaMLEStructured;
results.ThetaProfileStructured = ThetaProfileStructured;
results.logLikStructured = logLikStructured;
results.logLikStructuredNorm = logLikStructuredNorm;
results.CIsStructured = CIsStructured;

%%

% Plotting (for a single realisation) for each model
parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);
plotGraphs(results, parsToProfile, thresholdValue, mdl, "userdata", savFolder, 1);

% Save results
save(savFolder+fNameOut+".mat");



