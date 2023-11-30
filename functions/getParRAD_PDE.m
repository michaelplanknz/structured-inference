function par = getParRAD_PDE(Theta);

% Simulation parameters
par.tMax = 100;        % simulation time
par.C0 = 100;          % boundary condition
                        




% Noise model and parameters
par.noiseModel = "norm_SD_const";        % noise model is normal with SD proportional to mean
par.obsIntFlag = 0;     % set flag to indicate observations are rounded to integer values
par.obsSD = Theta(4);        % SD of noise on observed values

