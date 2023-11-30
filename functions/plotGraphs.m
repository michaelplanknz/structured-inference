function plotGraphs(sol, solMLE, obs, logLik, ThetaMLE, parsToProfile, nMesh, countMLE, countProfile, mdl, savLbl, savFolder, iCall)

h = figure(2*(iCall-1)+1);
plot(sol.xPlot, sol.eObs, solMLE.xPlot, solMLE.eObs , sol.xPlot, obs, '.' )
legend('actual', 'MLE', 'data')
xlabel(mdl.xLbl)
ylabel(mdl.yLbl)
%ylim([0 inf])
title(sprintf('MLE %i evaluations', countMLE))
drawnow
pause(0.1)
saveas(gcf, savFolder+"mle_"+savLbl, 'png');


h = figure(2*iCall);
h.Position = [   560         239        1012         709];
nPars = length(parsToProfile);      % number of parameters to profile
for iPar = 1:nPars
    ThetaMesh = linspace(mdl.ThetaLower(parsToProfile(iPar)), mdl.ThetaUpper(parsToProfile(iPar)), nMesh);
    subplot(2, 2, iPar)
    plot(ThetaMesh, logLik(iPar, :))
    xline(ThetaMLE(parsToProfile(iPar)), 'r--');
    xline(mdl.ThetaTrue(parsToProfile(iPar)), 'k--');
    legend('profile likelihood', 'MLE', 'actual')
    xlabel(mdl.parLbl(parsToProfile(iPar)))
    ylabel('log likelihood')
    title(sprintf('Profile %i evaluations', countProfile(iPar)))
    drawnow
end
pause(0.1)
saveas(gcf, savFolder+"profiles_"+savLbl, 'png');


