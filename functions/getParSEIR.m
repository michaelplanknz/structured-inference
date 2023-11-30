function par = getParSEIR(Theta);

% Simulation parameters
par.popSize = 5e6;      % population size
par.tMax = 2000;        % simulation time (days)
par.tSeed = 10;         % seed time (days)
par.seedSize = 20;      % magnitude of seeding event (number of introduced infections)
par.seedDur = 1;        % parameter controlling duration of seeding event (days) = SD of Gaussian forcing function

% Epi parameters
par.R0 = Theta(1);           % R0
par.tE = 2;             % avg exposed time (days)
par.tI = 4;             % avg infectious time (days)
par.tR = Theta(2);           % avg immune time (days)

% Observation parameters
par.pObs = Theta(3);        % proportion of infections observed
par.tObs = 3;           % avg time from becoming infectious to being observed (days)

% Noise model and parameters
% par.noiseModel = "norm_SD_propMean";        % noise model is normal with SD proportional to mean
% par.obsIntFlag = 1;     % set flag to indicate observations are rounded to integer values
% par.obsSD = Theta(4);        % SD of multiplicative noise on observed values
par.noiseModel = "negbin";
par.obsK = Theta(4);

par.gridSearchFlag = 0;     % set to 1 to do a preliminary grid search of the optimised parameter if the default starting value returns Nan

