clear 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOP-LEVEL SCRIPT TO REPRODUCE THE RESULTS IN THE ARTICLE
% Structured methods for parameter inference and uncertainty quantification for mechanistic models in the life sciences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For reproducibility
rng(19250);

% Folder with Matlab functions
addpath('functions', 'models');


% Folder and filename for saving results and plots 
savFolder = "results/";
fNameOut = "results";
fNameTex = "table";

% Global numerical settings
nReps = 100;    % number of independently generated data sets to analyse for each model
nMesh = 41;     % number of points in parameter mesh for profiles
Alpha = 0.05;   % significance level for calculating CIs

varyParamsFlag = 0;    % If set to 0, each rep will regenerate data using the *same* model parameters; if set                                                   to 1, each rep will randomly draw target parameter values and then regenerate data

modelLbl = ["LV", "SEIR", "RAD_PDE"]';                                 % string array of labels for models - can include "LV", "SEIR", "RAD_PDE"
getModel = {@specifyModelLV, @specifyModelSEIR, @specifyModelRAD_PDE}; % cell array of corresponding function handles to the model-specific function `specifyModelXXXX()`
modelLong = ["Predator-prey", "SEIR", "Adv. diff."]';                  % string array of corresponding labels to use in latex tables





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Number of models to be run
nModels = length(modelLbl);

% Initialise storage arrays
nCallsMLE_basic = zeros(nReps, nModels);
nCallsProfile_basic = zeros(nReps, nModels);
nCallsMLE_Structured = zeros(nReps, nModels);
nCallsProfile_Structured = zeros(nReps, nModels);
relErrBasic = zeros(nReps, nModels);
relErrStructured = zeros(nReps, nModels);


% Loop through each model
for iModel = 1:nModels
    fprintf('\nModel %s\n', modelLbl(iModel))

  
    % Use a parallel loop to apply the methods to a series of independently generated synthetic datasets
    parfor iRep = 1:nReps
        fprintf('   rep %i/%i\n', iRep, nReps)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Generate synthetic data from forward model
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        mdl = getModel{iModel}(varyParamsFlag);     % if varyParamsFlag == 0 this will always return the same values in mdl.ThetaTrue, if varyParamsFlag == 1 it will return different mdl.ThetaTrue for each rep
        par = mdl.getPar(mdl.ThetaTrue);    % get a structure containing model parameter values
        sol = mdl.solveModel(par);          % solve forward model to find the expected values of the observed data
        obs = genObs(sol.eObs, par);        % generate observed data by applying the noise model specified in par.noiseModel 

        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BASIC METHOD: Find MLE and profile each parameter using basic method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % MLE
        [ThetaMLE, parMLE, solMLE, LLMLE, countMLE] = doMLE(mdl, obs);
        
        % Profiling
       [ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, LLMLE, nMesh);
       logLikNorm = logLik - LLMLE;     % calculate normalised log-likelihood

       % Calculate CIs from profile results
        CIs = findCIs(ThetaProfile, logLikNorm, Alpha);
           
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  STRUCTURED METHOD: Find MLE and profile each (outer) parameter with structured inference method
        % NB variables with 'Structured" suffix relate to output from the structured inference method as opposed to the basic method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % MLE
        [ThetaMLEStructured, parMLEStructured, solMLEStructured, LLMLEStructured, countMLEStructured] = doMLEStructured(mdl, obs);
        
        % Profiling    
        [ThetaProfileStructured, logLikStructured, countProfileStructured] = doProfilingStructured(mdl, obs, ThetaMLEStructured, LLMLEStructured, nMesh);
        logLikStructuredNorm = logLikStructured - LLMLEStructured;      % calculate normalised log-likelihood

        % Calculate CIs from profile results
        CIsStructured = findCIs(ThetaProfileStructured, logLikNormStructured, Alpha);
        
        % Store results from this realisation in a structure array
        results(iRep, iModel).ThetaTrue = mdl.ThetaTrue;
        results(iRep, iModel).sol = sol;
        results(iRep, iModel).obs = obs;
        results(iRep, iModel).solMLE = solMLE;
        results(iRep, iModel).LLMLE = LLMLE;
        results(iRep, iModel).ThetaMLE = ThetaMLE;
        results(iRep, iModel).ThetaProfile = ThetaProfile;
        results(iRep, iModel).logLik = logLik;
        results(iRep, iModel).logLikNorm = logLikNorm;
        results(iRep, iModel).CIs = CIs;
        results(iRep, iModel).covFlag = mdl.ThetaTrue >= CIs(:, 1) & mdl.ThetaTrue <= CIs(:, 2);
        results(iRep, iModel).solMLEStructured = solMLEStructured;
        results(iRep, iModel).LLMLEStructured = LLMLEStructured;
        results(iRep, iModel).ThetaMLEStructured = ThetaMLEStructured;
        results(iRep, iModel).ThetaProfileStructured = ThetaProfileStructured;
        results(iRep, iModel).logLikStructured = logLikStructured;
        results(iRep, iModel).logLikStructuredNorm = logLikStructuredNorm;
        results(iRep, iModel).CIsStructured = CIsStructured;
        parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);      % parsToProfile contains the indices of the outer parameters; parsToOptimise contains the indices of the inner parameters
        results(iRep, iModel).covFlagStructured = mdl.ThetaTrue(parsToProfile) >= CIsStructured(:, 1) & mdl.ThetaTrue(parsToProfile) <= CIsStructured(:, 2);


        % Record some summary statistics for this model
        nCallsMLE_basic(iRep, iModel) = countMLE;                                                     % number of calls to `solveModel` needed to calculate the MLE using the basic method
        nCallsProfile_basic(iRep, iModel) = sum(countProfile);                                        % number of calls to `solveModel` needed to calculate the profiles using the basic method
        nCallsMLE_Structured(iRep, iModel) = countMLEStructured;                                      % number of calls to `solveModel` needed to calculate the MLE using the structured method
        nCallsProfile_Structured(iRep, iModel) = sum(countProfileStructured);                         % number of calls to `solveModel` needed to calculate the profiles using the structured method
        relErrBasic(iRep, iModel) = norm(ThetaMLE-mdl.ThetaTrue)/norm(mdl.ThetaTrue);                 % relative error in the MLE using the basic method
        relErrStructured(iRep, iModel) = norm(ThetaMLEStructured-mdl.ThetaTrue)/norm(mdl.ThetaTrue);  % relative error in the MLE using the structured method
        
    end

    % To check coverage evaluate the likelihood function for the 1st rep
    % at the MLE from the other reps
    mdl(iModel) = getModel{iModel}(0); 
    for iRep = 2:nReps
        par = mdl(iModel).getPar(results(iRep, iModel).ThetaMLE);
        results(iRep, iModel).LL1 = LLfunc( results(iRep, iModel).solMLE.eObs, results(1, iModel).obs, par);
        par = mdl(iModel).getPar(results(iRep, iModel).ThetaMLEStructured);
        results(iRep, iModel).LL1Structured = LLfunc( results(iRep, iModel).solMLEStructured.eObs, results(1, iModel).obs, par);
    end
end




%%
% Write outputs

% Filename suffic to indicate whether parameters are fixed or varied between reps
if varyParamsFlag == 0
    varyLbl = "_fixed";
else
    varyLbl = "_varied_fixIC";
end


% Plot graphs for (a single realisation of) each model
iToPlot = 1;            % realisation number to plot
for iModel = 1:nModels
    parsToProfile = setdiff(1:length(mdl(iModel).Theta0), mdl(iModel).parsToOptimise);
    plotGraphs(results(iToPlot, iModel), parsToProfile, Alpha, mdl(iModel), modelLbl(iModel)+varyLbl, savFolder, iModel);
end

% Create output table and write latex table
totCallsBasic = nCallsMLE_basic + nCallsProfile_basic;
totCallsStructured = nCallsMLE_Structured + nCallsProfile_Structured;
repNumber = (1:nReps)';
outTab = table(repNumber, relErrBasic, relErrStructured, nCallsMLE_basic, nCallsProfile_basic, totCallsBasic, nCallsMLE_Structured, nCallsProfile_Structured, totCallsStructured);

% Write latex for results tables
writeLatexCombined(mdl, outTab, results, modelLong, savFolder+fNameTex+varyLbl+".tex");

% Save results
save(savFolder+fNameOut+varyLbl+".mat");



