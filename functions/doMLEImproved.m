function [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getTrialPar, getTrialParImproved, solveModel, obs, par, Theta0_contracted, lb_contracted, ub_contracted, parsToOptimise, options)


%options = optimoptions('fmincon', 'Display', 'iter');

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLikImproved(getTrialParImproved, solveModel, obs, Theta, par, options));

% Local search starting from Theta0...
[ThetaMLEImproved, ~, ~, output] = fmincon( objFn, Theta0_contracted, [], [], [], [], lb_contracted, ub_contracted, [], options );
countMLEImproved = output.funcCount;

% Post-calculate optimal pObs
[~, pObsMLEImproved] = calcLogLikImproved(getTrialParImproved, solveModel, obs, ThetaMLEImproved, par, options);

% Solve model at MLE estimate and plot results
parMLEImproved = getTrialPar( makeTheta(pObsMLEImproved, ThetaMLEImproved, parsToOptimise ), par);
solMLEImproved = solveModel(parMLEImproved);
