function obs = genObs(eObs, par)

% Function to generate synthetic data from a model solution specifying the expected value
%
% USAGE: obs = genObs(eObs, par)
%
% INPUTS: eObs - expected values of the observed data
%         par - structure of model parameter values (as returned by getPar) - note only the fields of par relating to the noise model (type and parameters) will be accessed
%
% OUTPUTS: obs - observed data
%
% NB: par.noiseModel should be one of "norm_SD_const", "norm_SD_propMean", "poisson", "negbin"
%     If "norm_SD_const", par.obsSD should be set to the std. dev. of the noise distribution
%     If "norm_SD_prop", par.obsSD should be set to the proportionality constant realting the std. dev. of the noise distribution to the mean
%     If "negbin", par.obsK should be set to the dispersion factor of the negative binomial noise distribution
%     If either of the Gaussian ("norm_*") models is used, par.obsIntFlag should be set to 1 to round obsrved data to the nearest integer or 0 otherwsie

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
