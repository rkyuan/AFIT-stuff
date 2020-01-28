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

eph=current_ephemeris(prn);

mu = 3.986005*10^14

omega_e_dot = 7.2921151467*10^-5

A = eph.sqrt_a^2

n0 = sqrt(mu/A^3)

tk = transmit_time - eph.t0e

if tk > 302400
    tk = tk-604800
end

if tk< -302400
    tk = tk + 604800
end

n = n0 + eph.delta_n

Mk = eph.M0 +n*tk

syms eksolver

Ek = solve(eksolver - eph.e * sin(eksolver) - Mk)


vk = atan2(sqrt(1-eph.e^2)*sin(Ek)/(1 - eph.e * cos(Ek)),(cos(Ek)-eph.e)/(1-eph.e*cos(Ek)))


phik = vk + eph.omega


deltauk = eph.Cus * sin(2*phik) + eph.Cuc*cos(2*phik)

deltark = eph.Crs * sin(2*phik) + eph.Crc*cos(2*phik)

deltaik = eph.Cis * sin(2*phik) + eph.Cic*cos(2*phik)


uk = phik + deltauk

rk = eph.sqrt_a^2*(1-eph.e * cos(Ek)) + deltark

ik = eph.i0 + deltaik + eph.idot*tk

xk_prime = rk*cos(uk)
yk_prime = rk*sin(uk)



omegak = eph.Omega0 +(eph.Omegadot - omega_e_dot)*tk - omega_e_dot*eph.t0e


xk = xk_prime * cos(omegak) - yk_prime*cos(ik)*sin(omegak)
yk = xk_prime * sin(omegak) + yk_prime*cos(ik)*cos(omegak)
zk = yk_prime*sin(ik)


t = transmit_time

c = 2.99792458 * 10^8

F = -2*sqrt(mu)/c^2

deltatr = F * eph.e * eph.sqrt_a * sin(Ek)

deltatsv = eph.af0 +eph.af1*(t-eph.toc) + eph.af2*(t-eph.toc)^2 + deltatr


light_travel_distance = sqrt( (xk-rcvr_pos(1))^2 + (yk-rcvr_pos(2))^2 + (zk-rcvr_pos(3))^2)

light_travel_time = light_travel_distance/c

gamma = omega_e_dot * light_travel_time

earth_rotation_matrix = [cos(gamma) sin(gamma) 0; -1*sin(gamma) cos(gamma) 0; 0 0 1]

sv_pos = earth_rotation_matrix * [xk;yk;zk]

sv_clock_err = deltatsv


end

