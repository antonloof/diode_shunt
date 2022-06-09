clc, close all, clear

vd = linspace(0, 1, 1e4);
rs = 0.01;
vt = 30e-3;
i0 = 1e-9;
id_solve = @(x) i0.*(exp((vd-rs*x)./vt)-1)-x;

id_guess = vd / rs;
id_true = fsolve(id_solve, id_guess);
%%
close all
semilogy(vd, id_true);


