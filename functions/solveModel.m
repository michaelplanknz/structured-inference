function sol = solveModel(par)

tSpan = 0:1:par.tMax;
IC = getIC(par);
[t, Y] = ode45(@(t, x)odeRHS(t, x, par), tSpan, IC);

sol.t = t;
sol.S = Y(:, 1);                            % susceptible
sol.E = Y(:, 2);                            % exposed
sol.I = Y(:, 3);                            % infectious
sol.R1 = Y(:, 4);                           % recovered (part I)
sol.R2 = par.popSize - sum(Y(:, 1:4), 2);   % recovered (part II)
sol.C1 = Y(:, 5);                             % observed (latent)
sol.C2 = Y(:, 6);                             % observed (cumulative)


