function [ThetaMLE, parMLE, solMLE, LLMLE, countMLE] = doMLE(mdl, obs)

% Deine objective function for optimisation
objFn = @(Theta)(-calcLogLik(mdl, obs, Theta));

if mdl.GSFlag == 0
    % Local search starting from Theta0...
    [ThetaMLE, f, exitFlag, output] = fmincon( objFn, mdl.Theta0, [], [], [], [], mdl.lb, mdl.ub, [], mdl.options);
    if exitFlag <= 0
        fprintf('Warning in doMLE: fmincon failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
else
    % Global search
    problem = createOptimProblem('fmincon', 'x0', mdl.Theta0, 'objective', objFn,'lb', mdl.lb, 'ub', mdl.ub, 'options', mdl.options);
    [ThetaMLE, f, exitFlag, output, gsSolns]  = run(mdl.gs, problem);
    if exitFlag <= 0
        fprintf('Warning in doMLE: GS failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
end

LLMLE = -f;
countMLE = output.funcCount;


% Solve model at MLE estimate and plot results
parMLE = mdl.getPar(ThetaMLE);
solMLE = mdl.solveModel(parMLE);

end

