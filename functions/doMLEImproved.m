function [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(mdl, obs, options)


% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);


% Deine objective function for optimisation
objFn = @(Theta_contracted)(-calcLogLikImproved(mdl, obs, Theta_contracted, options));

% Local search starting from Theta0...
%[ThetaMLE_contracted, ~, ~, output] = fmincon( objFn, mdl.Theta0(parsToProfile), [], [], [], [], mdl.lb(parsToProfile), mdl.ub(parsToProfile), [], options );

gs = GlobalSearch;
gs.MaxTime = mdl.GSMaxTime;
problem = createOptimProblem('fmincon', 'x0', mdl.Theta0(parsToProfile), 'objective', objFn, 'lb', mdl.lb(parsToProfile), 'ub', mdl.ub(parsToProfile), 'options', options);
[ThetaMLE_contracted, ~, ~, output]  = run(gs, problem);

countMLEImproved = output.funcCount;

% Post-calculate optimal value of parameter(s) to be optimised
[~, PhiMLE] = calcLogLikImproved(mdl, obs, ThetaMLE_contracted, options);

% Combine the output from fmincon with the value of the parameter(s) optimised "within the loop" into a single vector of consistent format with ThetaMLE
ThetaMLEImproved = makeTheta(PhiMLE, ThetaMLE_contracted, mdl.parsToOptimise );

% Solve model at MLE estimate and plot results
parMLEImproved = mdl.getPar(ThetaMLEImproved);
solMLEImproved = mdl.solveModel(parMLEImproved);
