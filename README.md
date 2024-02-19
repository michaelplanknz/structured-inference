# structured-inference

 Structured methods for parameter inference and uncertainty quantification for mechanistic models in the life sciences.


 # How to use this repository

The root directory contains the top-level Matlab scripts *main.m* and *fitUserData.m$.

The sub-directory /models/ contains model-specific functions that define the models studied in the article and the sub-directory /functions/ contains other functions called by the main script. 

Running *main.m* will run the basic and structured methods on the three case studies described in the article. A results file, graphs and summary latex table will be saved in /results/.

Running *fitUserData.* will 



# Global settings

Global settings are specified at the beginning of *main.m*. These may be adjusted from the default values:
- nReps = 100 - number of independently generated data sets to analyse for each model.
 - nMesh = 41 - number of mesh points in each parameter profile.
 - Alpha = 0.05 - significance level for constructing confidence intervals from likelihood profiles.
 - varyParamsFlag = 0 - set to 0 to regenerate data using the *same* model parameters each rep; set to 1 to randomly draw moel parameters before generating data each rep.
 
# Running the code on a user-supplied model

By default, the model runs on the three models covered in the article, which are identified by the labels "LV", "SEIR" and "RAD_PDE" respectively.

To run the code on a user-supplied model, you need to choose a label for the model, say "LABEL", and place the following function files in the sub-directory /models/:
- specifyModelLABEL.m
- getParLABEL.m
- solveModelLABEL.m
- transformSolutionLABEL.m (if the transformation for the structured method is something other than a linear scaling)

The inputs and outputs that are required for each of these functions are described below.

## specifyModel










 
