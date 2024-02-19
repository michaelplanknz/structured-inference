function [LL, PhiOpt] = calcLogLikStructured(mdl, obs, Theta_contracted)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 
% Phi0, lb, and ub are the initial condition and lower and upper bound for the parameter(s) to be optimised (e.g. pOObs)

maxAttempts = 1000; % maximum number of attempts to find a valid starting value

% Construct a full parameter vector theta by suitably concatenating Theta_contracted with the specified, fixed value (runningValues) of the parameter(s) Phi to be optimised 
Theta = makeTheta(mdl.runningValues, Theta_contracted, mdl.parsToOptimise);

% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = mdl.getPar(Theta);

% Solve forward model (with pObs = 1 or equivalent modification made by getTrialParStructured)
sol = mdl.solveModel(par); 

% Find optimal Phi (representing e.g. pObs) and associated log likelihood, starting from initial guess pObs = 0.5
% Note this optimisation stop does not require the forward model to be re-run, it just evaluates the likelihood at scaled_yMean = pObs*yMean
objFn = @(Phi)(-LLfunc( mdl.transformSolution(Phi, sol), obs, par));

x0 = mdl.Theta0(mdl.parsToOptimise);
validStartFlag = isfinite(objFn(x0));

% If default startng value is invalid, and the grid search flag is set
% (only one parameter is being optimised) conduct a grid search to try and
% find a valid starting value
if length(mdl.parsToOptimise) == 1 & mdl.gridSearchFlag
    iAttempt = 1;
    while validStartFlag == 0 & iAttempt < maxAttempts
        h = haltonSeq(iAttempt, 2);
        x0 = mdl.lb(mdl.parsToOptimise) + h*(mdl.ub(mdl.parsToOptimise)-mdl.lb(mdl.parsToOptimise)) ;
        validStartFlag = isfinite(objFn(x0));
        iAttempt = iAttempt+1;
    end
end


if validStartFlag
    opts = optimoptions(@fmincon, 'Display', 'off');
    [PhiOpt, f, exitFlag] = fmincon(objFn, x0, [], [], [], [], mdl.lb(mdl.parsToOptimise), mdl.ub(mdl.parsToOptimise), [], opts);           
    LL = -f;        % f is negative log likelihood so return -f
    if exitFlag <= 0
        fprintf('Warning in calcLogLikStructured.m: fmincon failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
else
    LL = -inf;
    fprintf('Warning in calcLogLikStructured: unable to find feasible start point for fmincon\n')
end



