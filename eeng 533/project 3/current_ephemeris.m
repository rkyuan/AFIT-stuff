function ephemeris = current_ephemeris(prn)
% function ephemeris = current_ephemeris(prn)
%
% This function returns the current ephemeris record for the specified
% PRN value.  The "load_eph_file" function must be called prior to
% calling this function.

global EPHEMERIS

ephemeris = EPHEMERIS{prn};