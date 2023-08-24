function ThetaFull = makeTheta(ThetaFocal, ThetaOther, iFocal)

% Make a full vector fitted parameters out of a focal parameter ThetaFocal (the one being profiled) and a vector of other parameters ThetaOther (the ones being optimized) 
% iFocal is the index of ThetaFocal in ThetaFull


nTheta = length(ThetaOther)+1;
ThetaFull = zeros(nTheta, 1);
ThetaFull(iFocal) = ThetaFocal;
ThetaFull(setdiff(1:nTheta, iFocal)) = ThetaOther;
