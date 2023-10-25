function [ThetaMLE, parMLE, solMLE, countMLE] = doMLE(getTrialPar, solveModel, obs, par, Theta0, lb, ub, options)

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLik(getTrialPar, solveModel, obs, Theta, par));

% Local search starting from Theta0...
[ThetaMLE, ~, ~, output] = fmincon( objFn, Theta0, [], [], [], [], lb, ub, [], options);
countMLE = output.funcCount;

% ...or global search
% problem = createOptimProblem('fmincon','x0', Theta0, 'objective', objFn, 'lb', lb, 'ub', ub);
% ThetaMLE = run(GlobalSearch, problem);

% Solve model at MLE estimate and plot results
parMLE = getTrialPar(ThetaMLE, par);
solMLE = solveModel(parMLE);
