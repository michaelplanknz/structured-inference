function LL = nestedObjFn(pObs, Yt, obs, par)

% Nested objective function for optimisation of pObs, assuming all other parameters are fixed as in the parameter structure par 
% Yt is the expected observations when pObs = 1
% obs contains the actual data

small = 1e-10;

nPoints = length(obs);
    
Ytscaled = pObs*Yt;           % Scale unnormalised Yt (which assumed pObs=1) by pObs 
Ytp = max(small, Ytscaled);   % To avoid numerical problems, replace non-positive values with a small positive number

% Log likelihood (PDF of a normal with mean Yt and variance obsSD^2*Yt^2
LL = -nPoints*log(par.obsSD) - sum( log(Ytp) + 0.5*(obs-Ytp).^2./(par.obsSD^2*Ytp.^2)  );

