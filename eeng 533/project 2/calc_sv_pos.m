function [sv_pos,sv_clock_err] = calc_sv_pos(prn, transmit_time, rcvr_pos)
% This function returns the position of a satellite at a
% particular GPS time, expressed in the ECEF coordinate frame
% valid at the time the signal was received by a GPS receiver.
%
% Input parameters:
%    prn           - PRN of desired satellite
%    transmit_time – Desired time of transmission (GPS week
%                    seconds)
%    rcvr_pos      - 1x3 ECEF position vector of the receiver
%
% Output parameters:
%    sv_pos        - 1x3 ECEF position vector of satellite at time
%                    of transmission, expressed in ECEF 
%                    coordinate frame at time of reception (m)
%    sv_clock_err  - SV clock error at the time of transmission,
%                    calculated from the clock error terms of the
%                    navigation message

mu = 3.986005*10^14

omega_e_dot = 7.2921151467*10^-5



end

