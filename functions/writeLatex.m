function writeLatex(outTab, modelLbl, fName)

qt = [0.25, 0.5, 0.75];

fid = fopen(fName, 'w');

fprintf(fid, '\\hline  \n');
fprintf(fid, '{\\bf Model}  & \\multicolumn{2}{l}{\\bf Relative error (\\%%)} & \\multicolumn{3}{l}{\\bf Function calls}  \\\\ \n');
fprintf(fid, '  & Basic & Structured & Basic & Structured & Improvement (\\%%) \\\\ \n');
fprintf(fid, '\\hline  \n');
for iModel = 1:length(modelLbl)
    relErrBasic = 100*quantile(outTab.relErrBasic(:, iModel), qt);
    relErrImproved = 100*quantile(outTab.relErrImproved(:, iModel), qt);
    totCallsBasic = round(quantile(outTab.totCallsBasic(:, iModel), qt));
    totCallsImproved = round(quantile(outTab.totCallsImproved(:, iModel), qt));
    improvement = 100*quantile(1 - outTab.totCallsImproved(:, iModel)./outTab.totCallsBasic(:, iModel) , qt );
    fprintf(fid, '%s & %.1f [%.1f, %.1f] & %.1f [%.1f, %.1f] & %d [%d, %d] & %d [%d, %d]  & %.1f [%.1f, %.1f] \\\\ \n' , modelLbl(iModel), relErrBasic(2), relErrBasic(1), relErrBasic(3), relErrImproved(2), relErrImproved(1), relErrImproved(3), totCallsBasic(2), totCallsBasic(1), totCallsBasic(3), totCallsImproved(2), totCallsImproved(1), totCallsImproved(3), improvement(2), improvement(1), improvement(3) );
end
fprintf(fid, '\\hline  \n');

fclose(fid);

