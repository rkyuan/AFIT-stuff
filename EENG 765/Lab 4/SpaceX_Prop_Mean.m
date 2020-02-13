function x_out = SpaceX_Prop_Mean(x_in, m, input)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    x_out = m.Phi*x_in + m.Bd*input;

end

