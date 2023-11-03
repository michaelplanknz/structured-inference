function LL = calcLogLik(getPar, solveModel, obs, Theta)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 


% Get parameter strcutre for the specified values of Theta
par = getPar(Theta);

% Solve forward model
sol = solveModel(par); 

% Call likelihood function
LL = LLfunc(sol.eObs, obs, par);

