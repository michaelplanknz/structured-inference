function [logLik, countProfile] = doProfilingImproved(getPar, solveModel, transformSolution, obs, ThetaMLEImproved, Theta0, lb, ub, ThetaLower, ThetaUpper, parsToOptimise, runningValues, nMesh, options)


% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(Theta0), parsToOptimise);

% Create contracted vectors containing only the information for the parameters to be profiled
lb_contracted = lb(parsToProfile);
ub_contracted = ub(parsToProfile);
Theta0_contracted = Theta0(parsToProfile);
ThetaLower_contracted = ThetaLower(parsToProfile);
ThetaUpper_contracted = ThetaUpper(parsToProfile);
ThetaMLEImproved_contracted = ThetaMLEImproved(parsToProfile);





nPars = length(Theta0_contracted);
countProfile = zeros(nPars, 1);
logLik = zeros(nPars, nMesh);
parfor iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower_contracted(iPar), ThetaUpper_contracted(iPar), nMesh);
    jOther = setdiff(1:nPars, iPar);

    ll = zeros(1, nMesh);
    iStart = find(ThetaMesh >= ThetaMLEImproved_contracted(iPar), 1, 'first');        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLEImproved_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLikImproved(getPar, solveModel, transformSolution, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), parsToOptimise, runningValues, Theta0, lb, ub, options));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    ThetaOther0 = ThetaMLEImproved_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart-1:-1:1
        objFn = @(ThetaOther)(-calcLogLikImproved(getPar, solveModel, transformSolution, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), parsToOptimise, runningValues, Theta0, lb, ub, options));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    logLik(iPar, :) = ll;
end

