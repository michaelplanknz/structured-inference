function eObs = transformSolutionMultiply(Phi, sol) 

% Linear transformation function for models (such as the predator-prey and SEIR model case studiese) where the solution is an affine linear function of the inner parameter Phi
% In this simple case, the expected value of the observed data when the inner parameter taks value Phi is just Phi*sol.eObs, where sol.eObs is the expected value of the observed data when the inner parameter is equal to the reference value (1)

eObs = Phi * sol.eObs;


