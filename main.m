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

% Define lower and upper bounds on fitted parameters
lb = [0; 0; 0; 0];
ub = [20; 2000; 1; 2];

% Profile intervals for each parameter
ThetaLower = [1.2; 250; 0.005; 0.15];
ThetaUpper = [1.4; 350; 0.015; 0.4];




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

[ThetaMLE, parMLE, solMLE, countMLE] = doMLE(getTrialPar, solveModel, obs, par, Theta0, lb, ub, options);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Profile each parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[logLik, countProfile] = doProfiling(getTrialPar, solveModel, obs, par, ThetaMLE, Theta0, lb, ub, ThetaLower, ThetaUpper, nMesh, options);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting results of basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = figure(1);
plot(sol.t, sol.eObs, solMLE.t, solMLE.eObs , sol.t, obs, '.' )
legend('actual', 'MLE', 'data')
xlabel('time (days)')
ylabel('new daily observations')
ylim([0 inf])
title(sprintf('MLE %i evaluations', countMLE))
drawnow
saveas(gcf, savFolder+"mle_"+savLbl, 'png');


h = figure(2);
h.Position = [   560         239        1012         709];
nPars = length(Theta0);      % number of parameters to profile
for iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower(iPar), ThetaUpper(iPar), nMesh);
    subplot(2, 2, iPar)
    plot(ThetaMesh, logLik(iPar, :))
    xline(ThetaMLE(iPar), 'r--');
    xline(ThetaTrue(iPar), 'k--');
    legend('profile likelihood', 'MLE', 'actual')
    xlabel(parLbl(iPar))
    ylabel('log likelihood')
    title(sprintf('Profile %i evaluations', countProfile(iPar)))
    drawnow
end
saveas(gcf, savFolder+"profiles_"+savLbl, 'png');






%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE with structured inference method
% NB variables with 'Improved" suffix relate to output from the structured inference method as opposed to the basic method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Indices  of parameters in parLbl to optimise without re-evaluating forward model
parsToOptimise = 3;


% Call improved MLE function
[ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getTrialPar, getTrialParImproved, solveModel, transformSolution, obs, par, Theta0, lb, ub, parsToOptimise, options);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Profiling with structured inference method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[logLikImproved, countProfileImproved] = doProfilingImproved(getTrialParImproved, solveModel, transformSolution, obs, par, ThetaMLEImproved, Theta0, lb, ub, ThetaLower, ThetaUpper, parsToOptimise, nMesh, options);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting results of structued inference method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = figure(3);
plot(sol.t, sol.eObs, solMLEImproved.t, solMLEImproved.eObs, sol.t, obs, '.' )
legend('actual', 'MLE', 'data')
xlabel('time (days)')
ylabel('new daily observations')
ylim([0 inf])
title(sprintf('MLE %i evaluations', countMLEImproved))
drawnow
saveas(gcf, savFolder+"mle_structured_"+savLbl, 'png');


h = figure(4);
h.Position = [   560         239        1012         709];
parsToProfile = setdiff(1:length(Theta0), parsToOptimise);
nPars = length(parsToProfile);      % number of parameters to profile
for iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower(parsToProfile(iPar)), ThetaUpper(parsToProfile(iPar)), nMesh);
    subplot(2, 2, iPar)
    plot(ThetaMesh, logLikImproved(iPar, :))
    xline(ThetaMLEImproved(parsToProfile(iPar)), 'r--');
    xline(ThetaTrue(parsToProfile(iPar)), 'k--');
    legend('profile likelihood', 'MLE', 'actual')
    xlabel(parLbl(parsToProfile(iPar)))
    ylabel('log likelihood')
    title(sprintf('Profile %i evaluations', countProfileImproved(iPar)))
    drawnow
end
saveas(gcf, savFolder+"profiles_structured_"+savLbl, 'png');

