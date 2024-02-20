function par = getParSEIR(Theta)

% Function to return a structure `par` of parameter values for the SEIR model
% The input variable Theta contains the values of the target parameters, which will vary form one run of the model to the next. All other parameters are fixed.
% The field par.noiseModel is required to specify the noise model being used for observed data.
% Built-in options for the noise model are "norm_SD_const", "norm_SD_propMean", "poisson" and "negBin" - see ReadMe file on the GitHub repo `structured-inference` for details

% Simulation parameters
par.popSize = 5e6;      % population size
par.tMax = 2000;        % simulation time (days)
par.E0 = 100;           % initial number of exposed 

% Epi parameters
par.R0 = Theta(1);           % R0
par.Gamma = 1/2;             % inverse of vg exposed time (days)
par.Mu = 1/4;             % inverse of avg infectious time (days)
par.w = Theta(2);            % inverse of avg immune time (days)

% Observation parameters
par.pObs = Theta(3);        % proportion of infections observed
par.obsRate = 1/3;           % inverse of avg time from becoming infectious to being observed (days)

% Noise model and parameters
% par.noiseModel = "norm_SD_propMean";        % noise model is normal with SD proportional to mean
% par.obsIntFlag = 1;     % set flag to indicate observations are rounded to integer values
% par.obsSD = Theta(4);        % SD of multiplicative noise on observed values
par.noiseModel = "negbin";
par.obsK = Theta(4);


