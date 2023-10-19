function dydt = odeLV(t, y, par)

% par.r = 1;
% par.K = 1;
% par.a = 2;
%par.b = 0.2;
% par.mu = 1;

dydt = [par.r*y(1)*(1-y(1)/par.K) - par.a*y(1)*y(2)/(y(1)+par.b);
        par.a*y(1)*y(2)/(y(1)+par.b) - par.mu*y(2)  ];
