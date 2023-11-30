function eObs = transformSolution_OgataBanks(Phi, sol) 

% Here Phi represents the retardation factor R
% In this instance, sol represents the Ogata Banks solution when R=1
% To transform the Ogata Banks solutuion for a value of R>1, use the scaling relationship c(x, t, R) = c(x, t/R, 1)
 

tObs = max(sol.tt);
cTrans = interp1(sol.tt, sol.c, tObs/Phi);

eObs = (Phi-1)*cTrans;

