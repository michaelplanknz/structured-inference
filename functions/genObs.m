function obs = genObs(Yt, par)

nObs = length(Yt);

if par.noiseModel == "norm_SD_const" 
    obs = max(0,  Yt + par.obsSD*randn(nObs, 1) );
elseif par.noiseModel == "norm_SD_propMean"
    % Simple noise model is just integer-rounded multiplicative Gaussian noise 
    % Alternative could be, e.g. NegBin noise or Poisson distributed noise with
    % multiplicative Gaussian mean
    obs = max(0, Yt.*(1+par.obsSD*randn(nObs, 1)) );
else
   error("LLfunc: noiseModel type needs to be one of: 'const', 'propMean'");
end

if par.obsIntFlag
    obs = round(obs);
end