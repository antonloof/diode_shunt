clc, close all, clear
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
