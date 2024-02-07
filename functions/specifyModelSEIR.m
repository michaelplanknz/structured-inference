function mdl = specifyModelSEIR(varyParamsFlag)

% Functions defining SEIR model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParSEIR;
mdl.solveModel = @solveModelSEIR;
mdl.transformSolution = @transformSolutionMultiply;

% Labels for plotting model solution
mdl.xLbl = 'time (days)';
mdl.yLbl = 'new daily cases';        

% Specify true values of parameters to be fitted
mdl.parLbl = ["R_0", "w", "p_{obs}", "k"];
mdl.ThetaTrue = [1.3; 1/300; 0.1; 30];
if varyParamsFlag == 1        % add some (Gaussian) noise to parameter values
    mdl.ThetaTrue = mdl.ThetaTrue + [0.2; 0.0005; 0.02; 6].*randn(4, 1);
end


% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 3;
mdl.runningValues = 1;      % always run forward model with pObs = 1 under the improved method

% Initial guess for fitted parameters 
mdl.Theta0 = [1.25; 0.003; 0.12; 35];

       
% Define lower and upper bounds on fitted parameters
mdl.lb = [1e-3; 1e-4; 1e-4; 1e-2];
mdl.ub = [10; 1/10; 1; 100];
mdl.ThetaTrue = max(mdl.lb, min(mdl.ub, mdl.ThetaTrue) );       % force true parameter values to be within specified bounds

% Profile intervals for each parameter
mdl.profileRange = 0.2;
% mdl.ThetaLower = [1.2; 1/250; 0.005; 20];
% mdl.ThetaUpper = [1.4; 1/350; 0.015; 40];

mdl.gridSearchFlag = 1;     % set to 1 to do a preliminary grid search of the optimised parameter if the default starting value returns Nan

% Set fmincon options if required:
mdl.options = optimoptions(@fmincon, 'Display', 'off');


