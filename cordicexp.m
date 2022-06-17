function [w] = cordicexp(x, n)
%CORDICEXP w=exp(x) with n iterations of cordic
%   Detailed explanation goes here
factor = 1;
% adapt input to convergence range of exp
q = floor(x/log(2));
z = x-q*log(2);

w = 1;
k = 4;
for i = 1:n
    if z > 0 
        d = 1;
    else
        d = -1;
    end
    w = w + d * w * 2.^(-i);
    z = z - d * atanh(2.^(-i));
    factor = factor * sqrt(1-2.^(-2*i));
    if i == k
        if z > 0 
            d = 1;
        else
            d = -1;
        end
        w = w + d * w * 2.^(-i);
        z = z - d * atanh(2.^(-i));
        k = 3*k+1;
        factor = factor * sqrt(1-2.^(-2*i));
    end
end
w = w / factor * 2^q;

end

