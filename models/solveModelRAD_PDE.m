function sol = solveModelRAD_PDE(par)

% Function to solve the reaction-advection-diffusion PDE model for specified parameter values in the structure par
% The output sol is a structure containing (at a minimum) two fields
% sol.xPlot is a vector of values of the independent model variable (typically time or space)
% sol.eObs is a matrix containing the model solution (expected values of observed data)
% Each row of sol.eObs contains the expected value of the observed data at the value of the independent variable in the correspondng row of sol.xPlot
%
% To apply the structure method to this model additionally requires that sol has a field sol.u 
% sol.u contains the value of the solution for u at a range of values of t between t=0 and t=tObs
% The transformation function (transformSolution_OgataBanks) will look up values of sol.u at earlier times (t<tObs) in order to calculate the solution for different values of R

% Set up t grid for evaluating PDE solution
nPoints = 1001;
sol.t = linspace(0, par.tObs, nPoints);

[X, T] = meshgrid(par.xObs, sol.t);

% Evaluate Ogata-Banks solution - compute as exp(. + log(erfc(.)) ) to avoid numerical issues
sol.u = 0.5 * par.C0 * ( erfc((X-par.V/par.R*T)./(sqrt(4*par.D/par.R*T))) + exp( X*par.V/par.D + log(erfc((X+par.V/par.R*T)./(sqrt(4*par.D/par.R*T))) )  ) );
sol.s = (par.R-1).*sol.u;


% Horizontal axis coordinate against which observation values will be plotted
sol.xPlot = par.xObs;

% Calculate mean (expected) observations
sol.eObs = sol.s(end, :);

