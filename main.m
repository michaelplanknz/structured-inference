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

modelLbl = ["SEIR", "LV", "RAD_PDE"]';        % labels for models - can include "SEIR", "LV", "RAD_PDE"
%modelLbl = ["RAD_PDE"]';        % labels for models - can include "SEIR", "LV", "RAD_PDE"

options = optimoptions('fmincon', 'Display', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





nModels = length(modelLbl);

totCallsBasic = zeros(nModels, 1);
totCallsImproved = zeros(nModels, 1);
relErrBasic = zeros(nModels, 1);
relErrImproved = zeros(nModels, 1);


for iModel = 1:nModels
    
    % Specify model-specific functions and values here:
    if modelLbl(iModel) == "SEIR"
        mdl = specifyModelSEIR();
    elseif modelLbl(iModel) == "LV"
        mdl = specifyModelLV();
    elseif modelLbl(iModel) == "RAD_PDE"
        mdl = specifyModelRAD_PDE();
    end
    



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate data from forward model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    par = mdl.getPar(mdl.ThetaTrue);
    sol = mdl.solveModel(par);
    obs = genObs(sol.eObs, par);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find MLE and profile each parameter using basic method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % MLE
    fprintf('Model %s:   Basic method MLE...  ', modelLbl(iModel))
    [ThetaMLE, parMLE, solMLE, countMLE] = doMLE(mdl, obs, options);
    
    % Profiling
    fprintf('profiling...   ')
    [logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, nMesh, options);
    
    % Plotting
    parsToProfile = 1:length(mdl.Theta0);
    plotGraphs(sol, solMLE, obs, logLik, ThetaMLE, parsToProfile, nMesh, countMLE, countProfile, mdl, "basic_"+modelLbl(iModel), savFolder, 2*iModel-1);
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find MLE and profile each (non-optimised) parameter with structured inference method
    % NB variables with 'Improved" suffix relate to output from the structured inference method as opposed to the basic method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    
    
    % MLE
    fprintf('Structured method MLE... ')
    [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(mdl, obs, options);
    
    % Profiling    
    fprintf('profiling...   ')
    [logLikImproved, countProfileImproved] = doProfilingImproved(mdl, obs, ThetaMLEImproved, nMesh, options);
    fprintf('done\n')
    
    % Plotting
    parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);
    plotGraphs(sol, solMLEImproved, obs, logLikImproved, ThetaMLEImproved, parsToProfile, nMesh, countMLEImproved, countProfileImproved, mdl, "structured_"+modelLbl(iModel), savFolder, 2*iModel);
    

    % Record some summary statistics for this model
    totCallsBasic(iModel) = countMLE + sum(countProfile);
    totCallsImproved(iModel) = countMLEImproved + sum(countProfileImproved);
    relErrBasic(iModel) = norm(ThetaMLE-mdl.ThetaTrue)/norm(mdl.ThetaTrue);
    relErrImproved(iModel) = norm(ThetaMLEImproved-mdl.ThetaTrue)/norm(mdl.ThetaTrue);
    
end

fprintf('Model %i.  Calls: basic %i, improved %i.  Relative error: basic %.3e, improved, %.3d\n', [1:nModels; totCallsBasic'; totCallsImproved'; relErrBasic'; relErrImproved'])

outTab = table(modelLbl, relErrBasic, relErrImproved, totCallsBasic, totCallsImproved);
writetable(outTab, 'results/results.csv');




