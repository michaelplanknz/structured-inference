function dydt = odeRHS(t, y, par)

S = y(1);                       % susceptible
E = y(2);                       % exposed
I = y(3);                       % infectious
R1 = y(4);                      % recovered (part I)
R2 = par.popSize - sum(y(1:4)); % recovered (part II)
C1 = y(5);                      % observed (latent)
C2 = y(6);                      % observed (cumulative)

% Force of infection proportional to number infectious plus seeding term
FOI = par.R0 * (I/par.tI + par.seedSize * normpdf(t, par.tSeed, par.seedDur)) /par.popSize ;

dSdt = -FOI * S  +  2/par.tR * R2;
dEdt =  FOI * S  -  1/par.tE * E;
dIdt =  1/par.tE * E  -  1/par.tI * I;
dR1dt = 1/par.tI * I  -  2/par.tR * R1;

dC1dt = par.pObs * 1/par.tE * E  -  1/par.tObs * C1;
dC2dt = 1/par.tObs * C1;

dydt = [dSdt; dEdt; dIdt; dR1dt; dC1dt; dC2dt];

