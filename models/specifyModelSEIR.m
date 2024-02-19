function mdl = specifyModelSEIR(varyParamsFlag)

parameterCV = 0.1;      % CV in distribution of randomised parameters (when randomisation option is selected)
ICCV = 0.05;            % CV in distribution of ICs for fmincon about the true value (when randomisation option is selected)

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

% Initial guess for fitted parameters 
mdl.Theta0 = [1.25; 0.003; 0.12; 35];


if varyParamsFlag == 1      % add some (Gaussian) noise to parameter values
    mdl.ThetaTrue = mdl.ThetaTrue .* (1 + parameterCV*randn(4, 1)); 
  %  mdl.Theta0 = mdl.ThetaTrue .* (1 + ICCV*randn(4, 1));
end


% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 3;
mdl.runningValues = 1;      % always run forward model with pObs = 1 under the improved method


       
% Define lower and upper bounds on fitted parameters
mdl.lb = [1e-3; 1e-4; 1e-4; 1e-2];
mdl.ub = [10; 1/10; 1; 100];
mdl.ThetaTrue = max(mdl.lb, min(mdl.ub, mdl.ThetaTrue) );       % force true parameter values to be within specified bounds

% Profile intervals for each parameter - profile range will be from
% (1-x)*MLE to (1+x)*MLE
%mdl.profileRange = [0.005, 0.02, 0.04, 0.2];
mdl.profileRange = [0.0025, 0.005, 0.02, 0.2];

mdl.gridSearchFlag = 1;     % set to 1 to do a preliminary grid search of the optimised parameter if the default starting value returns Nan

% Set fmincon options (for outer problem) if required:
mdl.options = optimoptions(@fmincon, 'Display', 'off');
%mdl.options = optimoptions(@fmincon, 'Display', 'off', 'Algorithm', 'sqp');

% Set GSFlag to 1 to do a global search for the MLE, or 0 to do a local
% search (fmincon only):
mdl.GSFlag = (varyParamsFlag == 1);                             % set GS option only if do a parameter variation run     
mdl.gs = GlobalSearch(Display = "off", MaxTime = 1000);     % set GS options (if required)

