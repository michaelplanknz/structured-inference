function CIs = findCIs(x, LL, threshold)

[nPars, nPoints] = size(x);
iMid = (nPoints+1)/2;

CIs = nan(nPars, 2);

for iPar = 1:nPars
    % Find index of the first point before midway that is above threshold
    ind1 =          find(LL(iPar, 1:iMid)   >= threshold, 1, 'first' );  
    % Find the inex of the last point after midway that is above threshold
    ind2 = iMid-1 + find(LL(iPar, iMid:end) >= threshold, 1, 'last');

    % Interpolate to find lower and upper CIs
    % For the purposes of testing coverage properties, if all values in the profiled interval are above threshold (i.e. CI boundary is outside interval), set the CI boundary to be the edge of the interval.
    % This will produce CIs that are narrower than they should be, which is conservative for testing coverage
    if ind1 == 1
        CI(iPar, 1) = x(iPar, 1);
    elseif isempty(ind1)
        CI(iPar, 1) = x(iPar, iMid);
    else
       CIs(iPar, 1) = interp1( LL(iPar, ind1-1:ind1), x(iPar, ind1-1:ind1), threshold );
    end
    if ind2 == nPoints
        CI(iPar, 2) = x(iPar, end);
    elseif isempty(ind2)
        CI(iPar, 2) = x(iPar, iMid);
    else
       CIs(iPar, 2) = interp1( LL(iPar, ind2:ind2+1), x(iPar, ind2:ind2+1), threshold );
    end
end

