function [sol, Yt] = solveModelSEIR(par)


tSpan = 0:1:par.tMax;

% Define initial number in each compartment
S0 = par.popSize;       % susceptible
E0 = 0;                 % exposed
I0 = 0;                 % infectious
R10 = 0;                % recovered (part I)
C10 = 0;                % observed (latent)
C20 = 0;                % observed (cumulative)
IC = [S0; E0; I0; R10; C10; C20];

% Solve ODE
[t, Y] = ode45(@(t, x)odeSEIR(t, x, par), tSpan, IC);

% Extract solution variables from ODE solver output
sol.t = t;
sol.S = Y(:, 1);                            % susceptible
sol.E = Y(:, 2);                            % exposed
sol.I = Y(:, 3);                            % infectious
sol.R1 = Y(:, 4);                           % recovered (part I)
sol.R2 = par.popSize - sum(Y(:, 1:4), 2);   % recovered (part II)
sol.C1 = Y(:, 5);                             % cases (latent)
sol.C2 = Y(:, 6);                             % cases (cumulative)

% Calculate mean (expected) observations
Yt = 1/par.tObs * sol.C1;

