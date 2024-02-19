# structured-inference

 Structured methods for parameter inference and uncertainty quantification for mechanistic models in the life sciences.


 # How to use this repository

The root directory contains the top-level Matlab scripts *main.m* and *fitUserData.m*.

The sub-directory /models/ contains model-specific functions that define the models studied in the article and the sub-directory /functions/ contains other functions called by the main script. 

Running *main.m* will run the basic and structured methods on the three case studies described in the article. A results file, graphs and summary latex table will be saved in /results/.

Running *fitUserData.m* will run the basic and structured method once on a user-supplied dataset and specified model. By default, an example dataset is provided for the SEIR model. A results file and graphs will be saved in /results/.




# Global settings

Global settings are specified at the beginning of *main.m*. These may be adjusted from the default values:
- nReps = 100 - number of independently generated data sets to analyse for each model.
 - nMesh = 41 - number of mesh points in each parameter profile.
 - Alpha = 0.05 - significance level for constructing confidence intervals from likelihood profiles.
 - varyParamsFlag = 0 - set to 0 to regenerate data using the *same* model parameters each rep; set to 1 to randomly draw moel parameters before generating data each rep.
 
# Running the code on a user-supplied model

By default, the model runs on the three models covered in the article, which are identified by the labels "LV", "SEIR" and "RAD_PDE" respectively.

To run the code on a user-supplied model, you need to choose a label for the model, say "LABEL", and place the following function files in the sub-directory /models/:
- *specifyModelLABEL.m*
- *getParLABEL.m*
- *solveModelLABEL.m*
- *transformSolutionLABEL.m* (if the transformation for the structured method is something other than a linear scaling)

The inputs and outputs that are required for each of these functions are described below (see supplied files for an example in each case).

## specifyModel

**Inputs:** varyParamsFlag - a flag that equals 0 if fixed parameters are to be used (or model is being fitted to user-supplied data -- see below) or 1 if parameters are to be randomised with each call.

**Outputs:** mdl - a structure that has specific fields defining model properties.

The required fields of mdl are:
- getPar - a handle to the function getParLABEL()
- solveModel - a handle to the function solveModel()
- transformSolution - handle to a function that transforms a known solution for a reference value of the inner parameter(s) to the solution for any other valid value. If the transformation is a linear scaling, use @transformSolutionMultiply, otherwise a user-supplied transformation function must be provided.
- xLbl - string for labelling the horizontal axis of graphs of model output.
- yLbl - string for labelling the vertical axis of graphs of model output.
- parLbl - string array of labels for the target parameters for inference.
- ThetaTrue - corresponding array of the true values of the target parameters (or the mean values in the case of parameter randomisation).
- Theta0 - initial condition for the parameter values to use for the optimisation routine.
- lb - lower bound for the target parameter values
- ub - upper bound for the target parameter values
- profileRange - profile intervals for each parameter will be from (1-profileRange)*m to (1+profileRange)*m where m is the value of that parameter at the MLE.
- parsToOptimise - indices defining which parameter(s) in mdl.parLbl are inner parameters.
- runningValues - values of the inner parameter(s) to use when solving the forward model.
- gridSearchFlag - set to 1 to do a preliminary grid search of the inner parameter if the default starting value returns NaN (only works for a single inner parameter).
- options - an optimisation options structure for *fmincon* as returned by Matlab's *optimoptions* - default code uses the interior-point algorithm and turns *fmincon* display off.
- GSFlag - set to 1 to do a global search for the MLE or 0 to do a local search (i.e. *fmincon* only).
- gs - (if GSFlag is set to 1) a GlobalSearch object as returned by Matlab's *GlobalSearch* - default code specifies a maximum time of 1000 seconds and turns *GlobalSearch* display off.







 
