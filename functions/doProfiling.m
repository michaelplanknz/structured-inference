function [logLik, countProfile] = doProfiling(getTrialPar, solveModel, obs, par, ThetaMLE, Theta0, lb, ub, ThetaLower, ThetaUpper, nMesh, options)

nPars = length(Theta0);      % number of parameters to profile
countProfile = zeros(nPars, 1);
logLik = zeros(nPars, nMesh);
parfor iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower(iPar), ThetaUpper(iPar), nMesh);
    jOther = setdiff(1:nPars, iPar);

    ll = zeros(1, nMesh);
    iStart = find(ThetaMesh >= ThetaMLE(iPar), 1, 'first');        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLik(getTrialPar, solveModel, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), par));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb(jOther), ub(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart-1:-1:1
        objFn = @(ThetaOther)(-calcLogLik(getTrialPar, solveModel, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), par));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb(jOther), ub(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    logLik(iPar, :) = ll;
end

