function eObs = transformSolution_OgataBanks(Phi, sol) 

% Transformation function for the Ogata-Banks solution to the reaction-advection-diffusion PDE model
% Here the inner parameter Phi represents the retardation factor R and sol represents the Ogata Banks solution when R=1
% To transform the Ogata Banks solutuion for a value of R>1, use the scaling relationship u(x, t, R) = u(x, t/R, 1)
 
% Observation time is by definition the last time in sol
tObs = max(sol.t);

% Use linear interpolation to recover the value of the solution (sol.u) at t=tObs/R:
uTrans = interp1(sol.t, sol.u, tObs/Phi);

% The solution for the product s in terms of the solute u is s(x,t)=(R-1)*u(x,t):
eObs = (Phi-1)*uTrans;

