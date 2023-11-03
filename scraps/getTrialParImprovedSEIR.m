function trialPar = getTrialParImprovedSEIR(Theta, par)

% Construct a modified (trial) parameter structure trialPar by overwriting the default settings in par with the specified values of Theta

trialPar = par;
trialPar.R0  = Theta(1);
trialPar.tR = Theta(2);
trialPar.obsSD = Theta(3);

% Set pObs = 1 for all forward model runs under improved profiling method
trialPar.pObs = 1;