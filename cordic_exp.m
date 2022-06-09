clc, close all, clear
xs = linspace(0, 1, 1e3);
hold on
y = zeros(size(xs));
for i = 1:length(y)
    y(i) = cordicexp(xs(i), 16);
end
plot(xs, abs(y-exp(xs))./exp(xs));
%%
clc, clear all, close all
xs = linspace(0.5, 1, 1e3);
y = zeros(size(xs));
for i = 1:length(y)
    y(i) = nr_div(1, xs(i), 3);
end
plot(xs, abs(y-1./xs)./y);

%%
is = [1 2 3 4 4 5 6 7 8 9 10 11 12 13 13 14 15 16];

An = 1/prod(sqrt(1-2.^(-2*is)));

inp = 0.3;

w = An;
z = inp;

zs = [];
ys = [];
for i = 1:length(is)
    if z > 0 
        d = 1;
    else
        d = -1;
    end
    w = w + d * w * 2.^(-is(i));
    z = z - d * atanh(2.^(-is(i)));
    zs(i) = z;
end

log2(abs(w - exp(inp)))
