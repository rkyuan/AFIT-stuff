function  [lat, lon, alt] = ecef2lla(ECEF_pos);
% function  [lat, lon, alt] = ecef2lla(ECEF_pos);
%
% This function converts a position vector in the ECEF coordinate frame
% to geodetic coordinates (longitude, latitude, and altitude).
% 
% Input parameter:
%   ECEF_pos : ECEF position vector (m)
%
% Output parameters:
%   lon : WGS-84 geodetic longitude (rad)
%   lat : WGS-84 geodetic latitude (rad)
%   alt : WGS-84 ellipsoidal altitude (m)
%

ECEF=ECEF_pos;

a = 6378137;
e2 = 0.00669437999013;
b = 6356752.314;
epsilon = 1E-15;

%  Perform the tranformation
w = sqrt(ECEF(1)^2 + ECEF(2)^2);

if abs(w) > epsilon
  l = e2/2;
  l2 = l^2;
  m = (w/a)^2;
  tmp1 = ECEF(3)*(1-e2)/b;
  n = tmp1^2;
  i = -0.5*(2*l2+m+n);
  k = l2*(l2-m-n);
  tmp2 = m+n-4*l2;
  mnl2 = m*n*l2;
  q = (tmp2^3)/216 + mnl2;
  D = sqrt((2*q-mnl2)*mnl2);
  beta = i/3 - ((q+D)^(1/3)) - ((q-D)^(1/3));
  tmp3 = sqrt(sqrt(beta^2-k) - 0.5*(beta+i));
  t = tmp3 -sign(m-n)*sqrt(0.5*(beta-i));
  w1 = w/(t+l);
  z1 = ECEF(3)*(1-e2)/(t-l);

  lat = atan2(z1,(w1*(1-e2)));
  tmp_lon = 2*atan2((w-ECEF(1)),ECEF(2));
  tmp4 = w-w1;
  tmp5 = ECEF(3)-z1;
  alt = sign(t-1+l)*sqrt(tmp4^2 + tmp5^2);

else 
  alt = sign(ECEF(3))*(ECEF(3)-b);
  lat = sign(ECEF(3))*pi/2;
  tmp_lon = 0;
end

if tmp_lon > pi
  lon  = tmp_lon - 2*pi;
else 
  lon = tmp_lon;
end

