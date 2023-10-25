function eObs = transformSolutionSEIR(Phi, sol) 

% Transform function for the SEIR model
% In this model, the optimised parameter Phi represent pObs, the probability that an infection is reported as a case.
% This simply mutliplies the expected observation in the solution to the model where pObs=1

eObs = Phi * sol.eObs;

