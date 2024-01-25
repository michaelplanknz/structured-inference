function mdl = specifyModelRAD_PDE()

% Functions defining RAD_PDE model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParRAD_PDE;
mdl.solveModel = @solveModelRAD_PDE;
mdl.transformSolution = @transformSolution_OgataBanks;

% Labels for plotting model solution
mdl.xLbl = 'x';
mdl.yLbl = 's(x)';     

% Set this flag to 1 to fit model to synthetic data generated from a simulation of the model, or 0 to fit model to user-supplied data in the CSV file called mdl.dataFName in the data/ directory
mdl.useSynthDataFlag = 1;
mdl.dataFName = "";

% Specify true values of parameters to be fitted
mdl.parLbl = ["D", "v", "R", "\sigma"];
mdl.ThetaTrue = [1; 0.5; 2; 3];

% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 3;
mdl.runningValues = 1;      % always run forward model with R = 1 under the improved method

% Initial guess for fitted parameters 
mdl.Theta0 = [1.1; 0.4; 1.8; 4];

       
% Define lower and upper bounds on fitted parameters
mdl.lb = [1e-3; -50; 1; 1e-3];
mdl.ub = [100; 50; 100; 30];

% Profile intervals for each parameter
mdl.profileRange = 0.2;
% mdl.ThetaLower = [0.8; 0.4; 1.6; 2];
% mdl.ThetaUpper = [1.2; 0.6; 2.4; 4];

mdl.gridSearchFlag = 1;     % set to 1 to do a preliminary grid search of the optimised parameter if the default starting value returns Nan

% Set fmincon options if required:
mdl.options = optimoptions('fmincon');

% Maximum time for the local search optimiser (can be Inf to run without limit)
%mdl.GSMaxTime = inf;

