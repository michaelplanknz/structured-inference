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

modelLbl = ["SEIR", "LV"];        % labels for models

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
        % Functions defining SEIR model and parameter ranges and initial conditions for MLE
        getPar = @getParSEIR;
        getTrialPar = @getTrialParSEIR;
        getTrialParImproved = @getTrialParImprovedSEIR;
        solveModel = @solveModelSEIR;
        transformSolution = @transformSolutionMultiply;
        
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
    
    elseif modelLbl(iModel) == "LV"
        % Functions defining LV model and parameter ranges and initial conditions for MLE
        getPar = @getParLV;
        getTrialPar = @getTrialParLV;
        getTrialParImproved = @getTrialParImprovedLV;
        solveModel = @solveModelLV;
        transformSolution = @transformSolutionMultiply;
        
        % Initial guess for fitted parameters [a, b, pObs, obsSD]
        parLbl = ["r", "a", "pObs", "obsSD"];
        Theta0 = [0.95; 1.45; 0.11; 0.004];
        
        xLbl = 'time';
        yLbl = 'observed population count';
        
        % Define lower and upper bounds on fitted parameters
        lb = [0; 0; 0; 0];
        ub = [10; 10; 1; 0.02];
        
        % Profile intervals for each parameter
        ThetaLower = [0.8; 1.3; 0.08; 0.001];
        ThetaUpper = [1.2; 1.7; 0.12; 0.004];

    end
    



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate data from forward model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    par = getPar();
    sol = solveModel(par);
    obs = genObs(sol.eObs, par);
    
    % Make a vector of target parameters for inference (this is model-specific)
    if modelLbl(iModel) == "SEIR"
        ThetaTrue = [par.R0; par.tR; par.pObs; par.obsSD];
    elseif modelLbl(iModel) == "LV"
        ThetaTrue = [par.r; par.a; par.pObs; par.obsSD];
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find MLE and profile each parameter using basic method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % MLE
    fprintf('Model %s:   Basic method MLE...  ', modelLbl(iModel))
    [ThetaMLE, parMLE, solMLE, countMLE] = doMLE(getTrialPar, solveModel, obs, par, Theta0, lb, ub, options);
    
    % Profiling
    fprintf('profiling...   ')
    [logLik, countProfile] = doProfiling(getTrialPar, solveModel, obs, par, ThetaMLE, Theta0, lb, ub, ThetaLower, ThetaUpper, nMesh, options);
    
    % Plotting
    plotGraphs(sol, solMLE, obs, logLik, ThetaMLE, ThetaTrue, ThetaLower, ThetaUpper, nMesh, countMLE, countProfile, xLbl, yLbl, parLbl, "basic_"+modelLbl(iModel), savFolder, 2*iModel-1);
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find MLE and profile each (non-optimised) parameter with structured inference method
    % NB variables with 'Improved" suffix relate to output from the structured inference method as opposed to the basic method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Indices  of parameters in parLbl to optimise without re-evaluating forward model
    parsToOptimise = 3;
    
    
    % MLE
    fprintf('Structured method MLE... ')
    [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getTrialPar, getTrialParImproved, solveModel, transformSolution, obs, par, Theta0, lb, ub, parsToOptimise, options);
    
    % Profiling    
    fprintf('profiling...   ')
    [logLikImproved, countProfileImproved] = doProfilingImproved(getTrialParImproved, solveModel, transformSolution, obs, par, ThetaMLEImproved, Theta0, lb, ub, ThetaLower, ThetaUpper, parsToOptimise, nMesh, options);
    fprintf('done\n')
    
    % Plotting
    parsToProfile = setdiff(1:length(Theta0), parsToOptimise);
    plotGraphs(sol, solMLEImproved, obs, logLikImproved, ThetaMLEImproved(parsToProfile), ThetaTrue(parsToProfile), ThetaLower(parsToProfile), ThetaUpper(parsToProfile), nMesh, countMLEImproved, countProfileImproved, xLbl, yLbl, parLbl(parsToProfile), "structured_"+modelLbl(iModel), savFolder, 2*iModel);
    

    % Record some summary statistics for this model
    totCallsBasic(iModel) = countMLE + sum(countProfile);
    totCallsImproved(iModel) = countMLEImproved + sum(countProfileImproved);
    relErrBasic(iModel) = norm(ThetaMLE-ThetaTrue)/norm(ThetaTrue);
    relErrImproved(iModel) = norm(ThetaMLEImproved-ThetaTrue)/norm(ThetaTrue);
    
end
