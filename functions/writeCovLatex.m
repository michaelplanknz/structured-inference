function writeCovLatex(results, mdl, modelLbl, fName )

nModels = length(mdl);

fid = fopen(fName, 'w');

fprintf(fid, '\\hline  \n');
fprintf(fid, '  & Basic & Structured & \\\\ \n'); 
fprintf(fid, '\\hline  \n');
for iModel = 1:nModels
    fprintf(fid, '& \\multicolumn{3}{l}{\\em %s} \\\\ \n', modelLbl(iModel));
    nPars = length(results(1, iModel).covFlag);
    % Calculate the proportion of realisations for which the CI contained true value of each parameter (under basic and structured methods)
    pCov = mean(cat(2, results(:, iModel).covFlag), 2);
    pCovImproved = mean(cat(2, results(:, iModel).covFlagImproved), 2);
    for iPar = 1:nPars
        jParProfile = 1;
        fprintf(fid, '%s & %.0f\\%%', mdl(iModel).parLbl(iPar), 100*pCov(iPar));
        if ismember(iPar, mdl(iModel).parsToOptimise)
            fprintf(fid, ' &  \\\\ \n');
        else
            fprintf(fid, ' & %.0f\\%%  \\\\ \n', 100*pCovImproved(jParProfile) );
            jParProfile = jParProfile+1;
        end
    end
    fprintf(fid, '\\hline  \n');
end



fclose(fid);

