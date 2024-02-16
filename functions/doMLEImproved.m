function [ThetaMLEImproved, parMLEImproved, solMLEImproved, LLMLEImproved, countMLEImproved] = doMLEImproved(mdl, obs)


% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);


% Deine objective function for optimisation
objFn = @(Theta_contracted)(-calcLogLikImproved(mdl, obs, Theta_contracted));

if mdl.GSFlag == 0
    % Local search starting from Theta0...
    [ThetaMLE_contracted, f, exitFlag, output] = fmincon( objFn, mdl.Theta0(parsToProfile), [], [], [], [], mdl.lb(parsToProfile), mdl.ub(parsToProfile), [], mdl.options );
    if exitFlag <= 0
        fprintf('Warning in doMLEImproved: fmincon failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
else
    gs = GlobalSearch;
    gs.MaxTime = mdl.GSMaxTime;
    gs.Display = 'iter';
    problem = createOptimProblem('fmincon', 'x0', mdl.Theta0(parsToProfile), 'objective', objFn, 'lb', mdl.lb(parsToProfile), 'ub', mdl.ub(parsToProfile), 'options', mdl.options);
    [ThetaMLE_contracted, f, exitFlag, output, gsSolns]  = run(gs, problem);
    if exitFlag <= 0
        fprintf('Warning in doMLImprovedE: GS failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
end

LLMLEImproved = -f;
countMLEImproved = output.funcCount;

% Post-calculate optimal value of parameter(s) to be optimised
[~, PhiMLE] = calcLogLikImproved(mdl, obs, ThetaMLE_contracted);

% Combine the output from fmincon with the value of the parameter(s) optimised "within the loop" into a single vector of consistent format with ThetaMLE
ThetaMLEImproved = makeTheta(PhiMLE, ThetaMLE_contracted, mdl.parsToOptimise );

% Solve model at MLE estimate and plot results
parMLEImproved = mdl.getPar(ThetaMLEImproved);
solMLEImproved = mdl.solveModel(parMLEImproved);
