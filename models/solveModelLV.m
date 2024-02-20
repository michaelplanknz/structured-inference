function sol = solveModelLV(par)

% Function to solve the predator-prey model for specified parameter values in the structure par
% The output sol is a structure containing (at a minimum) two fields
% sol.xPlot is a vector of values of the independent model variable (typically time or space)
% sol.eObs is a matrix containing the model solution (expected values of observed data)
% Each row of sol.eObs contains the expected value of the observed data at the value of the independent variable in the correspondng row of sol.xPlot

tSpan = 0:1:par.tMax;

% Set initial condition
IC = par.y0;

% Set ODE solver options to specify non-negative solutions are required
options = odeset('NonNegative', ones(size(IC)));

% Solve ODE
[t, Y] = ode45(@(t, x)odesLV(t, x, par), tSpan, IC, options);

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
sol.prey = Y(:, 1);                            % susceptible
sol.pred = Y(:, 2);                            % exposed

% Horizontal axis coordinate against which observation values will be plotted
sol.xPlot = sol.t;

% Calculate mean (expected) observations
sol.eObs = par.pObs*[sol.prey, sol.pred];

