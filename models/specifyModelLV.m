function mdl = specifyModelLV(varyParamsFlag)

parameterCV = 0.1;      % CV in distribution of randomised parameters (when randomisation option is selected)
ICCV = 0.05;            % CV in distribution of ICs for fmincon about the true value (when randomisation option is selected)

% Functions defining LV model and parameter ranges and initial conditions for MLE
mdl.getPar = @getParLV;
mdl.solveModel = @solveModelLV;
mdl.transformSolution = @transformSolutionMultiply;

% Labels for plotting model solution
mdl.xLbl = 'time';
mdl.yLbl = 'observed population count';

% Specify true values of parameters to be fitted
mdl.parLbl = ["r", "a", "\mu", "p_{obs}"];
mdl.ThetaTrue = [0.5; 0.75; 0.5; 0.1];

% Initial guess for fitted parameters 
mdl.Theta0 = [0.95; 1.45; 0.9; 0.11];

if varyParamsFlag == 1      % add some (Gaussian) noise to parameter values
    mdl.ThetaTrue = mdl.ThetaTrue .* (1 + parameterCV*randn(4, 1)); 
   % mdl.Theta0 = mdl.ThetaTrue .* (1 + ICCV*randn(4, 1));
end

% Indices and values of parameters in parLbl to optimise without re-evaluating forward model in the improved method
mdl.parsToOptimise = 4;
mdl.runningValues = 1;      % always run forward model with pObs = 1 under the improved method        


% Define lower and upper bounds on fitted parameters
mdl.lb = [1e-3; 1e-3; 1e-3; 1e-4];
mdl.ub = [10; 10; 5; 1];
mdl.ThetaTrue = max(mdl.lb, min(mdl.ub, mdl.ThetaTrue) );       % force true parameter values to be within specified bounds

% Profile intervals for each parameter - profile range will be from
% (1-x)*MLE to (1+x)*MLE
%mdl.profileRange = [0.05, 0.05, 0.05, 0.05];
mdl.profileRange = [0.025, 0.025, 0.025, 0.025];

mdl.gridSearchFlag = 1;     % set to1 to do a preliminary grid search of the optimised parameter if the default starting value returns Nan

% Set fmincon options (for outer problem) if required:
mdl.options = optimoptions(@fmincon, 'Display', 'off');

% Set GSFlag to 1 to do a global search for the MLE, or 0 to do a local
% search (fmincon only):
mdl.GSFlag = (varyParamsFlag == 1);                             % set GS option only if do a parameter variation run     
mdl.gs = GlobalSearch(Display = "off", MaxTime = 1000);     % set GS options (if required)


