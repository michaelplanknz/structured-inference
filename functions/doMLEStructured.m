function [ThetaMLEStructured, parMLEStructured, solMLEStructured, LLMLEStructured, countMLEStructured] = doMLEStructured(mdl, obs)

% Function to calculate the MLE using the structured methiod
% 
% USAGE:  [ThetaMLEStructured, parMLEStructured, solMLEStructured, LLMLEStructured, countMLEStructured] = doMLEStructured(mdl, obs)
%
% INPUTS: mdl - a model-specification structure (as returned by specifyModel)
%         obs - an array of observed data
%
% OUTPUTS: ThetaMLEStructured - vector of target parameter values at the MLE
%          parMLEStructured - full parameter structure (as returned by getPar) containing all parameter values at the MLE
%          solMLEStructured - solution structure (as returned by solveModel) for the model at the MLE
%          LLMLEStructured - value of the log-likelihood function at the MLE
%          countMLEStructured - count of function calls to solveModel

% Indices of remianing parameters in parLbl to profile
parsToProfile = setdiff(1:length(mdl.Theta0), mdl.parsToOptimise);


% Deine objective function for optimisation
objFn = @(Theta_contracted)(-calcLogLikStructured(mdl, obs, Theta_contracted));

if mdl.GSFlag == 0
    % Local search starting from Theta0...
    [ThetaMLE_contracted, f, exitFlag, output] = fmincon( objFn, mdl.Theta0(parsToProfile), [], [], [], [], mdl.lb(parsToProfile), mdl.ub(parsToProfile), [], mdl.options );
    if exitFlag <= 0
        fprintf('Warning in doMLEStructured: fmincon failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
else
    problem = createOptimProblem('fmincon', 'x0', mdl.Theta0(parsToProfile), 'objective', objFn, 'lb', mdl.lb(parsToProfile), 'ub', mdl.ub(parsToProfile), 'options', mdl.options);
    [ThetaMLE_contracted, f, exitFlag, output, gsSolns]  = run(mdl.gs, problem);
    if exitFlag <= 0
        fprintf('Warning in doMLStructuredE: GS failed to converge to a local minimum (exitFlag = %i)\n', exitFlag)
    end
end

LLMLEStructured = -f;
countMLEStructured = output.funcCount;

% Post-calculate optimal value of parameter(s) to be optimised
[~, PhiMLE] = calcLogLikStructured(mdl, obs, ThetaMLE_contracted);

% Combine the output from fmincon with the value of the parameter(s) optimised "within the loop" into a single vector of consistent format with ThetaMLE
ThetaMLEStructured = makeTheta(PhiMLE, ThetaMLE_contracted, mdl.parsToOptimise );

% Solve model at MLE estimate and plot results
parMLEStructured = mdl.getPar(ThetaMLEStructured);
solMLEStructured = mdl.solveModel(parMLEStructured);
