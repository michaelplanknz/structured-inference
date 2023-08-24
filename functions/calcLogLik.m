function LL = calcLogLik(obs, Theta, par)

% Calculate log likelihood of observed data obs under parameters Theta
% par is the structrue containing all model parameters
% Theta is the vector of selected parameters to be fitted 

% Construct a modified parameter structure by overwriting the default settings with the specified values of Theta
par = getTrialPar(Theta, par);

% Solve forward model
sol = solveModel(par); 
Yt = 1/par.tObs * sol.C1;
small = 1e-10;
%minY = min([small; Yt(Yt > 0)]);
%Ytp = max(minY, Yt);      % To avoid numerical problems, replace non-positive values with the smallest positive value in the solution
Ytp = max(small, Yt);

nPoints = length(obs);

% Log likelihood (PDF of a normal with mean Yt and variance obsSD^2*Yt^2
LL = -nPoints*log(par.obsSD) - sum( log(Ytp) + 0.5*(obs-Ytp).^2./(par.obsSD^2*Ytp.^2)  );

