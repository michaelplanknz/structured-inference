function mdl = specifyModelRAD_PDE(varyParamsFlag)

% Functions defining RAD_PDE model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParRAD_PDE;
mdl.solveModel = @solveModelRAD_PDE;
mdl.transformSolution = @transformSolution_OgataBanks;

% Labels for plotting model solution
mdl.xLbl = 'x';
mdl.yLbl = 's(x)';     

% Specify true values of parameters to be fitted
mdl.parLbl = ["D", "v", "R", "\sigma"];
mdl.ThetaTrue = [1; 0.5; 2; 3];
if varyParamsFlag == 1        % add some (Gaussian) noise to parameter values
    mdl.ThetaTrue = mdl.ThetaTrue + [0.2; 0.1; 0.4; 0.5].*randn(4, 1);
end

% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 3;
mdl.runningValues = 1;      % always run forward model with R = 1 under the improved method

% Initial guess for fitted parameters 
mdl.Theta0 = [1.1; 0.4; 1.8; 4];

       
% Define lower and upper bounds on fitted parameters
mdl.lb = [1e-3; -50; 1; 1e-3];
mdl.ub = [100; 50; 100; 30];
mdl.ThetaTrue = max(mdl.lb, min(mdl.ub, mdl.ThetaTrue) );       % force true parameter values to be within specified bounds

% Profile intervals for each parameter
mdl.profileRange = 0.2;
% mdl.ThetaLower = [0.8; 0.4; 1.6; 2];
% mdl.ThetaUpper = [1.2; 0.6; 2.4; 4];

mdl.gridSearchFlag = 1;     % set to 1 to do a preliminary grid search of the optimised parameter if the default starting value returns Nan

% Set fmincon options if required:
mdl.options = optimoptions(@fmincon, 'Display', 'off', 'Algorithm', 'sqp');

