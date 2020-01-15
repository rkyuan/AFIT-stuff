function  ECEF_pos = lla2ecef(lat, lon, alt)
%
% function  ECEF_pos = lla2ecef(lat, lon, alt)
%
% This function converts from geodetic coordinates (longitude,
% latitude, and altitude) to an ECEF position vector.
%
% Input parameters:
%   lon : WGS-84 geodetic longitude (rad) - vector of nx1
%   lat : WGS-84 geodetic latitude (rad) - vector of nx1
%   alt : WGS-84 ellipsoidal altitude (m) - vector of nx1
%
% Output parameter:
%   ECEF_pos : ECEF position vector (m) - matrix of n x 3
%

% initial conditions
a = 6378137;
e2 = 0.00669437999013;

rn = a*ones(size(lat))./sqrt(1-e2*(sin(lat)).^2);
R = (rn + alt).*cos(lat);

ECEF_pos = [R.*cos(lon), R.*sin(lon), (rn*(1-e2) + alt).*sin(lat)];