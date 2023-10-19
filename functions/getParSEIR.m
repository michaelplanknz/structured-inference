function par = getParSEIR();

% Simulation parameters
par.popSize = 5e6;      % population size
par.tMax = 2000;        % simulation time (days)
par.tSeed = 10;         % seed time (days)
par.seedSize = 20;      % magnitude of seeding event (number of introduced infections)
par.seedDur = 1;        % parameter controlling duration of seeding event (days) = SD of Gaussian forcing function

% Epi parameters
par.R0 = 1.3;           % R0
par.tE = 2;             % avg exposed time (days)
par.tI = 4;             % avg infectious time (days)
par.tR = 300;           % avg immune time (days)

% Observation parameters
par.pObs = 0.01;        % proportion of infections observed
par.tObs = 3;           % avg time from becoming infectious to being observed (days)

% Noise parameters
par.obsSD = 0.2;        % SD of multiplicative noise on observed values

