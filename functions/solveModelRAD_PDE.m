function sol = solveModelRAD_PDE(par)

% Set up t grid for evaluating PDE solution
nPoints = 1001;
sol.tt = linspace(0, par.tObs, nPoints);

[X, T] = meshgrid(par.xObs, sol.tt);

% Evaluate Ogata-Banks solution
sol.c = 0.5 * par.C0 * ( erfc((X-par.V/par.R*T)./(sqrt(4*par.D/par.R*T))) + exp(X*par.V/par.D).*erfc((X+par.V/par.R*T)./(sqrt(4*par.D/par.R*T))) );
sol.s = (par.R-1).*sol.c;


% Hack for now - in plotGraphs.m solutions and data are by default plotted against sol.t so use this to store x values
sol.t = par.xObs;

% Calculate mean (expected) observations
sol.eObs = sol.s(end, :);

