function obs = genObsSEIR(sol, par)

Yt = 1/par.tObs * sol.C1;
nObs = length(Yt);

% Simple noise model is just integer-rounded multiplicative Gaussian noise 
% Alternative could be, e.g. NegBin noise or Poisson distributed noise with
% multiplicative Gaussian mean
obs = max(0, round( Yt.*(1+par.obsSD*randn(nObs, 1)) ));


