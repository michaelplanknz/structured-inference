function [ThetaMLE, parMLE, solMLE, countMLE] = doMLE(mdl, obs)

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLik(mdl, obs, Theta));

% Local search starting from Theta0...
[ThetaMLE, ~, ~, output] = fmincon( objFn, mdl.Theta0, [], [], [], [], mdl.lb, mdl.ub, [], mdl.options);

% gs = GlobalSearch;
% gs.MaxTime = mdl.GSMaxTime;
% gs.Display = 'iter';
% problem = createOptimProblem('fmincon', 'x0', mdl.Theta0, 'objective', objFn,'lb', mdl.lb, 'ub', mdl.ub, 'options', mdl.options);
% [ThetaMLE, ~, ~, output, gsSolns]  = run(gs, problem);

countMLE = output.funcCount;

% ...or global search
% problem = createOptimProblem('fmincon','x0', Theta0, 'objective', objFn, 'lb', lb, 'ub', ub);
% ThetaMLE = run(GlobalSearch, problem);

% Solve model at MLE estimate and plot results
parMLE = mdl.getPar(ThetaMLE);
solMLE = mdl.solveModel(parMLE);

end

