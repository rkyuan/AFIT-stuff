function [sv_pos, sv_clock_err] = calc_sv_pos(prn, transmit_time, rcvr_pos)
%
%function [sv_pos, sv_clock_err] = calc_sv_pos(prn, transmit_time, rcvr_pos)
%
% This function returns the position of a satellite at a
% particular GPS time, expressed in the ECEF coordinate frame
% valid at the time the signal was received by a GPS receiver.
%
% Input parameters:
%    prn           - PRN of desired satellite
%    transmit_time - Desired time of transmission (GPS week
%                    seconds)
%    rcvr_pos      - (optional) ECEF position vector of
%                    receiver.  If not given, will assume zero
%                    signal propagation time. (m) 
% Output parameter:
%    sv_pos        - ECEF position vector of satellite at time
%                    of transmission, expressed in ECEF 
%                    coordinate frame at time of reception (m)

% Oiriginally written by: Capt Mike Novy, 30 Mar 00 for EENG 533
% Modified by Maj Raquet


% Check for optional input else default to (0,0,0).
if nargin ~= 3
   rcvr_pos = [0,0,0];
end

% Define constants
mu = 3986005e8;               % Gravitational parameter, m^3/s^2
c = 299792458;                % Speed of light, m/s
Omegadote = 7.2921151467e-5;  % Earth rotation rate, rad/sec

% Start position calculation algorithm
% Load desired ephemeris
eph = current_ephemeris(prn);

% Semimajor axis
a = (eph.sqrt_a)^2;

% Corrected mean motion
n = sqrt(mu/a^3) + eph.delta_n;

% Time from ephemeris epoch
dt = transmit_time - eph.t0e;


% Correct for week crossover
if dt > 302400
    dt = dt - 604800;
elseif dt < -302400
    dt = dt + 604800;
end
dt;

% Mean anomaly
M = eph.M0 + n*dt;

% Eccentric anomaly
E0 = M + eph.e * sin(M);
E1 = (eph.e*(sin(E0) - E0*cos(E0)) + M)/(1 - eph.e*cos(E0));
E2 = (eph.e*(sin(E1) - E1*cos(E1)) + M)/(1 - eph.e*cos(E1));

% True anomaly
sinnu = (sqrt(1 - eph.e^2)*sin(E2))/(1 - eph.e*cos(E2));
cosnu = (cos(E2) - eph.e)/(1 - eph.e*cos(E2));
nu = atan2(sinnu,cosnu);

% Argument of latitude
phi = nu + eph.omega;

% Argument of latitude correction
del_phi = eph.Cus*sin(2*phi) + eph.Cuc*cos(2*phi);

% Radius correction
del_r = eph.Crs*sin(2*phi) + eph.Crc*cos(2*phi);

% Inclination correction
del_i = eph.Cis*sin(2*phi) + eph.Cic*cos(2*phi);

% Corrected argument of latitude
u = phi + del_phi;

% Corrected radius
r = a * (1 - eph.e*cos(E2)) + del_r;

% Corrected inclination
i = eph.i0 + eph.idot*dt + del_i;

% Corrected longitude of node
Omega = eph.Omega0 + (eph.Omegadot - Omegadote)*dt - Omegadote*eph.t0e;

% In-plane x-position
xp = r * cos(u);

% In-plane y-position
yp = r * sin(u);

% ECEF x-coordinate
xs = xp*cos(Omega) - yp*cos(i)*sin(Omega);

% ECEF y-coordinate
ys = xp*sin(Omega) + yp*cos(i)*cos(Omega);

% ECEF z-coordinate
zs = yp*sin(i);

% Signal propagation time
tprop = norm([xs,ys,zs]-rcvr_pos)/c;

% Approximate satellite rotation angle
gamma = Omegadote * tprop;

% Coordinate transformation matrix
Ctr = [cos(gamma),sin(gamma),0;-sin(gamma),cos(gamma),0;0,0,1];

% Satellite position in ECEF at time of reception 
sv_pos = Ctr*[xs;ys;zs];

Ek=E2;

F=-4.442807633E-10;

dtr=F*eph.e*eph.sqrt_a*sin(Ek);

dt=transmit_time-eph.toc;
if dt > 302400
    dt = dt - 604800;
elseif dt < -302400
    dt = dt + 604800;
end

sv_pos=sv_pos';
sv_clock_err=eph.af0+eph.af1*dt+eph.af2*dt^2+dtr;