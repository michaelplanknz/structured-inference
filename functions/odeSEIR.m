function dydt = odeSEIR(t, y, par)

big = 1e6;

S = y(1);                       % susceptible
E = y(2);                       % exposed
I = y(3);                       % infectious
R1 = y(4);                      % recovered (stage I)
R2 = par.popSize - sum(y(1:4)); % recovered (stage II)
C1 = y(5);                      % cases (latent)
C2 = y(6);                      % cases (cumulative)

% Force of infection proportional to number infectious 
FOI = par.R0 * (I*par.Mu) /par.popSize ;

dSdt = -FOI * S  +  2*par.w * R2;
dEdt =  FOI * S  -  par.Gamma * E;
dIdt =  par.Gamma * E  -  par.Mu * I;
dR1dt = par.Mu * I  -  2*par.w * R1;

dC1dt = par.pObs * par.Gamma * E  -  par.obsRate * C1;
dC2dt = par.obsRate * C1;

dydt = [dSdt; dEdt; dIdt; dR1dt; dC1dt; dC2dt];

% To prevent variables from becoming negative:
% (note an altenrative way to do this that avoids artificially introducing a steep gradient in the solution when outside the bioloigcal region would be to adjust error tolerances so that negative solutions never occur in the parameter range of interest)
negFlag = y < 0;
dydt(negFlag) = -big*y(negFlag);

