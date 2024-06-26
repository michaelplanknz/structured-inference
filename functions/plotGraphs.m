function plotGraphs(results, parsToProfile, Alpha, mdl, savLbl, savFolder, iCall)

% Calculate threshold value on normalised log likelihood for (1-Alpha)% confidence intervals 
threshold = -0.5*chi2inv(1-Alpha, 1);

% Extract variables from results structure
if isfield(results, 'sol')
    trueSolFlag = 1;        % flag indicating whether the results structure contains the true solution or not
    sol = results.sol;
    ThetaTrue = results.ThetaTrue;
else
    trueSolFlag = 0;
end
obs = results.obs;
solMLE = results.solMLE;
ThetaMLE = results.ThetaMLE;
ThetaProfile = results.ThetaProfile;
logLikNorm = results.logLikNorm;
solMLEStructured = results.solMLEStructured;
ThetaMLEStructured = results.ThetaMLEStructured;
ThetaProfileStructured = results.ThetaProfileStructured;
logLikStructuredNorm = results.logLikStructuredNorm;


lightness = 0.4;       % lightness for data points (setting to 0 will use default colors, setting to 1 will fully lighten them to white)


h = figure(2*(iCall-1)+1);
h.Position = [        98         524        1043         420];
subplot(1, 2, 1)
if trueSolFlag
    pl3 = plot(sol.xPlot, obs, '.' );
    pl3(1).DisplayName = 'data';
    for ii = 1:length(pl3)
        pl3(ii).Color = pl3(ii).Color*(1-lightness) + lightness;      % increase lightness level on data points to assist readability
    end
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl1 = plot(sol.xPlot, sol.eObs, '-', 'LineWidth', 2);
    pl1(1).DisplayName = 'actual';
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLE.xPlot, solMLE.eObs, '--', 'LineWidth', 2);
    pl2(1).DisplayName = 'MLE';
    for ii = 2:length(pl1)
        pl1(ii).HandleVisibility = 'off';
        pl2(ii).HandleVisibility = 'off';
        pl3(ii).HandleVisibility = 'off';
    end
else
    pl3 = plot(solMLE.xPlot, obs, '.' );
    pl3(1).DisplayName = 'data';
    for ii = 1:length(pl3)
        pl3(ii).Color = pl3(ii).Color*(1-lightness) + lightness;      % increase lightness level on data points to assist readability
    end
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLE.xPlot, solMLE.eObs, '--', 'LineWidth', 2);
    pl2(1).DisplayName = 'MLE';
    for ii = 2:length(pl2)
        pl2(ii).HandleVisibility = 'off';
        pl3(ii).HandleVisibility = 'off';
    end
end
legend;
xlabel(mdl.xLbl)
ylabel(mdl.yLbl)
title('(a)')
subplot(1, 2, 2)
if trueSolFlag
    pl3 = plot(sol.xPlot, obs, '.' );
    for ii = 1:length(pl3)
        pl3(ii).Color = pl3(ii).Color*(1-lightness) + lightness;      % increase lightness level on data points to assist readability
    end
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl1 = plot(sol.xPlot, sol.eObs, '-', 'LineWidth', 2);
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLEStructured.xPlot, solMLEStructured.eObs, '--', 'LineWidth', 2);
else
    pl3 = plot(solMLE.xPlot, obs, '.' );
    for ii = 1:length(pl3)
        pl3(ii).Color = pl3(ii).Color*(1-lightness) + lightness;      % increase lightness level on data points to assist readability
    end
    hold on
    set(gca, 'ColorOrderIndex', 1)
    pl2 = plot(solMLEStructured.xPlot, solMLEStructured.eObs, '--', 'LineWidth', 2);
end
xlabel(mdl.xLbl)
ylabel(mdl.yLbl)
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
        plot(ThetaProfileStructured(ind, :), logLikStructuredNorm(ind, :))
    end
    xline(ThetaMLE(iPar), 'b--');
    if ~isempty(ind)
        xline(ThetaMLEStructured(iPar), 'r--');
    end
    if trueSolFlag
        xline(ThetaTrue(iPar), 'k--');
    end
    if isfinite(threshold)
        yline(threshold, 'k:')
    end
    if ~isempty(ind) & legendDoneFlag == 0
       if trueSolFlag
          legend('profile (basic)', 'profile (structured)', 'MLE (basic)', 'MLE (structured)', 'actual', 'Location', 'south')
       else
          legend('profile (basic)', 'profile (structured)', 'MLE (basic)', 'MLE (structured)', 'Location', 'south')
       end
       legendDoneFlag = 1;
    end
    xlabel(mdl.parLbl(iPar))
    ylabel('log likelihood')
    drawnow
end
pause(0.1)
saveas(gcf, savFolder+"profiles_"+savLbl, 'png');


