clear 
close all

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

modelLbl = ["LV", "SEIR", "RAD_PDE"]';                      % labels for models - can include "LV", "SEIR", "RAD_PDE"
modelLong = ["Predator-prey", "SEIR", "Adv. diff."]';       % labels to use in latex tables
% modelLbl = "LV";
% modelLong = modelLbl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





nModels = length(modelLbl);

nCallsMLE_basic = zeros(nReps, nModels);
nCallsProfile_basic = zeros(nReps, nModels);
nCallsMLE_Structured = zeros(nReps, nModels);
nCallsProfile_Structured = zeros(nReps, nModels);
relErrBasic = zeros(nReps, nModels);
relErrStructured = zeros(nReps, nModels);

thresholdValue = -0.5*chi2inv(1-Alpha, 1);

for iModel = 1:nModels
    fprintf('\nModel %s\n', modelLbl(iModel))

    % Specify the model-specific functions here:
    if modelLbl(iModel) == "SEIR"
        getModel = @specifyModelSEIR;
    elseif modelLbl(iModel) == "LV"
        getModel = @specifyModelLV;
    elseif modelLbl(iModel) == "RAD_PDE"
        getModel = @specifyModelRAD_PDE;
    else
        error('Warning: model %s not found\n', modelLbl(iModel) );
    end
   

    parfor iRep = 1:nReps
        fprintf('   rep %i/%i\n', iRep, nReps)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Generate data from forward model
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % rng(iRep*1000+421);
         
        mdl = getModel(varyParamsFlag);     % if varyParamsFlag == 0 this will always return the same values in mdl.ThetaTrue, if varyParamsFlag == 1 it will return different mdl.ThetaTrue for each rep
        par = mdl.getPar(mdl.ThetaTrue);
        sol = mdl.solveModel(par);
        obs = genObs(sol.eObs, par);

        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find MLE and profile each parameter using basic method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % MLE

        [ThetaMLE, parMLE, solMLE, LLMLE, countMLE] = doMLE(mdl, obs);
        
        % Profiling
       [ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, LLMLE, nMesh);
       logLikNorm = logLik - max(logLik, [], 2);

       % Calculate CIs from profile results
        CIs = findCIs(ThetaProfile, logLikNorm, thresholdValue);
           
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find MLE and profile each (non-optimised) parameter with structured inference method
        % NB variables with 'Structured" suffix relate to output from the structured inference method as opposed to the basic method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % MLE
        [ThetaMLEStructured, parMLEStructured, solMLEStructured, LLMLEStructured, countMLEStructured] = doMLEStructured(mdl, obs);
        
        % Profiling    
        [ThetaProfileStructured, logLikStructured, countProfileStructured] = doProfilingStructured(mdl, obs, ThetaMLEStructured, LLMLEStructured, nMesh);
        logLikNormStructured = logLikStructured - max(logLikStructured, [], 2);

        % Calculate CIs from profile results
        CIsStructured = findCIs(ThetaProfileStructured, logLikNormStructured, thresholdValue);
        
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
        results(iRep, iModel).logLikStructuredNorm = logLikStructured - max(logLikStructured, [], 2);
        results(iRep, iModel).CIsStructured = CIsStructured;
        parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);
        results(iRep, iModel).covFlagStructured = mdl.ThetaTrue(parsToProfile) >= CIsStructured(:, 1) & mdl.ThetaTrue(parsToProfile) <= CIsStructured(:, 2);


        % Record some summary statistics for this model
        nCallsMLE_basic(iRep, iModel) = countMLE;
        nCallsProfile_basic(iRep, iModel) = sum(countProfile);
        nCallsMLE_Structured(iRep, iModel) = countMLEStructured;
        nCallsProfile_Structured(iRep, iModel) = sum(countProfileStructured);
        relErrBasic(iRep, iModel) = norm(ThetaMLE-mdl.ThetaTrue)/norm(mdl.ThetaTrue);
        relErrStructured(iRep, iModel) = norm(ThetaMLEStructured-mdl.ThetaTrue)/norm(mdl.ThetaTrue);
        
    end

    % To check coverage evaluate the likelihood function for the 1st rep
    % at the MLE from the other reps
    mdl = getModel(0); 
    for iRep = 2:nReps
        par = mdl.getPar(results(iRep, iModel).ThetaMLE);
        results(iRep, iModel).LL1 = LLfunc( results(iRep, iModel).solMLE.eObs, results(1, iModel).obs, par);
        par = mdl.getPar(results(iRep, iModel).ThetaMLEStructured);
        results(iRep, iModel).LL1Structured = LLfunc( results(iRep, iModel).solMLEStructured.eObs, results(1, iModel).obs, par);
    end
end




%%
% Write outputs

if varyParamsFlag == 0
    varyLbl = "_fixed";
else
    varyLbl = "_varied_fixIC";
end

% Plotting (a single realisation) for each model
iToPlot = 1;            % realisation number to plot
for iModel = 1:nModels
    % Specify model-specific functions and values here:
    if modelLbl(iModel) == "SEIR"
        mdl(iModel) = specifyModelSEIR(0);
    elseif modelLbl(iModel) == "LV"
        mdl(iModel) = specifyModelLV(0);
    elseif modelLbl(iModel) == "RAD_PDE"
        mdl(iModel) = specifyModelRAD_PDE(0);
    end

    parsToProfile = setdiff(1:length(mdl(iModel).Theta0), mdl(iModel).parsToOptimise);
    plotGraphs(results(iToPlot, iModel), parsToProfile, thresholdValue, mdl(iModel), modelLbl(iModel)+varyLbl, savFolder, iModel);
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



