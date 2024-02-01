function mdl = specifyModelLV(varyParamsFlag)

% Functions defining LV model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParLV;
mdl.solveModel = @solveModelLV;
mdl.transformSolution = @transformSolutionMultiply;

% Labels for plotting model solution
mdl.xLbl = 'time';
mdl.yLbl = 'observed population count';

% Specify true values of parameters to be fitted
mdl.parLbl = ["r", "a", "mu", "p_{obs}"];
mdl.ThetaTrue = [1; 1.5; 1; 0.1];
if varyParamsFlag == 1      % add some (Gaussian) noise to parameter values
    mdl.ThetaTrue = mdl.ThetaTrue + [0.2; 0.2; 0.2; 0.02].*randn(4, 1);
end

% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 4;
mdl.runningValues = 1;      % always run forward model with pObs = 1 under the improved method        

% Initial guess for fitted parameters 
mdl.Theta0 = [0.95; 1.45; 0.9; 0.11];

% Define lower and upper bounds on fitted parameters
mdl.lb = [1e-3; 1e-3; 1e-3; 1e-4];
mdl.ub = [10; 10; 5; 1];
mdl.ThetaTrue = max(mdl.lb, min(mdl.ub, mdl.ThetaTrue) );       % force true parameter values to be within specified bounds

% Profile intervals for each parameter
mdl.profileRange = 0.2;
% mdl.ThetaLower = [0.8; 1.3; 0.9; 0.08];
% mdl.ThetaUpper = [1.2; 1.7; 1.1; 0.12];

mdl.gridSearchFlag = 1;     % set to 1 to do a preliminary grid search of the optimised parameter if the default starting value returns Nan

% Set fmincon options if required:
mdl.options = optimoptions('fmincon');


