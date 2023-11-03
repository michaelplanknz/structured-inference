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
        solveModel = @solveModelSEIR;
        transformSolution = @transformSolutionMultiply;
        
        % Labels for plotting model solution
        xLbl = 'time (days)';
        yLbl = 'new daily cases';        
        
        % Specify true values of parameters to be fitted
        parLbl = ["R0", "tR", "pObs", "obsSD"];
        ThetaTrue = [1.3; 300; 0.01; 0.2];

        % Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
        parsToOptimise = 3;
        runningValues = 1;      % always run forward model with pObs = 1 under the improved method

        % Initial guess for fitted parameters [R0, tR, pObs, obsSD]
        Theta0 = [1.5; 400; 0.1; 0.4];
               
        % Define lower and upper bounds on fitted parameters
        lb = [0; 0; 0; 0];
        ub = [20; 2000; 1; 2];
        
        % Profile intervals for each parameter
        ThetaLower = [1.2; 250; 0.005; 0.15];
        ThetaUpper = [1.4; 350; 0.015; 0.4];
    
    elseif modelLbl(iModel) == "LV"
        % Functions defining LV model and parameter ranges and initial conditions for MLE
        getPar = @getParLV;
        solveModel = @solveModelLV;
        transformSolution = @transformSolutionMultiply;

       % Labels for plotting model solution
        xLbl = 'time';
        yLbl = 'observed population count';

        % Specify true values of parameters to be fitted
        parLbl = ["r", "a", "pObs"];%, "obsSD"];
        ThetaTrue = [1; 1.5; 0.1];%; par.obsSD];

        % Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
        parsToOptimise = 3;
        runningValues = 1;      % always run forward model with pObs = 1 under the improved method        

        % Initial guess for fitted parameters [r, a, pObs]
        Theta0 = [0.95; 1.45; 0.11];%; 4];
        
        % Define lower and upper bounds on fitted parameters
        lb = [0; 0; 0];%; 0];
        ub = [10; 10; 1];%; 20];
        
        % Profile intervals for each parameter
        ThetaLower = [0.8; 1.3; 0.08];%; 1];
        ThetaUpper = [1.2; 1.7; 0.12];%; 4];
    end
    



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate data from forward model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    par = getPar(ThetaTrue);
    sol = solveModel(par);
    obs = genObs(sol.eObs, par);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find MLE and profile each parameter using basic method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % MLE
    fprintf('Model %s:   Basic method MLE...  ', modelLbl(iModel))
    [ThetaMLE, parMLE, solMLE, countMLE] = doMLE(getPar, solveModel, obs, Theta0, lb, ub, options);
    
    % Profiling
    fprintf('profiling...   ')
    [logLik, countProfile] = doProfiling(getPar, solveModel, obs, ThetaMLE, Theta0, lb, ub, ThetaLower, ThetaUpper, nMesh, options);
    
    % Plotting
    plotGraphs(sol, solMLE, obs, logLik, ThetaMLE, ThetaTrue, ThetaLower, ThetaUpper, nMesh, countMLE, countProfile, xLbl, yLbl, parLbl, "basic_"+modelLbl(iModel), savFolder, 2*iModel-1);
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find MLE and profile each (non-optimised) parameter with structured inference method
    % NB variables with 'Improved" suffix relate to output from the structured inference method as opposed to the basic method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    
    
    % MLE
    fprintf('Structured method MLE... ')
    [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getPar, solveModel, transformSolution, obs, Theta0, lb, ub, parsToOptimise, runningValues, options);
    
    % Profiling    
    fprintf('profiling...   ')
    [logLikImproved, countProfileImproved] = doProfilingImproved(getPar, solveModel, transformSolution, obs, ThetaMLEImproved, Theta0, lb, ub, ThetaLower, ThetaUpper, parsToOptimise, runningValues, nMesh, options);
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
