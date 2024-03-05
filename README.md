# Structured methods for parameter inference and uncertainty quantification for mechanistic models in the life sciences

This repository provides code to accompany the article "Structured methods for parameter inference and uncertainty quantification for mechanistic models in the life sciences" by Michael J. Plank and Matthew J. Simpson.

A preprint of the article is available at https://arxiv.org/abs/2403.01678 
Results in this version were generated using the commit tagged `v1.0`.


 # How to use this repository

The root directory contains the top-level Matlab scripts `main.m` and `fitUserData.m`.

The sub-directory /models/ contains model-specific functions (see [section on user-supplied models](#user-supplied-models)) that define the models studied in the article and the sub-directory /functions/ contains other functions called by the main script. 

Running `main.m` will run the basic and structured methods on the three case studies described in the article. A results file, graphs and summary latex table will be saved in /results/.

Running `fitUserData.m` will run the basic and structured method on a user-supplied dataset (see [section on user-supplied data](#user-supplied-data)) and specified model. By default, an example dataset is provided for the SEIR model (`data/SEIR_data.csv`). A results file and graphs will be saved in /results/.

The sections below describe how to customise the code to use different settings or for use with user-supplied models and data.


# Global settings

Global settings are specified at the beginning of `main.m`. These may be adjusted from the default values:
- nReps = 100 - number of independently generated data sets to analyse for each model.
- nMesh = 41 - number of mesh points in each parameter profile.
- Alpha = 0.05 - significance level for constructing confidence intervals from likelihood profiles.
- varyParamsFlag = 0 - set to 0 to regenerate data using the *same* model parameters each rep; set to 1 to randomly draw moel parameters before generating data each rep.
 
# User-supplied models

By default, the model runs on the three models covered in the article, which are identified by the labels "LV", "SEIR" and "RAD_PDE" respectively.

To run the code on a user-supplied model, you need to choose a label for the model, say "LABEL", and place the following function files in the sub-directory /models/:
- `specifyModelLABEL.m`
- `getParLABEL.m`
- `solveModelLABEL.m`
- `transformSolutionLABEL.m` (if the transformation for the structured method is something other than a linear scaling)

The inputs and outputs that are required for each of these functions are described below (see supplied files for an example in each case).

Before running `main.m`, ensure the cell array variable *getModel* contains the funtion handle *@specifyModelLABEL*. If more than one model is being run, *getModel* is a cell array (of the same dimensions as modelLbl) containing function handles to each of the models being run.

## specifyModel

**Inputs:** varyParamsFlag - a flag that equals 0 if fixed parameters are to be used (or model is being fitted to user-supplied data -- see below) or 1 if parameters are to be randomised with each call.

**Outputs:** mdl - a structure that has specific fields defining model properties.

The required fields of mdl are:
- mdl.getPar - a handle to the function `getParLABEL`
- mdl.solveModel - a handle to the function `solveModelLABEL`
- mdl.transformSolution - handle to a function that transforms a known solution for a reference value of the inner parameter(s) to the solution for any other valid value. If the transformation is a linear scaling, use `@transformSolutionMultiply`, otherwise a user-supplied transformation function must be provided.
- mdl.xLbl - string for labelling the horizontal axis of graphs of model output.
- mdl.yLbl - string for labelling the vertical axis of graphs of model output.
- mdl.parLbl - string array of labels for the target parameters for inference.
- mdl.ThetaTrue - corresponding vector of the true values of the target parameters (or the mean values in the case of parameter randomisation).
- mdl.Theta0 - vector of initial conditions for the parameter values to use for the optimisation routine.
- mdl.lb - vector of lower bounds for the target parameter values
- mdl.ub - vector of upper bounds for the target parameter values
- mdl.profileRange - vector of profile ranges - the profile interval for each parameter will be from (1-profileRange)*m to (1+profileRange)*m where m is the value of that parameter at the MLE.
- mdl.parsToOptimise - indices defining which parameter(s) in mdl.parLbl are inner parameters.
- mdl.runningValues - reference value(s) of the inner parameter(s) to use when solving the forward model.
- mdl.gridSearchFlag - set to 1 to do a preliminary grid search of the inner parameter if the default starting value returns NaN (only works for a single inner parameter).
- mdl.options - an optimisation options structure for *fmincon* as returned by Matlab's *optimoptions* - default code uses the interior-point algorithm and turns *fmincon* display off.
- mdl.GSFlag - set to 1 to do a global search for the MLE or 0 to do a local search (i.e. *fmincon* only).
- mdl.gs - (if GSFlag is set to 1) a GlobalSearch object as returned by Matlab's *GlobalSearch* - default code specifies a maximum time of 1000 seconds and turns *GlobalSearch* display off.

## getPar

**Inputs:** Theta - a vector of values for the *target* parameters specified in the `specifyModelLABEL` function.

**Outputs:** par - a structure that has fields providing values of all parameters of the forward model and the noise model.

Note: `getPar` should copy the values in the input vector Theta into the appropiate fields of the output structure par (see supplied code for examples).

The required fields of par are:
- Any fields that are accessed by `solveModelLABEL` in order to solve the forward model.
- par.noiseModel - a string specifying the noise model to use. This can be one of the built-in noise models (see table below). Alternatively, you may specify a different noise model by adding the relevant likelihood function to `LLfunc` in terms of vectors representing the expected and observed data, and the relevant noise generation process to `genObs`. 
- Any noise-related fields that are accessed by the likelihood function `LLfunc` or the noise generation functoin `genObs` (see table below).


| Noise model label  | Noise model description | Fields required |
| ------------- | ------------- | ------------- |
| norm_SD_const  | Gaussian noise with constant std. dev. | par.obsSD (std. dev.)  |
|                |                                        | par.obsIntFlag (set to 1 to round observations to the nearest integer, 0 otherwise) |
| norm_SD_propMean  | Gaussian noise with std. dev. proportional to mean | par.obsSD (constant of proportionality for std. dev.)  |
|                |                                        | par.obsIntFlag (set to 1 to round observations to the nearest integer, 0 otherwise) |
| poisson        | Poisson  |  |
| negbin | Negative binomial | par.obsK (negative binomial dispersion factor) |


## solveModel

**Inputs:** par - parameter structure as returned by `getParLABEL`.

**Outputs:** sol - a structure containing the solution of the forward model for thr specified parameter values.

The required fields of sol are:
- sol.eObs - a column vector or matrix containing the expected value of the observed data under the forward model solution at the specified parameter values.
- sol.xPlot - column vector containing corresponding coordinate values for the horizontal axis of plots of the model solution (typically represnenting either time or space), such that each row of eObs is the model solution at the corresponding value of xPlot for time or space. 


## transformSolution

**Inputs:** Phi - the value of the inner parameter(s) at which the solution is required.
            sol - a solution structure  (as returned by `solveModelLABEL`) containing a field sol.eObs for the array of expected values of the observed data, under the reference value for the inner parameter(s).

**Outputs:** eObs - a corresponding array of the same size as the input array sol.eObs of expected values under the specified value (Phi) of inner parameter(s).

 
# User-supplied data

To run the code on a user-supplied dataset:
- Ensure the model specification functions are supplied in the /models/ sub-directiory as described [above](#user-supplied-models).
- Set the variable getModel in `fitUserData.m` the the appropriate model specification function of the form `specifyModelLABEL`.
- Save the data as a CSV file in the /data/ sub-directory. This should be in the same form (same array dimensions, same time/space observation coordinates) as the output returned by the `solveModelLABEL` function in sol.eObs.
- Set the variable dataFName in `fitUserData.m` to the appropriate file name containing the data.
- Adjust the [global settings](#global-settings) in `fitUserData.m` as required (note nReps and varyParamsFlag are not needed in this case as the method is only being run on a single dataset rather than multiple synthetically generated datasets).
- Run the script `fitUserData.m`.

This will generate profile likelihood graphs for the target parameters using both the basic and structured methods. The numerical results will be saved in a file '/results/results_userdata.mat'. This file contains a structure called results with the following fields:
- results.solMLE - model solution output at the MLE parameter values.
- results.LLMLE - log likelihood evaluated at the MLE.
- results.ThetaMLE - vector of parameter values at the MLE.
- results.ThetaProfile - array of parameter values profiled, with each row of ThetaProfile containing the range of values in the profiling interval for one of the target parameters.
- results.logLik - corresponding array of log likelihood values at the profiling points in ThetaProfile.
- results.logLikNorm - normalised version of logLik (i.e. difference between logLik and LLMLE).
- results.CIs - (1-Alpha)% confidence intervals for each profiled parameter
- all of the above with the field name suffixed with *Structured* for corresponding results from the structured method (NB for the fields containing the profiling results, only *outer* parameters are profiled, so the arrays will have k fewer rows than for the basic method, where k is the number of inner parameters). 
  
