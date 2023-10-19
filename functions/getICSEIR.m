function IC = getICSEIR(par);

% Return vector of intial conditions

% Define initial number in each compartment
S0 = par.popSize;       % susceptible
E0 = 0;                 % exposed
I0 = 0;                 % infectious
R10 = 0;                % recovered (part I)
C10 = 0;                % observed (latent)
C20 = 0;                % observed (cumulative)

IC = [S0; E0; I0; R10; C10; C20];

