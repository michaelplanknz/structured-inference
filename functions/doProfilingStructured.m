function [ThetaProfile, logLik, countProfile] = doProfilingStructured(mdl, obs, ThetaMLEStructured, LLMLEStructured, nMesh)

% Function to calculate the univariate profiles using the structured methiod
% 
% USAGE: [ThetaProfile, logLik, countProfile] = doProfilingStructured(mdl, obs, ThetaMLEStructured, LLMLEStructured, nMesh)
%
% INPUTS: mdl - a model-specification structure (as returned by specifyModel)
%         obs - an array of observed data
%         ThetaMLEStructured - vector of target parameter values at the MLE
%         LLMLEStructured - value of the log-likelihood function at the MLE
%         nMesh - number of mesh points to use to construct the profile
%
% OUTPUTS: ThetaProfile - matrix each row of which is the uniform mesh of values of the outer target parameter used in the profile
%          logLik - corresponding matrix of log-likelihood values for each outer target parameter
%          countProfile - count of function calls to solveModel
%
% NB: because the inner parameter(s) aren't profiled, the outputs ThetaProfile and logLik will have fewer rows than the corresponding outputs from doProfiling using the basic method

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
ThetaMLEStructured_contracted = ThetaMLEStructured(parsToProfile);

nPars = length(Theta0_contracted);
countProfile = zeros(nPars, 1);
ThetaProfile = zeros(nPars, nMesh);
logLik = zeros(nPars, nMesh);
for iPar = 1:nPars
    jOther = setdiff(1:nPars, iPar);        % indices of parameters not being profiled

    meshRange = sort( [ 1-profileRange(iPar), 1+profileRange(iPar)] * ThetaMLEStructured_contracted(iPar) );
    ThetaMesh = linspace(meshRange(1), meshRange(2), nMesh);

    ll = zeros(1, nMesh);
    ll(iMid) = LLMLEStructured;
    iStart = iMid+1;        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLEStructured_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLikStructured(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar) ));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], mdl.options);
        if exitFlag <= 0
             fprintf('Warning in doProfilingStructured: fmincon failed to converge to a local minimum on iPar = %i, iStart = %i (exitFlag = %i)\n', iPar, iStart, exitFlag)
        end
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    iStart = iMid-1;        % start profiling from the MLE leftwards
    ThetaOther0 = ThetaMLEStructured_contracted(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:-1:1
        objFn = @(ThetaOther)(-calcLogLikStructured(mdl, obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar) ));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb_contracted(jOther), ub_contracted(jOther), [], mdl.options);
        if exitFlag <= 0
             fprintf('Warning in doProfilingStructured: fmincon failed to converge to a local minimum on iPar = %i, iStart = %i (exitFlag = %i)\n', iPar, iStart, exitFlag)
        end
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    ThetaProfile(iPar, :) = ThetaMesh;
    logLik(iPar, :) = ll;
end

