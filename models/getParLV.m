function par = getParLV(Theta)

% Function to return a structure `par` of parameter values for the predator-prey model
% The input variable Theta contains the values of the target parameters, which will vary form one run of the model to the next. All other parameters are fixed.
% The field par.noiseModel is required to specify the noise model being used for observed data.
% Built-in options for the noise model are "norm_SD_const", "norm_SD_propMean", "poisson" and "negBin" - see ReadMe file on the GitHub repo `structured-inference` for details

par.tMax = 100;        % simulation time 

% Initial conditions
par.y0 = [500; 500];

% Model parameters
par.r = Theta(1);
par.K = 5000;
par.a = Theta(2);
par.b = 1000;
par.mu = Theta(3);

% Observation parameters
par.pObs = Theta(4);        % proportion of population observed

% Noise model and parameters
par.noiseModel = "poisson";        % noise model is normal with SD proportional to mean
par.obsIntFlag = 0;     % set flag to indicate observations are not rounded to integer values

