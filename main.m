clear 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For reproducibility
rng(19250);

% Folder with Matlab functions
addpath('functions');

% Folder and filename for saving results and plots 
savFolder = "results/";
fNameOut = "results";
fNameTex = "table";

% Global numerical settings
nReps = 100;    % number of independently generated data sets to analyse for each model
nMesh = 21;     % number of points in parameter mesh for profiles

varyParamsFlag = 1;    % If set to 0, each rep will regenerate data using the *same* model parameters; if set                                                   to 1, each rep will randomly draw target parameter values and then regenerate data

modelLbl = ["LV", "SEIR", "RAD_PDE"]';                      % labels for models - can include "LV", "SEIR", "RAD_PDE"
modelLong = ["Predator-prey", "SEIR", "Adv. diff."]';       % labels to use in latex tables
% modelLbl = "SEIR";
% modelLong = modelLbl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





nModels = length(modelLbl);

nCallsMLE_basic = zeros(nReps, nModels);
nCallsProfile_basic = zeros(nReps, nModels);
nCallsMLE_improved = zeros(nReps, nModels);
nCallsProfile_improved = zeros(nReps, nModels);
relErrBasic = zeros(nReps, nModels);
relErrImproved = zeros(nReps, nModels);


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

        [ThetaMLE, parMLE, solMLE, countMLE] = doMLE(mdl, obs);
        
        % Profiling
        [ThetaProfile, logLik, countProfile] = doProfiling(mdl, obs, ThetaMLE, nMesh);
        
           
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find MLE and profile each (non-optimised) parameter with structured inference method
        % NB variables with 'Improved" suffix relate to output from the structured inference method as opposed to the basic method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % MLE
        [ThetaMLEImproved, parMLEImproved, solMLEImproved, countMLEImproved] = doMLEImproved(mdl, obs);
        
        % Profiling    
        [ThetaProfileImproved, logLikImproved, countProfileImproved] = doProfilingImproved(mdl, obs, ThetaMLEImproved, nMesh);
        
        % Store results from this realisation in a structure array
        results(iRep, iModel).sol = sol;
        results(iRep, iModel).obs = obs;
        results(iRep, iModel).solMLE = solMLE;
        results(iRep, iModel).ThetaMLE = ThetaMLE;
        results(iRep, iModel).ThetaProfile = ThetaProfile;
        results(iRep, iModel).logLik = logLik;
        results(iRep, iModel).logLikNorm = logLik - max(logLik, [], 2);
        results(iRep, iModel).solMLEImproved = solMLEImproved;
        results(iRep, iModel).ThetaMLEImproved = ThetaMLEImproved;
        results(iRep, iModel).ThetaProfileImproved = ThetaProfileImproved;
        results(iRep, iModel).logLikImproved = logLikImproved;
        results(iRep, iModel).logLikImprovedNorm = logLikImproved - max(logLikImproved, [], 2);

        % Record some summary statistics for this model
        nCallsMLE_basic(iRep, iModel) = countMLE;
        nCallsProfile_basic(iRep, iModel) = sum(countProfile);
        nCallsMLE_improved(iRep, iModel) = countMLEImproved;
        nCallsProfile_improved(iRep, iModel) = sum(countProfileImproved);
        relErrBasic(iRep, iModel) = norm(ThetaMLE-mdl.ThetaTrue)/norm(mdl.ThetaTrue);
        relErrImproved(iRep, iModel) = norm(ThetaMLEImproved-mdl.ThetaTrue)/norm(mdl.ThetaTrue);
        
    end
end




%%

if varyParamsFlag == 0
    varyLbl = "_fixed";
else
    varyLbl = "_varied";
end

% Plotting (for a single realisation) for each model
iToPlot = 1;            % realisation number to plot
for iModel = 1:nModels
    % Specify model-specific functions and values here:
    if modelLbl(iModel) == "SEIR"
        mdl = specifyModelSEIR(0);
    elseif modelLbl(iModel) == "LV"
        mdl = specifyModelLV(0);
    elseif modelLbl(iModel) == "RAD_PDE"
        mdl = specifyModelRAD_PDE(0);
    end

    parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);
    plotGraphs(results(iToPlot, iModel), parsToProfile, mdl, modelLbl(iModel)+varyLbl, savFolder, iModel);
end

% Create output table and write latex table
totCallsBasic = nCallsMLE_basic + nCallsProfile_basic;
totCallsImproved = nCallsMLE_improved + nCallsProfile_improved;
repNumber = (1:nReps)';
outTab = table(repNumber, relErrBasic, relErrImproved, nCallsMLE_basic, nCallsProfile_basic, totCallsBasic, nCallsMLE_improved, nCallsProfile_improved, totCallsImproved);

% Write latex for results table
writeLatex(outTab, modelLong, savFolder+fNameTex+varyLbl+".tex");


% Save results
save(savFolder+fNameOut+varyLbl+".mat");



