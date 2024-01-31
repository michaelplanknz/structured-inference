clear 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Folder with Matlab functions
addpath('functions');

% Folder and filename for saving results and plots 
savFolder = "results/";
fNameOut = "results_userdata.mat";

% Filename containing user-supplied data
dataFName = "data/SEIR_data.csv";

% User-supplied model specification file (see README)
mdl = specifyModelSEIR();

% Global numerical settings
nMesh = 21;            % number of points in parameter mesh for profiles
mdl.options.Display = 'off';


% Read in user-supplied data
obs = readmatrix(dataFName);
        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE and profile each parameter using basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MLE

[ThetaMLE, parMLE, solMLE, countMLE] = doMLE(mdl, obs);

% Profiling
[ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, nMesh);

   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE and profile each (non-optimised) parameter with structured inference method
% NB variables with 'Improved" suffix relate to output from the structured inference method as opposed to the basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% MLE
[ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(mdl, obs);

% Profiling    
[ThetaProfileImproved, logLikImproved, countProfileImproved] = doProfilingImproved(mdl, obs, ThetaMLEImproved, nMesh);

% Store results in a structure
results.obs = obs;
results.solMLE = solMLE;
results.ThetaMLE = ThetaMLE;
results.ThetaProfile = ThetaProfile;
results.logLik = logLik;
results.solMLEImproved = solMLEImproved;
results.ThetaMLEImproved = ThetaMLEImproved;
results.ThetaProfileImproved = ThetaProfileImproved;
results.logLikImproved = logLikImproved;

%%

% Plotting (for a single realisation) for each model
parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);
plotGraphs(results, parsToProfile, mdl, "userdata", savFolder, 1);

% Save results
save(savFolder+fNameOut);



