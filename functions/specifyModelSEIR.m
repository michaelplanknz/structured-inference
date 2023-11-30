function mdl = specifyModelSEIR();

% Functions defining SEIR model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParSEIR;
mdl.solveModel = @solveModelSEIR;
mdl.transformSolution = @transformSolutionMultiply;

% Labels for plotting model solution
mdl.xLbl = 'time (days)';
mdl.yLbl = 'new daily cases';        

% Specify true values of parameters to be fitted
mdl.parLbl = ["R0", "tR", "pObs", "obsSD"];
mdl.ThetaTrue = [1.3; 300; 0.01; 30];

% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 3;
mdl.runningValues = 1;      % always run forward model with pObs = 1 under the improved method

% Initial guess for fitted parameters [R0, tR, pObs, obsSD]
mdl.Theta0 = [1.5; 400; 0.1; 25];

       
% Define lower and upper bounds on fitted parameters
mdl.lb = [0; 0; 0; 0];
mdl.ub = [20; 2000; 1; 100];

% Profile intervals for each parameter
mdl.ThetaLower = [1.2; 250; 0.005; 25];
mdl.ThetaUpper = [1.4; 350; 0.015; 35];

