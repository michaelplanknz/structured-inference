function eObs = transformSolutionMultiply(Phi, sol) 

% Transform function for the SEIR model (and possibly others)
% In this model, the optimised parameter Phi represent pObs, the probability that an infection is reported as a case.
% This simply mutliplies the expected observation in the solution to the model where pObs=1

try
    eObs = Phi * sol.eObs;
catch
    1
end

