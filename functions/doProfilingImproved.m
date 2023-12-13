function [ThetaProfile, logLik, countProfile] = doProfilingImproved(mdl, obs, ThetaMLEImproved, nMesh)


% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);

% Create contracted vectors containing only the information for the parameters to be profiled
lb_contracted = mdl.lb(parsToProfile);
ub_contracted = mdl.ub(parsToProfile);
Theta0_contracted = mdl.Theta0(parsToProfile);
% ThetaLower_contracted = mdl.ThetaLower(parsToProfile);
% ThetaUpper_contracted = mdl.ThetaUpper(parsToProfile);
ThetaMLEImproved_contracted = ThetaMLEImproved(parsToProfile);





nPars = length(Theta0_contracted);
countProfile = zeros(nPars, 1);
ThetaProfile = zeros(nPars, nMesh);
logLik = zeros(nPars, nMesh);
for iPar = 1:nPars
    %ThetaMesh = linspace(ThetaLower_contracted(iPar), ThetaUpper_contracted(iPar), nMesh);
    meshRange = sort( [ 1-mdl.profileRange, 1+mdl.profileRange] * ThetaMLEImproved_contracted(iPar) );
    ThetaMesh = linspace(meshRange(1), meshRange(2), nMesh);
    jOther = setdiff(1:nPars, iPar);

    ll = zeros(1, nMesh);
    iStart = find(ThetaMesh >= ThetaMLEImproved_contracted(iPar), 1, 'first');        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLEImproved_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLikImproved(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar) ));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], mdl.options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    iStart = find(ThetaMesh < ThetaMLEImproved_contracted(iPar), 1, 'last');        % start profiling from the MLE leftwards
    ThetaOther0 = ThetaMLEImproved_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:-1:1
        objFn = @(ThetaOther)(-calcLogLikImproved(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar) ));
        [x, f, ~, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], mdl.options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    ThetaProfile(iPar, :) = ThetaMesh;
    logLik(iPar, :) = ll;
end

