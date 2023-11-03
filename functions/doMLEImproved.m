function [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(getPar, solveModel, transformSolution, obs, Theta0, lb, ub, parsToOptimise, runningValues, options)


% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(Theta0), parsToOptimise);


% Deine objective function for optimisation
objFn = @(Theta_contracted)(-calcLogLikImproved(getPar, solveModel, transformSolution, obs, Theta_contracted, parsToOptimise, runningValues, Theta0, lb, ub, options));

% Local search starting from Theta0...
[ThetaMLE_contracted, ~, ~, output] = fmincon( objFn, Theta0(parsToProfile), [], [], [], [], lb(parsToProfile), ub(parsToProfile), [], options );
countMLEImproved = output.funcCount;

% Post-calculate optimal value of parameter(s) to be optimised
[~, PhiMLE] = calcLogLikImproved(getPar, solveModel, transformSolution, obs, ThetaMLE_contracted, parsToOptimise, runningValues, Theta0, lb, ub, options);

% Combine the output from fmincon with the value of the parameter(s) optimised "within the loop" into a single vector of consistent format with ThetaMLE
ThetaMLEImproved = makeTheta(PhiMLE, ThetaMLE_contracted, parsToOptimise );

% Solve model at MLE estimate and plot results
parMLEImproved = getPar(ThetaMLEImproved);
solMLEImproved = solveModel(parMLEImproved);
