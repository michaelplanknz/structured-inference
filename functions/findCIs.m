function CIs = findCIs(x, LL, threshold)

[nPars, nPoints] = size(x);
nMid = (nPoints+1)/2;

CIs = nan(nPars, 2);

for iPar = 1:nPars
    % Find index of the first point before midway that is above threshold
    ind1 =          find(LL(iPar, 1:nMid)   >= threshold, 1, 'first' );  
    % Find the inex of the last point after midway that is above threshold
    ind2 = nMid-1 + find(LL(iPar, nMid:end) >= threshold, 1, 'last');

    % Interpolate to find lower and upper CIs
    % For the purposes of testing coverage properties, if all values in the profiled interval are above threshold (i.e. CI boundary is outside interval), set the CI boundary to be the edge of the interval.
    % This will produce CIs that are narrower than they should be, which is conservative for testing coverage
    if ind1 > 1
       CIs(iPar, 1) = interp1( LL(iPar, ind1-1:ind1), x(iPar, ind1-1:ind1), threshold );
    else
        CI(iPar, 1) = x(iPar, 1);
    end
    if ind2 < nPoints
       CIs(iPar, 2) = interp1( LL(iPar, ind2:ind2+1), x(iPar, ind2:ind2+1), threshold );
    else
        CI(iPar, 2) = x(iPar, 2);
    end
end