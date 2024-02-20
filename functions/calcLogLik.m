function LL = calcLogLik(mdl, obs, Theta)

% Function to calculate log likelihood of observed data obs under target parameters Theta using the basic method
%
% USAGE: LL = calcLogLik(mdl, obs, Theta)
%
% INPUTS: mdl - a model-specification structure (as returned by specifyModel)
%         obs - an array of observed data
%         Theta - values of the target parameters at which to evaluate the likelihood function
%
% OUTPUTS: LL - log-likelihood


% Get parameter strcutre for the specified values of Theta
par = mdl.getPar(Theta);

% Solve forward model
sol = mdl.solveModel(par); 

% Evaluate log-likelihood function
LL = LLfunc(sol.eObs, obs, par);


