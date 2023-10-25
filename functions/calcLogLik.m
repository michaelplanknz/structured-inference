function LL = calcLogLik(getTrialPar, solveModel, obs, Theta, par)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 


% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = getTrialPar(Theta, par);

% Solve forward model
sol = solveModel(par); 

LL = LLfunc(sol.eObs, obs, par.obsSD, par.noiseModel);

