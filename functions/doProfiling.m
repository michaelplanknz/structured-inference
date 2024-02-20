function [ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, LLMLE, nMesh)

% Function to calculate the univariate profiles using the basic methiod
% 
% USAGE: [ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, LLMLE, nMesh)
%
% INPUTS: mdl - a model-specification structure (as returned by specifyModel)
%         obs - an array of observed data
%         ThetaMLE - vector of target parameter values at the MLE
%         LLMLE - value of the log-likelihood function at the MLE
%         nMesh - number of mesh points to use to construct the profile
%
% OUTPUTS: ThetaProfile - matrix each row of which is the uniform mesh of values of the target parameter used in the profile
%          logLik - corresponding matrix of log-likelihood values for each target parameter
%          countProfile - count of function calls to solveModel

% Force nMesh to be odd so there is a central point
nMesh = 2*ceil((nMesh-1)/2) + 1;
iMid = (nMesh+1)/2;     % index of central point in the mesh

nPars = length(mdl.Theta0);      % number of parameters to profile
countProfile = zeros(nPars, 1);
ThetaProfile = zeros(nPars, nMesh);
logLik = zeros(nPars, nMesh);



for iPar = 1:nPars
    jOther = setdiff(1:nPars, iPar);        % indices of parameters not being profiled

    meshRange = sort( [ 1-mdl.profileRange(iPar), 1+mdl.profileRange(iPar)] * ThetaMLE(iPar) );
    ThetaMesh = linspace(meshRange(1), meshRange(2), nMesh);

    ll = zeros(1, nMesh);
    ll(iMid) = LLMLE;
    iStart = iMid+1;        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLik(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar)));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], mdl.lb(jOther), mdl.ub(jOther), [], mdl.options);
        if exitFlag <= 0
             fprintf('Warning in doProfiling: fmincon failed to converge to a local minimum on iPar = %i, iStart = %i (exitFlag = %i)\n', iPar, iStart, exitFlag)
        end
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    iStart = iMid-1;        % start profiling from the MLE leftwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:-1:1
        objFn = @(ThetaOther)(-calcLogLik(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar)));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], mdl.lb(jOther), mdl.ub(jOther), [], mdl.options);
        if exitFlag <= 0
             fprintf('Warning in doProfiling: fmincon failed to converge to a local minimum on iPar = %i, iStart = %i (exitFlag = %i)\n', iPar, iStart, exitFlag)
        end
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    ThetaProfile(iPar, :) = ThetaMesh;
    logLik(iPar, :) = ll;
end

