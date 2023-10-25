clear 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Folder with Matlab functions
addpath('functions');

% Folder for saving plots
savFolder = "figures/";

nMesh = 21;     % number of points in parameter mesh for profiles

options = optimoptions('fmincon', 'Display', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% Functions defining SEIR model and parameter ranges and initial conditions for MLE
getPar = @getParSEIR;
getTrialPar = @getTrialParSEIR;
getTrialParImproved = @getTrialParImprovedSEIR;
solveModel = @solveModelSEIR;
transformSolution = @transformSolutionSEIR;
savLbl = "SEIR";

% Initial guess for fitted parameters [R0, tR, pObs, obsSD]
parLbl = ["R0", "tR", "pObs", "obsSD"];
Theta0 = [1.5; 400; 0.1; 0.4];

xLbl = 'time (days)';
yLbl = 'new daily cases';

% Define lower and upper bounds on fitted parameters
lb = [0; 0; 0; 0];
ub = [20; 2000; 1; 2];

% Profile intervals for each parameter
ThetaLower = [1.2; 250; 0.005; 0.15];
ThetaUpper = [1.4; 350; 0.015; 0.4];

iModel = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate data from forward model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

par = getPar();
sol = solveModel(par);
obs = genObs(sol.eObs, par);

% Make a vector of target parameters for inference
ThetaTrue = [par.R0; par.tR; par.pObs; par.obsSD];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Model %s:   Basic method MLE...  ', savLbl)
[ThetaMLE, parMLE, solMLE, countMLE] = doMLE(getTrialPar, solveModel, obs, par, Theta0, lb, ub, options);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Profile each parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('profiling...   ')
[logLik, countProfile] = doProfiling(getTrialPar, solveModel, obs, par, ThetaMLE, Theta0, lb, ub, ThetaLower, ThetaUpper, nMesh, options);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting results of basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plotGraphs(sol, solMLE, obs, logLik, ThetaMLE, ThetaTrue, ThetaLower, ThetaUpper, nMesh, countMLE, countProfile, xLbl, yLbl, parLbl, "basic_"+savLbl, savFolder, 2*iModel-1);


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE with structured inference method
% NB variables with 'Improved" suffix relate to output from the structured inference method as opposed to the basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Indices  of parameters in parLbl to optimise without re-evaluating forward model
parsToOptimise = 3;


% Call improved MLE function
fprintf('Structured method MLE... ')
[ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getTrialPar, getTrialParImproved, solveModel, transformSolution, obs, par, Theta0, lb, ub, parsToOptimise, options);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Profiling with structured inference method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('profiling...   ')
[logLikImproved, countProfileImproved] = doProfilingImproved(getTrialParImproved, solveModel, transformSolution, obs, par, ThetaMLEImproved, Theta0, lb, ub, ThetaLower, ThetaUpper, parsToOptimise, nMesh, options);
fprintf('done\n')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting results of structued inference method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parsToProfile = setdiff(1:length(Theta0), parsToOptimise);
plotGraphs(sol, solMLEImproved, obs, logLikImproved, ThetaMLEImproved(parsToProfile), ThetaTrue(parsToProfile), ThetaLower(parsToProfile), ThetaUpper(parsToProfile), nMesh, countMLEImproved, countProfileImproved, xLbl, yLbl, parLbl(parsToProfile), "structured_"+savLbl, savFolder, 2*iModel);



