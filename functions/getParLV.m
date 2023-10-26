function par = getParLV();

par.tMax = 100;        % simulation time 

% Initial conditions
par.y0 = [0.1; 0.1];

% Model parameters
par.r = 1;
par.K = 1;
par.a = 1.5;
par.b = 0.2;
par.mu = 1;

% Observation parameters
par.pObs = 0.1;        % proportion of population observed

% Noise model and parameters
par.noiseModel = "norm_SD_const";        % noise model is normal with SD proportional to mean
par.obsIntFlag = 0;     % set flag to indicate observations are not rounded to integer values
par.obsSD = 0.002;        % SD of noise on observed values
