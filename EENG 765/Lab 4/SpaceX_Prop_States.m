function x_out = SpaceX_Prop_States(x_in, m, input)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
        
    x_out = m.Phi*x_in + m.Bd * input + chol(m.Qd)'*randn(3,1);
end

