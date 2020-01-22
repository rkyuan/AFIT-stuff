function x_out = SpaceX_student_function(x_in,thrust)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
u_step = [thrust;evalin('base','F_grav_0')];

x_out = evalin('base' ,'system_d.A')*x_in + evalin('base','system_d.B')*u_step;
x_out = evalin('base' ,'system_d.A')*x_in + evalin('base','System.B')*0.1*u_step;

end

