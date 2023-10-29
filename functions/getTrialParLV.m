function trialPar = getTrialParLV(Theta, par)

% Construct a modified (trial) parameter structure trialPar by overwriting the default settings in par with the specified values of Theta

trialPar = par;
trialPar.r  = Theta(1);
trialPar.a = Theta(2);
trialPar.pObs = Theta(3);
%trialPar.obsSD = Theta(4);
