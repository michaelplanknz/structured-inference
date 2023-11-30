function mdl = specifyModelLV()

% Functions defining LV model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParLV;
mdl.solveModel = @solveModelLV;
mdl.transformSolution = @transformSolutionMultiply;

% Labels for plotting model solution
mdl.xLbl = 'time';
mdl.yLbl = 'observed population count';

% Specify true values of parameters to be fitted
mdl.parLbl = ["r", "a", "mu", "pObs"];
mdl.ThetaTrue = [1; 1.5; 1; 0.1];

% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 4;
mdl.runningValues = 1;      % always run forward model with pObs = 1 under the improved method        

% Initial guess for fitted parameters [r, a, pObs]
mdl.Theta0 = [0.95; 1.45; 0.9; 0.11];

% Define lower and upper bounds on fitted parameters
mdl.lb = [0; 0; 0; 0];
mdl.ub = [10; 10; 5; 1];

% Profile intervals for each parameter
mdl.ThetaLower = [0.8; 1.3; 0.9; 0.08];
mdl.ThetaUpper = [1.2; 1.7; 1.1; 0.12];
