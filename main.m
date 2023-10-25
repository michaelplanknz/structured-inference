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
[sol, Yt] = solveModel(par);
obs = genObs(Yt, par);

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
plot(sol.t, (1/par.tObs)*sol.C1, solMLE.t, (1/parMLE.tObs)*solMLE.C1 , sol.t, obs, '.' )
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







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find MLE with structured inference method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Indices  of parameters in parLbl to optimise without re-evaluating forward model
parsToOptimise = 3;
% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(parLbl), parsToOptimise);

% Create contracted vectors containing only the information for the parameters to be profiled
lb_contracted = lb(parsToProfile);
ub_contracted = ub(parsToProfile);
ThetaTrue_contracted = ThetaTrue(parsToProfile);
parLbl_contracted = parLbl(parsToProfile);
Theta0_contracted = Theta0(parsToProfile);
ThetaLower_contracted = ThetaLower(parsToProfile);
ThetaUpper_contracted = ThetaUpper(parsToProfile);


[ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getTrialPar, getTrialParImproved, solveModel, obs, par, Theta0_contracted, lb_contracted, ub_contracted, parsToOptimise, options);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Profiling with structured inference method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[logLikImproved, countProfileImproved] = doProfilingImproved(getTrialParImproved, solveModel, obs, par, ThetaMLEImproved, Theta0_contracted, lb_contracted, ub_contracted, ThetaLower_contracted, ThetaUpper_contracted, nMesh, options);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting results of structued inference method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = figure(3);
plot(sol.t, (1/par.tObs)*sol.C1, solMLEImproved.t, (1/parMLEImproved.tObs)*solMLEImproved.C1 , sol.t, obs, '.' )
legend('actual', 'MLE', 'data')
xlabel('time (days)')
ylabel('new daily observations')
ylim([0 inf])
title(sprintf('MLE %i evaluations', countMLEImproved))
drawnow
saveas(gcf, savFolder+"mle_structured_"+savLbl, 'png');


h = figure(4);
h.Position = [   560         239        1012         709];
nPars = length(Theta0_contracted);      % number of parameters to profile
for iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower_contracted(iPar), ThetaUpper_contracted(iPar), nMesh);
    subplot(2, 2, iPar)
    plot(ThetaMesh, logLikImproved(iPar, :))
    xline(ThetaMLEImproved(iPar), 'r--');
    xline(ThetaTrue_contracted(iPar), 'k--');
    legend('profile likelihood', 'MLE', 'actual')
    xlabel(parLbl_contracted(iPar))
    ylabel('log likelihood')
    title(sprintf('Profile %i evaluations', countProfileImproved(iPar)))
    drawnow
end
saveas(gcf, savFolder+"profiles_structured_"+savLbl, 'png');

