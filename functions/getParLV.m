function par = getParLV(Theta);

par.tMax = 100;        % simulation time 

% Initial conditions
par.y0 = [100; 100];

% Model parameters
par.r = Theta(1);
par.K = 1000;
par.a = Theta(2);
par.b = 200;
par.mu = 1;

% Observation parameters
par.pObs = Theta(3);        % proportion of population observed

% Noise model and parameters
par.noiseModel = "poisson";        % noise model is normal with SD proportional to mean
par.obsIntFlag = 0;     % set flag to indicate observations are not rounded to integer values
