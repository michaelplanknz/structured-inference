function sol = solveModelSEIR(par)

tSpan = 0:1:par.tMax;


% Define initial number in each compartment
S0 = par.popSize-par.E0; % susceptible
E0 = par.E0;            % exposed
I0 = 0;                  % infectious
R10 = 0;                 % recovered (stage I)
C10 = 0;                 % observed (latent)
C20 = 0;                 % observed (cumulative)
IC = [S0; E0; I0; R10; C10; C20];

% Set ODE solver options to specify non-negative solutions are required
options = odeset('NonNegative', ones(size(IC)), options);

% Solve ODE
[t, Y] = ode45(@(t, x)odeSEIR(t, x, par), tSpan, IC);

% If ODE solution terminates before tMax (because of numerical problems), pad solution with Y=infinity 
if t(end) < par.tMax
    nVars = length(IC);
    tPad = ((t(end)+1):1:par.tMax)';
    nPad = length(tPad);
    t = [t; tPad];
    Y = [Y; inf*ones(nPad, nVars)];
end

% Extract solution variables from ODE solver output
sol.t = t;
sol.S = Y(:, 1);                              % susceptible
sol.E = Y(:, 2);                              % exposed
sol.I = Y(:, 3);                              % infectious
sol.R1 = Y(:, 4);                             % recovered (stage I)
sol.R2 = par.popSize - sum(Y(:, 1:4), 2);     % recovered (stage II)
sol.C1 = Y(:, 5);                             % cases (latent)
sol.C2 = Y(:, 6);                             % cases (cumulative)

% Horizontal axis coordinate against which observation values will be plotted
sol.xPlot = sol.t;

% Calculate mean (expected) observations
sol.eObs = par.obsRate * sol.C1;

