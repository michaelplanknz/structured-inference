function [LL, pObsOpt] = calcLogLikImproved(obs, Theta, par)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 

options = optimoptions('fmincon', 'Display', 'off');

nPoints = length(obs);

% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = getTrialParImproved(Theta, par);

% Solve forward model with pObs = 1
par.pObs = 1;
sol = solveModel(par); 

% Expected observed values under pObs=1
Yt = 1/par.tObs * sol.C1;       

% Find optimal pObs and associated log likelihood, starting from initial guess pObs = 0.5
% Note this optimisation stop does not require the forward model to be re-run
objFn = @(pObs)(-nestedObjFn(pObs, Yt, obs, par));
[pObsOpt, f, exitFlag, output] = fmincon(objFn, 0.5, [], [], [], [], 0, 1, [], options);
assert(exitFlag > 0)

LL = -f;

