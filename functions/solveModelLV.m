function sol = solveModelLV(par)

tSpan = 0:1:par.tMax;

% Set initial condition
IC = par.y0;

% Solve ODE
[t, Y] = ode45(@(t, x)odesLV(t, x, par), tSpan, IC);

% If ODE solution terminates before tMax (because of numerical problems), pad solution with Y=infinity 
if t(end) < par.tMax
    nVars = length(IC);
    tPad = ((t(end)+1):1:par.tMax)';
    nPad = length(tPad);
    t = [t; tPad];
    Y = [Y; inf*ones(nPad, nVars)];
    size(Y)
end

% Extract solution variables from ODE solver output
sol.t = t;
sol.prey = Y(:, 1);                            % susceptible
sol.pred = Y(:, 2);                            % exposed

% Calculate mean (expected) observations
sol.eObs = par.pObs*[sol.prey, sol.pred];

