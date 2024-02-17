function CIs = findCIs(x, LL, threshold)

[nPars, nPoints] = size(x);
nMid = (nPoints+1)/2;

CIs = nan(nPars, 2);

for iPar = 1:nPars
    % Find index of the first point before midway that is above threshold
    ind1 =          find(LL(iPar, 1:nMid)   >= -threshold, 1, 'first' );  
    % Find the inex of the last point after midway that is above threshold
    ind2 = nMid-1 + find(LL(iPar, nMid:end) >= -threshold, 1, 'last');

    % Interpolate to find lower and upper CIs
    if ind1 > 1
       CIs(iPar, 1) = interp1( LL(iPar, ind1-1:ind1), x(iPar, ind1-1:ind1), -threshold );
    end
    if ind2 < nPoints
       CIs(iPar, 2) = interp1( LL(iPar, ind2:ind2+1), x(iPar, ind2:ind2+1), -threshold );
    end
end