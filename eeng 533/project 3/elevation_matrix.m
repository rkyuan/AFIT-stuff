function e_m = elevation_matrix(rcvrECEF)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
e_m = zeros(287,32);
[rlat,rlong,ralt] = ecef2lla(rcvrECEF);
for prn=1:32
    t = 0;
    for time = [518400:5*60:604200]
        t = t+1;
        [sv_pos, clock_err] = calc_sv_pos_correct(prn,time,rcvrECEF);
        e_m(t,prn)=sv_elevation(rlat,rlong,rcvrECEF,sv_pos);
        e_m(t,prn) = rad2deg(e_m(t,prn));
    end
end
end

