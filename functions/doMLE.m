function [ThetaMLE, parMLE, solMLE, LLMLE, countMLE] = doMLE(mdl, obs)

% Function to calculate the MLE using the basic methiod
% 
% USAGE: [ThetaMLE, parMLE, solMLE, LLMLE, countMLE] = doMLE(mdl, obs)
%
% INPUTS: mdl - a model-specification structure (as returned by specifyModel)
%         obs - an array of observed data
%
% OUTPUTS: ThetaMLE - vector of target parameter values at the MLE
%          parMLE - full parameter structure (as returned by getPar) containing all parameter values at the MLE
%          solMLE - solution structure (as returned by solveModel) for the model at the MLE
%          LLMLE - value of the log-likelihood function at the MLE
%          countMLE - count of function calls to solveModel

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

