function P_out = SpaceX_Prop_Cov(P_in, m)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
    P_out = m.Phi*P_in*m.Phi' + m.Qd;
end

