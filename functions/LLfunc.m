function LL = LLfunc(yMean, yData, par)

small = 1e-10;

% If yMean and yData are n x m matrices (e.g. n x 2 matrix of time eries of 2 observed variables) this reshapes them both to be column vectors
yMean = yMean(:);
yData = yData(:);


nPoints = numel(yData);

if par.noiseModel == "norm_SD_const"
    % Log likelihood (PDF of a normal with mean yMean and variance SD^2)
    LL = -nPoints*(log(2*pi)/2 + log(par.obsSD))  -  0.5/par.obsSD^2 * sum( (yData-yMean).^2 );

elseif par.noiseModel == "norm_SD_propMean"
    yMean_pos = max(small, yMean);   % To avoid numerical problems, replace non-positive values with a small positive number
    
    % Log likelihood (PDF of a normal with mean yMean_pos and variance SD^2*yMean_pos^2)
    LL = -nPoints*(log(2*pi)/2 + log(par.obsSD))  -  sum( log(yMean_pos) + 0.5/par.obsSD^2 * (yData-yMean_pos).^2./(yMean_pos.^2)  );
elseif par.noiseModel == "poisson"
    yMean_pos = max(small, yMean);   % To avoid numerical problems, replace non-positive values with a small positive number

    Ci = [0, cumsum( log(1:max(yData)) )]';  % vector of cumulative sum of log(integers) for efficient calculation of log(k!) in LL
    LL = sum( yData.*log(yMean_pos) - yMean_pos - Ci(1+yData) ); 
elseif par.noiseModel == "negbin"       % NegBin with dispersion factor k
    yMean_pos = max(small, yMean);   % To avoid numerical problems, replace non-positive values with a small positive number

    LL = nPoints * (-gammaln(par.obsK) + par.obsK*log(par.obsK)) + sum( gammaln(yData+par.obsK) - gammaln(yData+1) + yData.*log(yMean_pos) - (yData+par.obsK).*log(yMean_pos+par.obsK) );
else
   error("par.noiseModel type needs to be one of: 'const', 'propMean', 'poisson', 'negbin'");
end

