function [meas] = SpaceX_gen_meas(x_in, m)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    meas = m.H * x_in + chol(m.R)'*randn;
end

