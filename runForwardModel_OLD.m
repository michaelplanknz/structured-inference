clear 
close all

addpath('functions');

par = getPar();

sol = solveModel(par);
obs = genObs(sol, par);

figure(1);
subplot(1, 2, 1)
plot(sol.t, 1/par.tE*sol.E )
xlabel('time (days)')
ylabel('new daily infections')
ylim([0 inf])
subplot(1, 2, 2)
plot(sol.t, (1/par.tObs)*sol.C1, sol.t, obs, '.' )
legend('model', 'model+noise')
xlabel('time (days)')
ylabel('new daily observations')
ylim([0 inf])




