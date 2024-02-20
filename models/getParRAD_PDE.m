function par = getParRAD_PDE(Theta)

% Function to return a structure `par` of parameter values for the reaction-advection-diffusion PDE model
% The input variable Theta contains the values of the target parameters, which will vary form one run of the model to the next. All other parameters are fixed.
% The field par.noiseModel is required to specify the noise model being used for observed data.
% Built-in options for the noise model are "norm_SD_const", "norm_SD_propMean", "poisson" and "negBin" - see ReadMe file on the GitHub repo `structured-inference` for details

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

