function mdl = specifyModelRAD_PDE()

% Functions defining RAD_PDE model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParRAD_PDE;
mdl.solveModel = @solveModelRAD_PDE;
mdl.transformSolution = @transformSolution_OgataBanks;

% Labels for plotting model solution
mdl.xLbl = 'x';
mdl.yLbl = 's(x)';        

% Specify true values of parameters to be fitted
mdl.parLbl = ["D", "V", "R", "obsSD"];
mdl.ThetaTrue = [1; 0.5; 2; 5];

% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 3;
mdl.runningValues = 1;      % always run forward model with R = 1 under the improved method

% Initial guess for fitted parameters [R0, tR, pObs, obsSD]
mdl.Theta0 = [1.1; 0.4; 1.8; 4];

       
% Define lower and upper bounds on fitted parameters
mdl.lb = [0; -50; 1; 0];
mdl.ub = [100; 50; 100; 50];

% Profile intervals for each parameter
mdl.ThetaLower = [0.8; 0.4; 1.6; 4];
mdl.ThetaUpper = [1.2; 0.6; 2.4; 6];

