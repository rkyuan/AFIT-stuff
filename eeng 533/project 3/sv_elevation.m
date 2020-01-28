function elevation = sv_elevation(rec_lat, rec_lon, rec_pos_ECEF, sv_pos_ECEF)
%
% function elevation = sv_elevation(rec_lat, rec_lon, rec_pos_ECEF, sv_pos_ECEF)
%
% This function calculates the elevation of a satellite.  Note that
% the lat and lon parameters could be calculated from the rec_pos_ECEF
% vector.  However, this is somewhat computationally intensive, and
% in many cases the lat and lon is already known anyway, so including
% lat and lon as additional parameters greatly speeds up this routine.
%
% Input parameters:
%   rec_lat      : Geodetic latitude of receiver (rad)
%   rec_lon      : Geodetic longitude of receiver (rad)
%   rec_pos_ECEF : Receiver ECEF position vector (row vector) (m)
%   sv_pos_ECEF  : Satellite ECEF position vector (row vector) (m)
%
% Output parameters:
%   elevation : Satellite elevation above horizon (rad)
%

sv_vec = sv_pos_ECEF - rec_pos_ECEF;
sv_unit_vec = sv_vec / norm(sv_vec);

% This is equivalent to Ceg * [0 0 1]'
cos_lat = cos(rec_lat);
geodetic_vertical = [cos_lat*cos(rec_lon), cos_lat*sin(rec_lon), sin(rec_lat)];

elevation = asin(dot(geodetic_vertical, sv_unit_vec));
