function [LL, PhiOpt] = calcLogLikImproved(getPar, solveModel, transformSolution, obs, Theta_contracted, parsToOptimise, runningValues, Theta0, lb, ub, options)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 
% Phi0, lb, and ub are the initial condition and lower and upper bound for the parameter(s) to be optimised (e.g. pOObs)

% Construct a full parameter vector theta by suitably concatenating Theta_contracted with the specified, fixed value (runningValues) of the parameter(s) Phi to be optimised 
Theta = makeTheta(runningValues, Theta_contracted, parsToOptimise);

% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = getPar(Theta);

% Solve forward model (with pObs = 1 or equivalent modification made by getTrialParImproved)
sol = solveModel(par); 

% Find optimal Phi (representing e.g. pObs) and associated log likelihood, starting from initial guess pObs = 0.5
% Note this optimisation stop does not require the forward model to be re-run, it just evaluates the likelihood at scaled_yMean = pObs*yMean
objFn = @(Phi)(-LLfunc( transformSolution(Phi, sol), obs, par));
[PhiOpt, f, exitFlag] = fmincon(objFn, Theta0(parsToOptimise), [], [], [], [], lb(parsToOptimise), ub(parsToOptimise), [], options);           

assert(exitFlag > 0)

% f is negative log likelihood so return -f
LL = -f;

