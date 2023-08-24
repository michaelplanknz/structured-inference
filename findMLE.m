clear 
close all


addpath('functions');

% Generate data from forward model
par = getPar();
sol = solveModel(par);
obs = genObs(sol, par);


% Initial guess for fitted parameters [R0, tR, pObs, obsSD]
Theta0 = [1.5; 400; 0.1; 0.4];

% Define lower and upper bounds on fitted parameters
lb = [0; 0; 0; 0];
ub = [30; 5000; 1; 2];

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLik(obs, Theta, par));

% Local search starting from Theta0...
ThetaMLE = fmincon( objFn, Theta0, [], [], [], [], lb, ub )

% ...or global search
% problem = createOptimProblem('fmincon','x0', Theta0, 'objective', objFn, 'lb', lb, 'ub', ub);
% ThetaMLE = run(GlobalSearch, problem);


parMLE = getTrialPar(ThetaMLE, par);
solMLE = solveModel(parMLE);

figure(1);
subplot(1, 2, 1)
plot(sol.t, 1/par.tE*sol.E, solMLE.t, 1/parMLE.tE*solMLE.E )
legend('actual', 'MLE')
xlabel('time (days)')
ylabel('new daily infections')
ylim([0 inf])
subplot(1, 2, 2)
plot(sol.t, (1/par.tObs)*sol.C1, solMLE.t, (1/parMLE.tObs)*solMLE.C1 , sol.t, obs, '.' )
legend('model actual', 'model MLE', 'data')
xlabel('time (days)')
ylabel('new daily observations')
ylim([0 inf])




