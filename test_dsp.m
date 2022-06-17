clc, close all, clear

vd = linspace(0, 1, 1e3);
rs = 0.01;
vt = 30e-3;
i0 = 1e-9;
id_solve = @(x) i0.*(exp((vd-rs*x)./vt)-1)-x;

id_guess = vd / rs;
id_true = fsolve(id_solve, id_guess);
%% test full range of exp
clc, close all, clear
a = linspace(-10, 10, 1e4);
b = [];
for aa = a
    b(end+1) = cordicexp(aa, 16);
end
plot(a, (b-exp(a))./exp(a))
%% test full range of div
clc, close all, clear
a = linspace(-10, 10, 1e4);
b = [];
for aa = a
    b(end+1) = nr_div(1, aa, 2);
end
plot(a, (b-1./a)./(1./a))
%%
close all, clc
% 0 = i0(exp((v-ir)/vt)-1)-i = f(i)
% x_i+1 = x_i - f(x_i)/f'(x_i)
% f'(i) = -i0*r/vt*exp((v-ir)/vt)-1

icalc = [];
for vmeas = vd
    icalc(end+1) = numerical_solve(vmeas, 3, 20, 16, rs, vt, i0);
end
loglog(id_true, abs((icalc-id_true)./id_true))
xlim([1e-9 100])
grid on
%%
y = cordicexp(0.1, 16);
lookup = round(atanh(2.^(-(1:16)))*2^(16-1))
