function [x] = numerical_solve(vmeas,div_iter,exp_iter,newton_iter,rs,vt,i0)
%NUMERICAL_SOLVE Summary of this function goes here
%   Detailed explanation goes here
    f_prim = @(i) -i0 * nr_div(rs, vt, div_iter) * cordicexp(nr_div(vmeas-i*rs, vt, div_iter), exp_iter) - 1;
    f = @(i) i0 * (cordicexp(nr_div(vmeas-i*rs, vt, div_iter), exp_iter) - 1) - i;
    
    x = nr_div(vmeas, rs, 2);
    xs = [];
    for i = 1:newton_iter
        x = x - nr_div(f(x), f_prim(x), div_iter);
        xs(end+1)=x;
    end
    plot(xs)
end

