function trialPar = getTrialPar(Theta, par)

% Construct a modified (trial) parameter structure trialPar by overwriting the default settings in par with the specified values of Theta

trialPar = par;
trialPar.R0  = Theta(1);
trialPar.tR = Theta(2);
trialPar.pObs = Theta(3);
trialPar.obsSD = Theta(4);
