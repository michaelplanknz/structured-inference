function [LL, PhiOpt] = calcLogLikImproved(getTrialParImproved, solveModel, transformSolution, obs, Theta, par, Phi0, lb, ub, options)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 
% Phi0, lb, and ub are the initial condition and lower and upper bound for the parameter(s) to be optimised (e.g. pOObs)


% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = getTrialParImproved(Theta, par);

% Solve forward model (with pObs = 1 or equivalent modification made by getTrialParImproved)
sol = solveModel(par); 

% Find optimal Phi (representing e.g. pObs) and associated log likelihood, starting from initial guess pObs = 0.5
% Note this optimisation stop does not require the forward model to be re-run, it just evaluates the likelihood at scaled_yMean = pObs*yMean
objFn = @(Phi)(-LLfunc( transformSolution(Phi, sol), obs, par.obsSD, par.noiseModel));
[PhiOpt, f, exitFlag] = fmincon(objFn, Phi0, [], [], [], [], lb, ub, [], options);           

assert(exitFlag > 0)

% f is negative log likelihood so return -f
LL = -f;

