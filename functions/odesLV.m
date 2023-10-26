function dydt = odesLV(t, y, par)

dydt = [par.r*y(1)*(1-y(1)/par.K) - par.a*y(1)*y(2)/(y(1)+par.b);
        par.a*y(1)*y(2)/(y(1)+par.b) - par.mu*y(2)  ];
