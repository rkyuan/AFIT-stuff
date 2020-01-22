%% Lab 1 - Space X Rocket - SpaceX_student_script.m
% Name EENG 765

clear; close all; clc
%% Load data from SpaceX game

Project_1
Thrust_data = load('SpaceX_Winning_Inputs.mat');
Thrust_data = Thrust_data.inputs_saved;
%% Set up variables for simulating the data

dt = 0.1 % [seconds]
tt=0:dt:(length(Thrust_data)*dt)-dt; % Time vector [seconds]
%% Initilize the output vector (Velocity and Position)

Vel_0 =-10; %[m/s]
Pos_0 = 80; %[m]

x = zeros(2,length(tt));
y = zeros(1,length(tt));
x(:,1) = [Pos_0;Vel_0];
%% Loop through the data to get the output vector:
y(1)=H*x(:,1)
for i=2:(length(tt)+1)
    x(:,i)=SpaceX_student_function(x(:,i-1),Thrust_data(i-1));
    y(i) = H*x(:,i);
    
end
%% Report Final Velocity

disp(sprintf('The Rockets final Velocity was %.4f m/s',x(2,end)));
%% Plot time vs. position
    figure(1)
    plot(x(1,:))
    grid on
    title('Height vs Time')
    legend('x_1')
    xlabel('time (s)')
    ylabel('height (m)')
    
    figure(2)
    plot(y)
    grid on
    title('Height vs Time (Output)')
    legend('Y')
    xlabel('time (s)')
    ylabel('height (m)')
    
%% Plot Time vs. Velocity
    figure(3)
    plot(x(2,:))
    title('Velocity vs Time')
    legend('x_2')
    xlabel('time (s)')
    ylabel('velocity (m/s)')
    
%% Plot Temperature