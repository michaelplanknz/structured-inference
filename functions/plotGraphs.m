function plotGraphs(results, parsToProfile, mdl, savLbl, savFolder, iCall)

% Extract variables from results structure
sol = results.sol;
obs = results.obs;
solMLE = results.solMLE;
ThetaMLE = results.ThetaMLE;
ThetaProfile = results.ThetaProfile;
logLik = results.logLik;
solMLEImproved = results.solMLEImproved;
ThetaMLEImproved = results.ThetaMLEImproved;
ThetaProfileImproved = results.ThetaProfileImproved;
logLikImproved = results.logLikImproved;


h = figure(2*(iCall-1)+1);
h.Position = [        98         524        1043         420];
subplot(1, 2, 1)
pl1 = plot(sol.xPlot, sol.eObs, '-');
hold on
pl2 = plot(solMLE.xPlot, solMLE.eObs, '--');
pl3 = plot(sol.xPlot, obs, '.' );
pl1(1).DisplayName = 'actual';
pl2(1).DisplayName = 'MLE';
pl3(1).DisplayName = 'data';
legend;
xlabel(mdl.xLbl)
ylabel(mdl.yLbl)
%ylim([0 inf])
title('(a)')
subplot(1, 2, 2)
pl1 = plot(sol.xPlot, sol.eObs, '-');
hold on
pl2 = plot(solMLEImproved.xPlot, solMLEImproved.eObs, '--');
pl3 = plot(sol.xPlot, obs, '.' );
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
    plot(ThetaProfile(iPar, :), logLik(iPar, :))
    hold on
    ind = find(parsToProfile == iPar);
    if ~isempty(ind)
        plot(ThetaProfileImproved(ind, :), logLikImproved(ind, :))
    end
    xline(ThetaMLE(iPar), 'b--');
    if ~isempty(ind)
        xline(ThetaMLEImproved(iPar), 'r--');
    end
    xline(mdl.ThetaTrue(iPar), 'k--');
    if ~isempty(ind) & legendDoneFlag == 0
       legend('profile likelihood (basic)', 'profile likelihood (structured)', 'MLE (basic)', 'MLE (structured)', 'actual')
       legendDoneFlag = 1;
    end
    xlabel(mdl.parLbl(iPar))
    ylabel('log likelihood')
    drawnow
end
pause(0.1)
saveas(gcf, savFolder+"profiles_"+savLbl, 'png');


