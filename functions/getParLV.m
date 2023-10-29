function par = getParLV();

par.tMax = 100;        % simulation time 

% Initial conditions
par.y0 = [100; 100];

% Model parameters
par.r = 1;
par.K = 1000;
par.a = 1.5;
par.b = 200;
par.mu = 1;

% Observation parameters
par.pObs = 0.1;        % proportion of population observed

% Noise model and parameters
par.noiseModel = "poisson";        % noise model is normal with SD proportional to mean
par.obsIntFlag = 0;     % set flag to indicate observations are not rounded to integer values
par.obsSD = 2;        % SD of noise on observed values
