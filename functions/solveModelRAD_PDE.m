function sol = solveModelRAD_PDE(par)

% Set up t grid for evaluating PDE solution
nPoints = 1001;
sol.t = linspace(0, par.tObs, nPoints);

[X, T] = meshgrid(par.xObs, sol.t);

% Evaluate Ogata-Banks solution
sol.c = 0.5 * par.C0 * ( erfc((X-par.V/par.R*T)./(sqrt(4*par.D/par.R*T))) + exp(X*par.V/par.D).*erfc((X+par.V/par.R*T)./(sqrt(4*par.D/par.R*T))) );
sol.s = (par.R-1).*sol.c;


% Horizontal axis coordinate against which observation values will be plotted
sol.xPlot = par.xObs;

% Calculate mean (expected) observations
sol.eObs = sol.s(end, :);

