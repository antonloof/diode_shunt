function [q] = nr_div(n,d,iters)
%NR_DIV Summary of this function goes here
%   q = n/d, d in [0.5, 1]
    scale = floor(log2(abs(d/.5))); % this is counting number of 0 before first one
    ds = sign(d);
    d = abs(d) * 2^(-scale);
    z = 48/17-32/17*d;
    for i = 1:iters
        z = z*(2-d*z);
    end
    q = z*n * 2^(-scale)*ds;
end

