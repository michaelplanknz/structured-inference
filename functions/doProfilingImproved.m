function [ThetaProfile, logLik, countProfile] = doProfilingImproved(mdl, obs, ThetaMLEImproved, LLMLEImproved, nMesh)

% Force nMesh to be odd so there is a central point
nMesh = 2*ceil((nMesh-1)/2) + 1;
iMid = (nMesh+1)/2;     % index of central point in the mesh

% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);

% Create contracted vectors containing only the information for the parameters to be profiled
lb_contracted = mdl.lb(parsToProfile);
ub_contracted = mdl.ub(parsToProfile);
profileRange = mdl.profileRange(parsToProfile);
Theta0_contracted = mdl.Theta0(parsToProfile);
ThetaMLEImproved_contracted = ThetaMLEImproved(parsToProfile);

nPars = length(Theta0_contracted);
countProfile = zeros(nPars, 1);
ThetaProfile = zeros(nPars, nMesh);
logLik = zeros(nPars, nMesh);
for iPar = 1:nPars
    jOther = setdiff(1:nPars, iPar);        % indices of parameters not being profiled

    meshRange = sort( [ 1-profileRange(iPar), 1+profileRange(iPar)] * ThetaMLEImproved_contracted(iPar) );
    ThetaMesh = linspace(meshRange(1), meshRange(2), nMesh);

    ll = zeros(1, nMesh);
    ll(iMid) = LLMLEImproved;
    iStart = iMid+1;        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLEImproved_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLikImproved(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar) ));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], mdl.options);
        if exitFlag <= 0
             fprintf('Warning in doProfilingImproved: fmincon failed to converge to a local minimum on iPar = %i, iStart = %i (exitFlag = %i)\n', iPar, iStart, exitFlag)
        end
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    iStart = iMid-1;        % start profiling from the MLE leftwards
    ThetaOther0 = ThetaMLEImproved_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:-1:1
        objFn = @(ThetaOther)(-calcLogLikImproved(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar) ));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], mdl.options);
        if exitFlag <= 0
             fprintf('Warning in doProfilingImproved: fmincon failed to converge to a local minimum on iPar = %i, iStart = %i (exitFlag = %i)\n', iPar, iStart, exitFlag)
        end
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    ThetaProfile(iPar, :) = ThetaMesh;
    logLik(iPar, :) = ll;
end

