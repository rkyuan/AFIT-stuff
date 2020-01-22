clear
clc
clf

%% 
% Step 1:
% 
% x1dot = x2
% 
% x2dot = -G*m1*m2/r^2 + F_thrust
%% 
% Step 2:

G = 6.67 *10^-11;
r_a = 1000;
m1 = 1000;
m2 = 4.497*10^16;

F_grav_0 = -G*m1*m2/r_a^2
%% 
% Step 3:
% 
% f_grav = -G*m1*m2/(r_a+x)^2
% 
% d_f_grav/d_x = 2 * G*m1*m2/(r_a + x)^3

d_f_grav = 2 * G*m1*m2/(r_a)^3
%% 
% Step 4:

syms x
f_grav = -G*m1*m2/(r_a+x)^2;
f_grav_lin = F_grav_0 + d_f_grav*x;

x = 0
RealGravity = double(subs (f_grav))
LinGravity =double(subs(f_grav_lin))
PercentError=100 * (RealGravity - LinGravity)/(RealGravity)

x = 80
RealGravity = double(subs (f_grav))
LinGravity =double(subs(f_grav_lin))
PercentError=100 * (RealGravity - LinGravity)/(RealGravity)

x = 200
RealGravity = double(subs (f_grav))
LinGravity =double(subs(f_grav_lin))
PercentError=100 * (RealGravity - LinGravity)/(RealGravity)

x = 500
RealGravity = double(subs (f_grav))
LinGravity =double(subs(f_grav_lin))
PercentError=100 * (RealGravity - LinGravity)/(RealGravity)
%% 
% Step 5:

F = [0 1;d_f_grav/m1 0]
%2 states for input u1 = thrust u2 = gravity
B = [0 0;1/m1 1/m1]

H= [1 0]

dt= 0.1;

System = ss(F,B,H,0)
system_d = c2d(System,dt)

system_d.A
system_d.B
%% 
% Step 7:

SpaceX_student_function([80;-10],8000)