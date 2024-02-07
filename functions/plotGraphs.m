function plotGraphs(results, parsToProfile, mdl, savLbl, savFolder, iCall)

% Extract variables from results structure
if isfield(results, 'sol')
    trueSolFlag = 1;        % flag indicating whether the results structure contains the true solution or not
    sol = results.sol;
else
    trueSolFlag = 0;
end
obs = results.obs;
solMLE = results.solMLE;
ThetaMLE = results.ThetaMLE;
ThetaProfile = results.ThetaProfile;
logLikNorm = results.logLikNorm;
solMLEImproved = results.solMLEImproved;
ThetaMLEImproved = results.ThetaMLEImproved;
ThetaProfileImproved = results.ThetaProfileImproved;
logLikImprovedNorm = results.logLikImprovedNorm;


h = figure(2*(iCall-1)+1);
h.Position = [        98         524        1043         420];
subplot(1, 2, 1)
if trueSolFlag
    pl3 = plot(sol.xPlot, obs, '.' );
    pl3(1).DisplayName = 'data';
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl1 = plot(sol.xPlot, sol.eObs, '-');
    pl1(1).DisplayName = 'actual';
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLE.xPlot, solMLE.eObs, '--');
    pl2(1).DisplayName = 'MLE';
    for ii = 2:length(pl1)
        pl1(ii).HandleVisibility = 'off';
        pl2(ii).HandleVisibility = 'off';
        pl3(ii).HandleVisibility = 'off';
    end
else
    pl3 = plot(solMLE.xPlot, obs, '.' );
    pl3(1).DisplayName = 'data';
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLE.xPlot, solMLE.eObs, '--');
    pl2(1).DisplayName = 'MLE';
    for ii = 2:length(pl2)
        pl2(ii).HandleVisibility = 'off';
        pl3(ii).HandleVisibility = 'off';
    end
end
legend;
xlabel(mdl.xLbl)
ylabel(mdl.yLbl)
%ylim([0 inf])
title('(a)')
subplot(1, 2, 2)
if trueSolFlag
    pl3 = plot(sol.xPlot, obs, '.' );
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl1 = plot(sol.xPlot, sol.eObs, '-');
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLEImproved.xPlot, solMLEImproved.eObs, '--');
else
    pl3 = plot(solMLE.xPlot, obs, '.' );
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLEImproved.xPlot, solMLEImproved.eObs, '--');
end
xlabel(mdl.xLbl)
ylabel(mdl.yLbl)
%ylim([0 inf])
title('(b)')
drawnow
pause(0.1)
saveas(gcf, savFolder+"mle_"+savLbl, 'png');


h = figure(2*iCall);
h.Position = [   560         239        1012         709];
nPars = length(ThetaMLE);      % number of parameters to profile
legendDoneFlag = 0;
for iPar = 1:nPars
    subplot(ceil(nPars/2), 2, iPar)
    plot(ThetaProfile(iPar, :), logLikNorm(iPar, :))
    hold on
    ind = find(parsToProfile == iPar);
    if ~isempty(ind)
        plot(ThetaProfileImproved(ind, :), logLikImprovedNorm(ind, :))
    end
    xline(ThetaMLE(iPar), 'b--');
    if ~isempty(ind)
        xline(ThetaMLEImproved(iPar), 'r--');
    end
    if trueSolFlag
        xline(mdl.ThetaTrue(iPar), 'k--');
    end
    if ~isempty(ind) & legendDoneFlag == 0
       if trueSolFlag
          legend('profile likelihood (basic)', 'profile likelihood (structured)', 'MLE (basic)', 'MLE (structured)', 'actual')
       else
          legend('profile likelihood (basic)', 'profile likelihood (structured)', 'MLE (basic)', 'MLE (structured)')
       end
       legendDoneFlag = 1;
    end
    xlabel(mdl.parLbl(iPar))
    ylabel('log likelihood')
    drawnow
end
pause(0.1)
saveas(gcf, savFolder+"profiles_"+savLbl, 'png');


