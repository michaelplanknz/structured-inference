function writeLatexCombined(mdl, outTab, results, modelLbl, fName)

nModels = length(mdl);

qt = [0.25; 0.5; 0.75];

% For each statistic of interest, create an m x n array whose m rows are the m quantile points specified in qt and whose n columns are the n different models
relErrBasic = 100*quantile(outTab.relErrBasic, qt);
relErrStructured = 100*quantile(outTab.relErrStructured, qt);
nCallsMLE_basic = round(quantile(outTab.nCallsMLE_basic, qt));
nCallsMLE_Structured = round(quantile(outTab.nCallsMLE_Structured, qt));
nCallsProfile_basic = round(quantile(outTab.nCallsProfile_basic, qt));
nCallsProfile_Structured = round(quantile(outTab.nCallsProfile_Structured, qt));
totCallsBasic = round(quantile(outTab.totCallsBasic, qt));
totCallsStructured = round(quantile(outTab.totCallsStructured, qt));
improvementMLE = 100*quantile(1 - outTab.nCallsMLE_Structured./outTab.nCallsMLE_basic, qt );
improvementProfile = 100*quantile(1 - outTab.nCallsProfile_Structured./outTab.nCallsProfile_basic, qt );
improvementTotal = 100*quantile(1 - outTab.totCallsStructured./outTab.totCallsBasic, qt );

fid = fopen(fName, 'w');

fprintf(fid, '\\begin{tabular}{lllll} \n');
fprintf(fid, '\\hline  \n');

fprintf(fid, '& & \\multicolumn{2}{l}{\\bf Relative error (\\%%)} & \\\\ \n');
fprintf(fid, ' & & Basic & Structured & \\\\ \n'); 
for iModel = 1:nModels
    fprintf(fid, '%s && %.1f [%.1f, %.1f] & %.1f [%.1f, %.1f] & \\\\ \n', modelLbl(iModel), relErrBasic(2, iModel), relErrBasic(1, iModel), relErrBasic(3, iModel), relErrStructured(2, iModel), relErrStructured(1, iModel), relErrStructured(3, iModel) );
end
fprintf(fid, '\\hline  \n');

fprintf(fid, '& & \\multicolumn{2}{l}{\\bf 95\\%% CI coverage} & \\\\ \n');
fprintf(fid, '  && Basic & Structured \\\\ \n'); 
for iModel = 1:nModels
    fprintf(fid, '%s ', modelLbl(iModel));
    nPars = length(results(1, iModel).covFlag);
    % Calculate the proportion of realisations for which the CI contained true value of each parameter (under basic and structured methods)
    pCov = mean(cat(2, results(:, iModel).covFlag), 2);
    pCovStructured = mean(cat(2, results(:, iModel).covFlagStructured), 2);
    for iPar = 1:nPars
        jParProfile = 1;
        fprintf(fid, '& $%s$ & %.0f\\%%', mdl(iModel).parLbl(iPar), 100*pCov(iPar));
        if ismember(iPar, mdl(iModel).parsToOptimise)
            fprintf(fid, ' & - \\\\ \n');
        else
            fprintf(fid, ' & %.0f\\%%  \\\\ \n', 100*pCovStructured(jParProfile) );
            jParProfile = jParProfile+1;
        end
    end

end
fprintf(fid, '\\hline  \n');



fprintf(fid, '&& \\multicolumn{3}{l}{\\bf Function calls (MLE) } \\\\ \n');
fprintf(fid, '  && Basic & Structured & Improvement (\\%%) \\\\ \n'); 
for iModel = 1:nModels
  fprintf(fid, '%s && %d [%d, %d] & %d [%d, %d]  & %.1f [%.1f, %.1f] \\\\ \n',  modelLbl(iModel), nCallsMLE_basic(2, iModel), nCallsMLE_basic(1, iModel), nCallsMLE_basic(3, iModel), nCallsMLE_Structured(2, iModel), nCallsMLE_Structured(1, iModel), nCallsMLE_Structured(3, iModel), improvementMLE(2, iModel), improvementMLE(1, iModel), improvementMLE(3, iModel) );
end
fprintf(fid, '\\hline  \n');



fprintf(fid, '&& \\multicolumn{3}{l}{\\bf Function calls (profiles) } \\\\ \n');
fprintf(fid, '  && Basic & Structured & Improvement (\\%%) \\\\ \n'); 
for iModel = 1:length(modelLbl)
  fprintf(fid, '%s && %d [%d, %d] & %d [%d, %d]  & %.1f [%.1f, %.1f] \\\\ \n',  modelLbl(iModel), nCallsProfile_basic(2, iModel), nCallsProfile_basic(1, iModel), nCallsProfile_basic(3, iModel), nCallsProfile_Structured(2, iModel), nCallsProfile_Structured(1, iModel), nCallsProfile_Structured(3, iModel), improvementProfile(2, iModel), improvementProfile(1, iModel), improvementProfile(3, iModel) );
end
fprintf(fid, '\\hline  \n');



fprintf(fid, '&& \\multicolumn{3}{l}{\\bf Function calls (total) } \\\\ \n');
fprintf(fid, '  && Basic & Structured & Improvement (\\%%) \\\\ \n'); 
for iModel = 1:nModels
  fprintf(fid, '%s && %d [%d, %d] & %d [%d, %d]  & %.1f [%.1f, %.1f] \\\\ \n',  modelLbl(iModel), totCallsBasic(2, iModel), totCallsBasic(1, iModel), totCallsBasic(3, iModel), totCallsStructured(2, iModel), totCallsStructured(1, iModel), totCallsStructured(3, iModel), improvementTotal(2, iModel), improvementTotal(1, iModel), improvementTotal(3, iModel) );
end
fprintf(fid, '\\hline  \n');

fprintf(fid, '\\end{tabular} \n');


fclose(fid);

