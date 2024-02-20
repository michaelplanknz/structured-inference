function [LL, PhiOpt] = calcLogLikStructured(mdl, obs, Theta_contracted)

% Function to calculate log likelihood of observed data obs under target parameters Theta using the structured method
%
% USAGE: [LL, PhiOpt] = calcLogLikStructured(mdl, obs, Theta_contracted)
%
% INPUTS: mdl - a model-specification structure (as returned by specifyModel)
%         obs - an array of observed data
%         Theta_contracted - values of the outer target parameters at which to evaluate the likelihood function
%
% OUTPUTS: LL - log-likelihood
%          PhiOpt - optimised value(s) of the inner parameter(s) at he specified values of the outer parameters

maxAttempts = 1000; % maximum number of attempts to find a valid starting value for the inner parameter(s)

% Construct a full parameter vector theta by suitably concatenating Theta_contracted with the specified, fixed reference value (runningValues) of the inner parameter(s) Phi to be optimised 
Theta = makeTheta(mdl.runningValues, Theta_contracted, mdl.parsToOptimise);

% Get parameter strcutre for the specified values of Theta and the reference value of the inner parameter(s)
par = mdl.getPar(Theta);

% Solve forward model with the reference value of the inner parameter(s)
sol = mdl.solveModel(par); 

% Objective function for the inner optimisation problem to find optimal value of the inner parameter(s) Phi 
% This is the likelihood function evaluated with observed data obs evaluated at the transformed solution for inner parameter(s) Phi 
% Note evaluating this objective function does not require the forward model to be re-run, it just evaluates the likelihood using the specified transformation function in mdl.transformSolution
objFn = @(Phi)(-LLfunc( mdl.transformSolution(Phi, sol), obs, par));

% Default initial condition for the inner parameter(s)
x0 = mdl.Theta0(mdl.parsToOptimise);

% Check whether the objective funciton returns a value output (finite number) at the default initial conditon
validStartFlag = isfinite(objFn(x0));

% If default startng value is invalid, and the grid search flag is set
% (and only one parameter is being optimised) conduct a grid search to try and
% find a valid starting value using a 1D Halton sequence 
if length(mdl.parsToOptimise) == 1 & mdl.gridSearchFlag
    iAttempt = 1;
    while validStartFlag == 0 & iAttempt < maxAttempts
        h = haltonSeq(iAttempt, 2);     % get the ith number in the Halton sequence
        x0 = mdl.lb(mdl.parsToOptimise) + h*(mdl.ub(mdl.parsToOptimise)-mdl.lb(mdl.parsToOptimise)) ;
        validStartFlag = isfinite(objFn(x0));       % check whether the trial initial conditoin x0 returns a valid output
        iAttempt = iAttempt+1;
    end
end


if validStartFlag
    opts = optimoptions(@fmincon, 'Display', 'off');
    % Solve the inner optimisation problem
    [PhiOpt, f, exitFlag] = fmincon(objFn, x0, [], [], [], [], mdl.lb(mdl.parsToOptimise), mdl.ub(mdl.parsToOptimise), [], opts);           
    LL = -f;        % f is negative log likelihood so set LL = -f
    if exitFlag <= 0
        fprintf('Warning in calcLogLikStructured.m: fmincon failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
else
    LL = -inf;
    fprintf('Warning in calcLogLikStructured: unable to find feasible start point for fmincon\n')
end



