function LL = LLfunc(yMean, yData, SD, noiseModel)

small = 1e-10;

% If yMean and yData are n x m matrices (e.g. n x 2 matrix of time eries of 2 observed variables) this reshapes them both to be column vectors
yMean = yMean(:);
yData = yData(:);


nPoints = numel(yData);

if noiseModel == "norm_SD_const"
    % Log likelihood (PDF of a normal with mean yMean and variance SD^2)
    LL = -nPoints*(log(2*pi)/2 + log(SD))  -  0.5/SD^2 * sum( (yData-yMean).^2 );

elseif noiseModel == "norm_SD_propMean"
    yMean_pos = max(small, yMean);   % To avoid numerical problems, replace non-positive values with a small positive number
    
    % Log likelihood (PDF of a normal with mean yMean_pos and variance SD^2*yMean_pos^2)
    LL = -nPoints*(log(2*pi)/2 + log(SD))  -  sum( log(yMean_pos) + 0.5/SD^2 * (yData-yMean_pos).^2./(yMean_pos.^2)  );
elseif noiseModel == "poisson"
    yMean_pos = max(small, yMean);   % To avoid numerical problems, replace non-positive values with a small positive number

    Ci = [0, cumsum( log(1:max(yData)) )]';  % vector of cumulative sum of log(integers) for efficient calculation of log(k!) in LL
    LL = sum( yData.*log(yMean_pos) - yMean_pos - Ci(1+yData) ); 
else
   error("noiseModel type needs to be one of: 'const', 'propMean', 'poisson'");
end

