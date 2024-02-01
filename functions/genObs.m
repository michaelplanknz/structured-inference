function obs = genObs(eObs, par)


if par.noiseModel == "norm_SD_const" 
    obs =  eObs + par.obsSD*randn(size(eObs)) ;
elseif par.noiseModel == "norm_SD_propMean"
    obs = max(0, eObs.*(1+par.obsSD*randn(size(eObs)) ));
elseif par.noiseModel == "poisson"
   obs = max(0, poissrnd(max(0, eObs)));
elseif par.noiseModel == "negbin"
    obs = nbinrnd(par.obsK, par.obsK./(max(0, eObs)+par.obsK));
else
   error("noiseModel type needs to be one of: 'const', 'propMean', 'poisson', 'negbin'");
end

if ismember(par.noiseModel, ["norm_SD_const", "norm_SD_propMean"]) && par.obsIntFlag
    obs = round(obs);
end
