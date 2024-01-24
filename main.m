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
fNameOut = "results.mat";
fNameTex = "table.tex";

nReps = 100;    % number of independently generated data sets to analyse for each model
nMesh = 21;     % number of points in parameter mesh for profiles

modelLbl = ["SEIR", "LV", "RAD_PDE"]';        % labels for models - can include "SEIR", "LV", "RAD_PDE"
modelLong = ["SEIR", "Predator-prey", "Adv. diff."]';        % labels for models - can include "SEIR", "LV", "RAD_PDE"

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


    % Specify model-specific functions and values here:
    if modelLbl(iModel) == "SEIR"
        mdl = specifyModelSEIR();
    elseif modelLbl(iModel) == "LV"
        mdl = specifyModelLV();
    elseif modelLbl(iModel) == "RAD_PDE"
        mdl = specifyModelRAD_PDE();
    else
        fprintf('Warning: model %s not found\n', modelLbl(iModel) )
    end
   
    mdl.options.Display = 'off';
    parfor iRep = 1:nReps
        fprintf('   rep %i/%i\n', iRep, nReps)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Generate data from forward model
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
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
        results(iRep, iModel).solMLEImproved = solMLEImproved;
        results(iRep, iModel).ThetaMLEImproved = ThetaMLEImproved;
        results(iRep, iModel).ThetaProfileImproved = ThetaProfileImproved;
        results(iRep, iModel).logLikImproved = logLikImproved;
    
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

% Plotting (for a single realisation) for each model
iToPlot = 1;            % realisation number to plot
for iModel = 1:nModels
    % Specify model-specific functions and values here:
    if modelLbl(iModel) == "SEIR"
        mdl = specifyModelSEIR();
    elseif modelLbl(iModel) == "LV"
        mdl = specifyModelLV();
    elseif modelLbl(iModel) == "RAD_PDE"
        mdl = specifyModelRAD_PDE();
    end

    parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);
    plotGraphs(results(iToPlot, iModel), parsToProfile, mdl, modelLbl(iModel), savFolder, iModel);
end

% Create output table and write latex table
totCallsBasic = nCallsMLE_basic + nCallsProfile_basic;
totCallsImproved = nCallsMLE_improved + nCallsProfile_improved;
repNumber = (1:nReps)';
outTab = table(repNumber, relErrBasic, relErrImproved, nCallsMLE_basic, nCallsProfile_basic, totCallsBasic, nCallsMLE_improved, nCallsProfile_improved, totCallsImproved);

% Write latex for results table
writeLatex(outTab, modelLong, savFolder+fNameTex);


% Save results
save(savFolder+fNameOut);



