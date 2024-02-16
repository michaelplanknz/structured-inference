function LL = calcLogLik(mdl, obs, Theta)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 


% Get parameter strcutre for the specified values of Theta
par = mdl.getPar(Theta);

% Solve forward model
sol = mdl.solveModel(par); 

% Call likelihood function
%try
    LL = LLfunc(sol.eObs, obs, par);
%catch
%     fprintf('sol.eObs:\n');
%     disp(sol.eObs)
%     fprintf('obs:\n');
%     disp(obs)
%     fprintf('par:\n');
%     disp(par) 
% end

