function [ThetaMLE, parMLE, solMLE, countMLE] = doMLE(mdl, obs, options)

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLik(mdl, obs, Theta));

% Local search starting from Theta0...
[ThetaMLE, ~, ~, output] = fmincon( objFn, mdl.Theta0, [], [], [], [], mdl.lb, mdl.ub, [], options);
countMLE = output.funcCount;

% ...or global search
% problem = createOptimProblem('fmincon','x0', Theta0, 'objective', objFn, 'lb', lb, 'ub', ub);
% ThetaMLE = run(GlobalSearch, problem);

% Solve model at MLE estimate and plot results
parMLE = mdl.getPar(ThetaMLE);
solMLE = mdl.solveModel(parMLE);

