function [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getTrialPar, getTrialParImproved, solveModel, obs, par, Theta0, lb, ub, parsToOptimise, options)


% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(Theta0), parsToOptimise);



% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLikImproved(getTrialParImproved, solveModel, obs, Theta, par, Theta0(parsToOptimise), lb(parsToOptimise), ub(parsToOptimise), options));

% Local search starting from Theta0...
[ThetaMLE_contracted, ~, ~, output] = fmincon( objFn, Theta0(parsToProfile), [], [], [], [], lb(parsToProfile), ub(parsToProfile), [], options );
countMLEImproved = output.funcCount;

% Post-calculate optimal value of parameter(s) to be optimised
[~, PhiMLE] = calcLogLikImproved(getTrialParImproved, solveModel, obs, ThetaMLE_contracted, par, Theta0(parsToOptimise), lb(parsToOptimise), ub(parsToOptimise), options);

% Combine the output from fmincon with the value of the parameter(s) optimised "within the loop" into a single vector of consistent format with ThetaMLE
ThetaMLEImproved = makeTheta(PhiMLE, ThetaMLE_contracted, parsToOptimise )

% Solve model at MLE estimate and plot results
parMLEImproved = getTrialPar(ThetaMLEImproved, par);
solMLEImproved = solveModel(parMLEImproved);
