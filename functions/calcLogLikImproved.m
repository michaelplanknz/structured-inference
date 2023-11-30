function [LL, PhiOpt] = calcLogLikImproved(getPar, solveModel, transformSolution, obs, Theta_contracted, parsToOptimise, runningValues, Theta0, lb, ub, options)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 
% Phi0, lb, and ub are the initial condition and lower and upper bound for the parameter(s) to be optimised (e.g. pOObs)

maxAttempts = 1000; % maximum number of attempts to find a valid starting value

% Construct a full parameter vector theta by suitably concatenating Theta_contracted with the specified, fixed value (runningValues) of the parameter(s) Phi to be optimised 
Theta = makeTheta(runningValues, Theta_contracted, parsToOptimise);

% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = getPar(Theta);

% Solve forward model (with pObs = 1 or equivalent modification made by getTrialParImproved)
sol = solveModel(par); 

% Find optimal Phi (representing e.g. pObs) and associated log likelihood, starting from initial guess pObs = 0.5
% Note this optimisation stop does not require the forward model to be re-run, it just evaluates the likelihood at scaled_yMean = pObs*yMean
objFn = @(Phi)(-LLfunc( transformSolution(Phi, sol), obs, par));

x = Theta0(parsToOptimise);
validStartFlag = isfinite(objFn(x));

% If default startng value is invalid, and the grid search flag is set
% (only one parameter is being optimised) conduct a grid search to try and
% find a valid starting value
if length(parsToOptimise) == 1 & par.gridSearchFlag
    iAttempt = 1;
    while validStartFlag == 0 & iAttempt < maxAttempts
        h = haltonSeq(iAttempt, 2);
        x = lb(parsToOptimise) + h*(ub(parsToOptimise)-lb(parsToOptimise)) ;
        validStartFlag = isfinite(objFn(x));
        iAttempt = iAttempt+1;
    end
end

if validStartFlag
    [PhiOpt, f, exitFlag] = fmincon(objFn, Theta0(parsToOptimise), [], [], [], [], lb(parsToOptimise), ub(parsToOptimise), [], options);           
    LL = -f;        % f is negative log likelihood so return -f
else
    LL = -inf;
end



