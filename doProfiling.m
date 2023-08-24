clear 
close all


addpath('functions');

savFolder = "figures/";

% Generate data from forward model
par = getPar();
sol = solveModel(par);
obs = genObs(sol, par);
ThetaTrue = [par.R0; par.tR; par.pObs; par.obsSD];

% Initial guess for fitted parameters [R0, tR, pObs, obsSD]
parLbl = ["R0", "tR", "pObs", "obsSD"];
Theta0 = [1.5; 400; 0.1; 0.4];

% Define lower and upper bounds on fitted parameters
lb = [0; 0; 0; 0];
ub = [20; 2000; 1; 2];

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLik(obs, Theta, par));

% Local search starting from Theta0...
ThetaMLE = fmincon( objFn, Theta0, [], [], [], [], lb, ub )

% ...or global search
% problem = createOptimProblem('fmincon','x0', Theta0, 'objective', objFn, 'lb', lb, 'ub', ub);
% ThetaMLE = run(GlobalSearch, problem);

parMLE = getTrialPar(ThetaMLE, par);
solMLE = solveModel(parMLE);

h = figure(1);
h.Position =   [ 560   591   974   357];
subplot(1, 2, 1)
plot(sol.t, 1/par.tE*sol.E, solMLE.t, 1/parMLE.tE*solMLE.E )
legend('actual', 'MLE')
xlabel('time (days)')
ylabel('new daily infections')
ylim([0 inf])
subplot(1, 2, 2)
plot(sol.t, (1/par.tObs)*sol.C1, solMLE.t, (1/parMLE.tObs)*solMLE.C1 , sol.t, obs, '.' )
legend('actual', 'MLE', 'data')
xlabel('time (days)')
ylabel('new daily observations')
ylim([0 inf])
saveas(gcf, savFolder+"mle", 'png');
drawnow

% Profile each parameter

nMesh = 21;

ThetaLower = [1.15; 200; 0.005; 0.15];
ThetaUpper = [1.5; 350; 0.02; 0.4];

nPars = length(Theta0);
logLik = zeros(nPars, nMesh);

h = figure(2);
h.Position = [   560         239        1012         709];
for iPar = 1:nPars
    ThetaMesh = linspace(ThetaLower(iPar), ThetaUpper(iPar), nMesh);
    iOther = setdiff(1:nPars, iPar);
    for iMesh = 1:nMesh
        objFn = @(ThetaOther)(-calcLogLik(obs, makeTheta(ThetaMesh(iMesh), ThetaOther, iPar), par));
        [x, f] = fmincon(objFn, ThetaMLE(iOther), [], [], [], [], lb(iOther), ub(iOther));
        logLik(iPar, iMesh) = -f;
        
%         ThetaProf = makeTheta(ThetaMesh(iMesh), x, iPar);
%         parProf = getTrialPar(ThetaProf, par);
%         solProf = solveModel(parProf);
% 
%         figure(3)
%         plot(solProf.t, (1/parMLE.tObs)*solProf.C1 , sol.t, obs, '.' )
%         drawnow
    end

    subplot(2, 2, iPar)
    plot(ThetaMesh, logLik(iPar, :))
    xline(ThetaMLE(iPar), 'r--');
    xline(ThetaTrue(iPar), 'k--');
    legend('profile likelihood', 'MLE', 'actual')
    xlabel(parLbl(iPar))
    drawnow
end
saveas(gcf, savFolder+"profiles", 'png');


