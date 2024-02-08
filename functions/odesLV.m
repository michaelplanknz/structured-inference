function dydt = odesLV(t, y, par)

big = 1e6;

dydt = [par.r*y(1)*(1-y(1)/par.K) - par.a*y(1)*y(2)/(y(1)+par.b);
        par.a*y(1)*y(2)/(y(1)+par.b) - par.mu*y(2)  ];

% To prevent variables from becoming negative:
negFlag = y < 0;
dydt(negFlag) = -big*y(negFlag);

