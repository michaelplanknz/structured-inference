function [LL, pObsOpt] = calcLogLikImproved(getTrialParImproved, solveModel, obs, Theta, par, options)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 


nPoints = length(obs);

% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = getTrialParImproved(Theta, par);

% Solve forward model (with pObs = 1 or equivalent modification made by getTrialParImproved)
[~, Yt] = solveModel(par); 

% Find optimal pObs and associated log likelihood, starting from initial guess pObs = 0.5
% Note this optimisation stop does not require the forward model to be re-run, it just evaluates the likelihood at scaled_yMean = pObs*yMean
objFn = @(pObs)(-LLfunc(pObs*Yt, obs, par.obsSD, par.noiseModel));
[pObsOpt, f, exitFlag] = fmincon(objFn, 0.05, [], [], [], [], 0, 1, [], options);            % 0.5 is the initial condition for the optimisd parameter; [0, 1] arguments require the optimised parameter to be bounded by [0, 1] 
assert(exitFlag > 0)
%pObsOpt


LL = -f;

