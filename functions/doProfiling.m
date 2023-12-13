function [ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, nMesh)

nPars = length(mdl.Theta0);      % number of parameters to profile
countProfile = zeros(nPars, 1);
ThetaProfile = zeros(nPars, nMesh);
logLik = zeros(nPars, nMesh);
for iPar = 1:nPars

    %ThetaMesh = linspace(mdl.ThetaLower(iPar), mdl.ThetaUpper(iPar), nMesh);
    meshRange = sort( [ 1-mdl.profileRange, 1+mdl.profileRange] * ThetaMLE(iPar) );
    ThetaMesh = linspace(meshRange(1), meshRange(2), nMesh);
    jOther = setdiff(1:nPars, iPar);

    ll = zeros(1, nMesh);
    iStart = find(ThetaMesh >= ThetaMLE(iPar), 1, 'first');        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLik(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar)));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], mdl.lb(jOther), mdl.ub(jOther), [], mdl.options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    iStart = find(ThetaMesh < ThetaMLE(iPar), 1, 'last');        % start profiling from the MLE leftwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:-1:1
        objFn = @(ThetaOther)(-calcLogLik(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar)));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], mdl.lb(jOther), mdl.ub(jOther), [], mdl.options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    ThetaProfile(iPar, :) = ThetaMesh;
    logLik(iPar, :) = ll;
end

