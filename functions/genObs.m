function obs = genObs(eObs, par)


if par.noiseModel == "norm_SD_const" 
    obs = max(0,  eObs + par.obsSD*randn(size(eObs)) );
elseif par.noiseModel == "norm_SD_propMean"
    % Simple noise model is just integer-rounded multiplicative Gaussian noise 
    % Alternative could be, e.g. NegBin noise or Poisson distributed noise with
    % multiplicative Gaussian mean
    obs = max(0, eObs.*(1+par.obsSD*randn(size(eObs)) ));
elseif par.noiseModel == "poisson"
   obs = poissrnd(eObs);
else
   error("noiseModel type needs to be one of: 'const', 'propMean', 'poisson'");
end

if par.obsIntFlag
    obs = round(obs);
end
