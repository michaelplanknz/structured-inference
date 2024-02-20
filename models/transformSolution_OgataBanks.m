function eObs = transformSolution_OgataBanks(Phi, sol) 

% Transformation function for the Ogata-Banks solution to the reaction-advection-diffusion PDE model
% Here the inner parameter Phi represents the retardation factor R and sol represents the Ogata Banks solution when R=1
% To transform the Ogata Banks solutuion for a value of R>1, use the scaling relationship c(x, t, R) = c(x, t/R, 1)
 
% Observation time is by definition the last time in sol
tObs = max(sol.t);

% Use linear interpolation to recover the value of the solution (sol.c) at t=tObs/R:
cTrans = interp1(sol.t, sol.c, tObs/Phi);

% The solution for the produce s in terms of the solute c is s(x,t)=(R-1)*u(x,t):
eObs = (Phi-1)*cTrans;

