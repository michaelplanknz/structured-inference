clear 
close all

% Folder with Matlab functions
addpath('functions');

% Folder for saving plots
savFolder = "figures/";

optTol = 1e-10;          % default is 1e-6

options = optimoptions('fmincon', 'Display', 'off');%, 'OptimalityTolerance', optTol);



% Generate data from forward model
par = getPar();
sol = solveModel(par);
obs = genObs(sol, par);
ThetaTrue = [par.R0; par.tR; par.obsSD];





tic

% Initial guess for fitted parameters [R0, tR, pObs, obsSD]
parLbl = ["R0", "tR", "obsSD"];
Theta0 = [1.5; 400; 0.4];

% Define lower and upper bounds on fitted parameters
lb = [0; 0; 0];
ub = [20; 2000; 2];

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLikImproved(obs, Theta, par));

% Local search starting from Theta0...
[ThetaMLE, ~, exitFlag, output] = fmincon( objFn, Theta0, [], [], [], [], lb, ub, [], options );
countMLE = output.funcCount;

% Post-calculate optimal pObs
[~, pObsMLE] = calcLogLikImproved(obs, ThetaMLE, par);

% Solve model at MLE estimate and plot results
parMLE = getTrialPar([ThetaMLE(1:2); pObsMLE; ThetaMLE(3)], par);
solMLE = solveModel(parMLE);

h = figure(1);
h.Position =   [ 560   591   974   357];
subplot(1, 2, 1)
plot(sol.t, 1/par.tE*sol.E, solMLE.t, 1/parMLE.tE*solMLE.E )
legend('actual', 'MLE')
xlabel('time (days)')
ylabel('new daily infections')
ylim([0 inf])
title(sprintf('MLE %i evaluations', countMLE))
subplot(1, 2, 2)
plot(sol.t, (1/par.tObs)*sol.C1, solMLE.t, (1/parMLE.tObs)*solMLE.C1 , sol.t, obs, '.' )
legend('actual', 'MLE', 'data')
xlabel('time (days)')
ylabel('new daily observations')
ylim([0 inf])
saveas(gcf, savFolder+"mleImproved", 'png');
drawnow






% Profile each parameter

nMesh = 21;     % number of points in parameter mesh

% Profile intervals for each parameter
ThetaLower = [1.2; 250; 0.15];
ThetaUpper = [1.4; 350; 0.4];

nPars = length(Theta0);
countProfile = zeros(nPars, 1);
logLik = zeros(nPars, nMesh);
parfor iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower(iPar), ThetaUpper(iPar), nMesh);
    jOther = setdiff(1:nPars, iPar);

    ll = zeros(1, nMesh);
    iStart = find(ThetaMesh >= ThetaMLE(iPar), 1, 'first');        % start profiling from the MLE rightwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart:nMesh
        objFn = @(ThetaOther)(-calcLogLikImproved(obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), par));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb(jOther), ub(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    % now profile from the MLE leftwards
    ThetaOther0 = ThetaMLE(jOther);                                % use MLE as initial guess for first run
    for iMesh = iStart-1:-1:1
        objFn = @(ThetaOther)(-calcLogLikImproved(obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), par));
        [x, f, exitFlag, output] = fmincon(objFn, ThetaOther0, [], [], [], [], lb(jOther), ub(jOther), [], options);
        ll(iMesh) = -f;
        ThetaOther0 = x;                                          % use profile solution as the initial guess for the next run
        countProfile(iPar) = countProfile(iPar) + output.funcCount;
    end

    logLik(iPar, :) = ll;
end

toc

h = figure(2);
h.Position = [   560         239        1012         709];
for iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower(iPar), ThetaUpper(iPar), nMesh);
    subplot(2, 2, iPar)
    plot(ThetaMesh, logLik(iPar, :))
    xline(ThetaMLE(iPar), 'r--');
    xline(ThetaTrue(iPar), 'k--');
    legend('profile likelihood', 'MLE', 'actual')
    xlabel(parLbl(iPar))
    ylabel('log likelihood')
    title(sprintf('Profile %i evaluations', countProfile(iPar)))
    drawnow
end

saveas(gcf, savFolder+"profilesImproved", 'png');


