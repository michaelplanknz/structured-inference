function [logLik, countProfile] = doProfilingImproved(getTrialParImproved, solveModel, obs, par, ThetaMLEImproved, Theta0_contracted, lb_contracted, ub_contracted, ThetaLower_contracted, ThetaUpper_contracted, nMesh, options)

nPars = length(Theta0_contracted);
countProfile = zeros(nPars, 1);
logLik = zeros(nPars, nMesh);
parfor iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower_contracted(iPar), ThetaUpper_contracted(iPar), nMesh);
    jOther = setdiff(1:nPars, iPar);

    ll = zeros(1, nMesh);
    iStart = find(ThetaMesh >= ThetaMLEImproved(iPar), 1, 'first');        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLEImproved(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLikImproved(getTrialParImproved, solveModel, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), par, options));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    ThetaOther0 = ThetaMLEImproved(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart-1:-1:1
        objFn = @(ThetaOther)(-calcLogLikImproved(getTrialParImproved, solveModel, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), par, options));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    logLik(iPar, :) = ll;
end

