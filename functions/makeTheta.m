function ThetaFull = makeTheta(ThetaFocal, ThetaOther, iFocal)

% Make a full vector fitted parameters out of a focal parameter ThetaFocal (the one being profiled) and a vector of other parameters ThetaOther (the ones being optimized) 
% iFocal is the index of ThetaFocal in ThetaFull


nTheta = length(ThetaOther)+length(iFocal);
if max(iFocal) > nTheta
    error('Maximum value in iFocal cannot be greater than the sum of the lengths of ThetaFocal and ThetaOther')
end
ThetaFull = nan(nTheta, 1);
ThetaFull(iFocal) = ThetaFocal;
ThetaFull(setdiff(1:nTheta, iFocal)) = ThetaOther;
