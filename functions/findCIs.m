function CIs = findCIs(x, LL, Alpha)

% Function to calculate CIs from univariate parameter profiles
%
% USAGE: CIs = findCIs(x, LL, Alpha)
%
% INPUTS: x - n x m matrix of parameter values, each row of which is a mesh of values for one target parameter (as returned by doProfiling)
%         LL - n x m matrix of corresponding normalised log-likelihoods
%         Alpha - significance level to use (e.g. 0.05 for 95% CIs)
%
% OUTUTS: CIs - n x 2 vector of CI boundaries for each target parameter (1st column contains the left boundaries, 2nd column contains the right boundaries)



% Calculate threshold value on normalised log likelihood for (1-Alpha)% confidence intervals 
thresholdValue = -0.5*chi2inv(1-Alpha, 1);

% Number of parameters to calculatye CIs for and number of mesh points for each parameter
[nPars, nPoints] = size(x);
% Index of the midpoint of the mesh
iMid = (nPoints+1)/2;

% Initialise array
CIs = nan(nPars, 2);

% Loop through each parameter
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

