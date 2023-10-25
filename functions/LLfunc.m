function LL = LLfunc(yMean, yData, SD, noiseModel)

small = 1e-10;


nPoints = length(yData);

if noiseModel == "norm_SD_const"
    % Log likelihood (PDF of a normal with mean yMean and variance SD^2)
    LL = -nPoints*log(SD) - 0.5/SD^2*sum( (yData-yMean).^2 );

elseif noiseModel == "norm_SD_propMean"
    yMean_pos = max(small, yMean);   % To avoid numerical problems, replace non-positive values with a small positive number
    
    % Log likelihood (PDF of a normal with mean yMean_pos and variance SD^2*yMean_pos^2)
    LL = -nPoints*log(SD) - sum( log(yMean_pos) + 0.5 * (yData-yMean_pos).^2./(SD^2*yMean_pos.^2)  );
else
    error("LLfunc: noiseModel type needs to be one of: 'const', 'propMean'");
end

