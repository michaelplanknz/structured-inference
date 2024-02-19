function writeLatexCombined(mdl, outTab, results, modelLbl, fName)

nModels = length(mdl);

qt = [0.25; 0.5; 0.75];

% For each statistic of interest, create an m x n array whose m rows are the m quantile points specified in qt and whose n columns are the n different models
relErrBasic = 100*quantile(outTab.relErrBasic, qt);
relErrImproved = 100*quantile(outTab.relErrImproved, qt);
nCallsMLE_basic = round(quantile(outTab.nCallsMLE_basic, qt));
nCallsMLE_improved = round(quantile(outTab.nCallsMLE_improved, qt));
nCallsProfile_basic = round(quantile(outTab.nCallsProfile_basic, qt));
nCallsProfile_improved = round(quantile(outTab.nCallsProfile_improved, qt));
totCallsBasic = round(quantile(outTab.totCallsBasic, qt));
totCallsImproved = round(quantile(outTab.totCallsImproved, qt));
improvementMLE = 100*quantile(1 - outTab.nCallsMLE_improved./outTab.nCallsMLE_basic, qt );
improvementProfile = 100*quantile(1 - outTab.nCallsProfile_improved./outTab.nCallsProfile_basic, qt );
improvementTotal = 100*quantile(1 - outTab.totCallsImproved./outTab.totCallsBasic, qt );

fid = fopen(fName, 'w');

fprintf(fid, '\\begin{tabular}{lllll} \n');
fprintf(fid, '\\hline  \n');

fprintf(fid, '& & \\multicolumn{2}{l}{\\bf Relative error (\\%%)} & \\\\ \n');
fprintf(fid, ' & & Basic & Structured & \\\\ \n'); 
for iModel = 1:nModels
    fprintf(fid, '%s && %.1f [%.1f, %.1f] & %.1f [%.1f, %.1f] & \\\\ \n', modelLbl(iModel), relErrBasic(2, iModel), relErrBasic(1, iModel), relErrBasic(3, iModel), relErrImproved(2, iModel), relErrImproved(1, iModel), relErrImproved(3, iModel) );
end
fprintf(fid, '\\hline  \n');

fprintf(fid, '& & \\multicolumn{2}{l}{\\bf 95\\%% CI coverage} & \\\\ \n');
fprintf(fid, '  && Basic & Structured \\\\ \n'); 
for iModel = 1:nModels
    fprintf(fid, '%s ', modelLbl(iModel));
    nPars = length(results(1, iModel).covFlag);
    % Calculate the proportion of realisations for which the CI contained true value of each parameter (under basic and structured methods)
    pCov = mean(cat(2, results(:, iModel).covFlag), 2);
    pCovImproved = mean(cat(2, results(:, iModel).covFlagImproved), 2);
    for iPar = 1:nPars
        jParProfile = 1;
        fprintf(fid, '& $%s$ & %.0f\\%%', mdl(iModel).parLbl(iPar), 100*pCov(iPar));
        if ismember(iPar, mdl(iModel).parsToOptimise)
            fprintf(fid, ' & - \\\\ \n');
        else
            fprintf(fid, ' & %.0f\\%%  \\\\ \n', 100*pCovImproved(jParProfile) );
            jParProfile = jParProfile+1;
        end
    end

end
fprintf(fid, '\\hline  \n');



fprintf(fid, '&& \\multicolumn{3}{l}{\\bf Function calls (MLE) } \\\\ \n');
fprintf(fid, '  && Basic & Structured & Improvement (\\%%) \\\\ \n'); 
for iModel = 1:nModels
  fprintf(fid, '%s && %d [%d, %d] & %d [%d, %d]  & %.1f [%.1f, %.1f] \\\\ \n',  modelLbl(iModel), nCallsMLE_basic(2, iModel), nCallsMLE_basic(1, iModel), nCallsMLE_basic(3, iModel), nCallsMLE_improved(2, iModel), nCallsMLE_improved(1, iModel), nCallsMLE_improved(3, iModel), improvementMLE(2, iModel), improvementMLE(1, iModel), improvementMLE(3, iModel) );
end
fprintf(fid, '\\hline  \n');



fprintf(fid, '&& \\multicolumn{3}{l}{\\bf Function calls (profiles) } \\\\ \n');
fprintf(fid, '  && Basic & Structured & Improvement (\\%%) \\\\ \n'); 
for iModel = 1:length(modelLbl)
  fprintf(fid, '%s && %d [%d, %d] & %d [%d, %d]  & %.1f [%.1f, %.1f] \\\\ \n',  modelLbl(iModel), nCallsProfile_basic(2, iModel), nCallsProfile_basic(1, iModel), nCallsProfile_basic(3, iModel), nCallsProfile_improved(2, iModel), nCallsProfile_improved(1, iModel), nCallsProfile_improved(3, iModel), improvementProfile(2, iModel), improvementProfile(1, iModel), improvementProfile(3, iModel) );
end
fprintf(fid, '\\hline  \n');



fprintf(fid, '&& \\multicolumn{3}{l}{\\bf Function calls (total) } \\\\ \n');
fprintf(fid, '  && Basic & Structured & Improvement (\\%%) \\\\ \n'); 
for iModel = 1:nModels
  fprintf(fid, '%s && %d [%d, %d] & %d [%d, %d]  & %.1f [%.1f, %.1f] \\\\ \n',  modelLbl(iModel), totCallsBasic(2, iModel), totCallsBasic(1, iModel), totCallsBasic(3, iModel), totCallsImproved(2, iModel), totCallsImproved(1, iModel), totCallsImproved(3, iModel), improvementTotal(2, iModel), improvementTotal(1, iModel), improvementTotal(3, iModel) );
end
fprintf(fid, '\\hline  \n');

fprintf(fid, '\\end{tabular} \n');


fclose(fid);

