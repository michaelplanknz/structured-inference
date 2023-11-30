function par = getParRAD_PDE(Theta);

% Simulation parameters
par.tObs = 100;        % simulation time
par.C0 = 100;          % boundary condition

par.xObs = 0:5:100;   % x points at which data is observed 

% PDE coefficients
par.D = Theta(1);
par.V = Theta(2);
par.R = Theta(3);


% Noise model and parameters
par.noiseModel = "norm_SD_const";        % noise model is normal with SD proportional to mean
par.obsIntFlag = 0;     % set flag to indicate observations are rounded to integer values
par.obsSD = Theta(4);        % SD of noise on observed values

