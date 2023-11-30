function obs = genObs(eObs, par)


if par.noiseModel == "norm_SD_const" 
    obs =  eObs + par.obsSD*randn(size(eObs)) ;
elseif par.noiseModel == "norm_SD_propMean"
    % Simple noise model is just integer-rounded multiplicative Gaussian noise 
    % Alternative could be, e.g. NegBin noise or Poisson distributed noise with
    % multiplicative Gaussian mean
    obs = max(0, eObs.*(1+par.obsSD*randn(size(eObs)) ));
elseif par.noiseModel == "poisson"
   obs = poissrnd(eObs);
elseif par.noiseModel == "negbin"
    obs = nbinrnd(par.obsK, par.obsK./(eObs+par.obsK));
else
   error("noiseModel type needs to be one of: 'const', 'propMean', 'poisson', 'negbin'");
end

if ismember(par.noiseModel, ["norm_SD_const", "norm_SD_propMean"]) && par.obsIntFlag
    obs = round(obs);
end
