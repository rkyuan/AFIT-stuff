function load_eph_file(ephem_file_name, time_to_match)
% function load_ephem_file(ephem_file_name, time_to_match)
%
% This function loads in the ephemeris file given by ephem_file_name.
% If there are more than one ephemeris record for a given PRN, it will
% choose the ephemeris record that has a t0e closest to the time_to_match
% parameter.  (time_to_match is optional, and if not specified, the routine
% will return just the first ephemeris record for each PRN).
%
% This routine loads the ephemeris into global memory.  To obtain an
% ephemeris record for a particular PRN, use the function
% "current_ephemeris"

clear global EPHEMERIS

global EPHEMERIS

% Initialize the ephemeris output array
for prn=1:32
    EPHEMERIS{prn}.valid = 0;
end

% Set time_to_match to zero if it isn't specified (which will effectively
% take the first ephemeris for each satellite
if nargin < 2
    time_to_match = 0;
end

dtr = pi/180;  % degrees to radians conversion

% Determine if ascii or binary format
f=fopen(ephem_file_name, 'r');
if f<0

    disp(sprintf('Error opening ephemeris file %s',ephem_file_name))
    return

else

    c=char(fread(f,5))';
    if strcmp(c,'*****')
        is_ascii=1;
    else
        is_ascii=0;
    end
    fclose(f);
end


% Now read file, depending upon file type

if is_ascii

    f=fopen(ephem_file_name,'r');
    done=0;
    while ~done

        % Read in the next record
        try
            next_line=fgetl(f);  % title line
            next_line=fgetl(f); eph.prn      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.week     = str2num(next_line(27:end));
            next_line=fgetl(f); eph.t0e      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.sqrt_a   = str2num(next_line(27:end));
            next_line=fgetl(f); eph.e        = str2num(next_line(27:end));
            next_line=fgetl(f); eph.M0       = str2num(next_line(27:end))*dtr;
            next_line=fgetl(f); eph.i0       = str2num(next_line(27:end))*dtr;
            next_line=fgetl(f); eph.Omega0   = str2num(next_line(27:end))*dtr;
            next_line=fgetl(f); eph.omega    = str2num(next_line(27:end))*dtr;
            next_line=fgetl(f); eph.idot     = str2num(next_line(27:end))*dtr;
            next_line=fgetl(f); eph.Omegadot = str2num(next_line(27:end))*dtr;
            next_line=fgetl(f); eph.delta_n  = str2num(next_line(27:end));
            next_line=fgetl(f); eph.Cuc      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.Cus      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.Crc      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.Crs      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.Cic      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.Cis      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.toc      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.af0      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.af1      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.af2      = str2num(next_line(27:end));
            next_line=fgetl(f); eph.tgd      = str2num(next_line(27:end));
            next_line=fgetl(f);
            eph.valid = 1;
            save_it = 0;

            if ~EPHEMERIS{eph.prn}.valid
                save_it = 1;
            else
                dt_current = abs(time_to_match - EPHEMERIS{eph.prn}.t0e);
                dt_new     = abs(time_to_match - eph.t0e);
                if dt_new < dt_current
                    save_it = 1;
                end
            end

            if save_it
                EPHEMERIS{eph.prn} = eph;
            end

        catch

            done = 1;

        end

        if feof(f)
            done = 1;
        end

    end

else  % It's binary

    % Open up the ephemeris file
    f=fopen(ephem_file_name, 'rb', 'ieee-le');


    % Loop through each record
    while ~feof(f)

        % Read in a new raw record
        [raw_ephem, num_read] = fread(f, [26,1], 'double');

        if num_read == 26

            % Decide if this one should be saved
            save_it = 0;
            prn = raw_ephem(1);

            if ~EPHEMERIS{prn}.valid
                save_it = 1;
            else
                dt_current = abs(time_to_match - EPHEMERIS{prn}.t0e);
                dt_new     = abs(time_to_match - raw_ephem(18));
                if dt_new < dt_current
                    save_it = 1;
                end
            end

            % If it should be saved, convert to the correct format and load it up
            if save_it
                EPHEMERIS{prn} = to_ephemeris_record(raw_ephem);
            end

        end % if num_read == 26

    end % of large while loop

end % ascii or binary

% Print out a summary of which ones have been loaded
%count=0;
%for prn=1:32
%  if ephemeris{prn}.valid
%    count=count+1;
%    loaded(count)=prn;
%  end
%end
%disp(['Ephemeris loaded for PRNs',sprintf(' %d',loaded)])
% Thats it!!

fclose(f);


% subfunction to convert to a matlab ephemeris record format
function eph_record = to_ephemeris_record(raw_ephem)

eph_record.prn      = raw_ephem(1);
eph_record.week     = raw_ephem(2);
eph_record.t0e      = raw_ephem(18);
eph_record.sqrt_a   = raw_ephem(17);
eph_record.e        = raw_ephem(15);
eph_record.M0       = raw_ephem(13);
eph_record.i0       = raw_ephem(22);
eph_record.Omega0   = raw_ephem(20);
eph_record.omega    = raw_ephem(24);
eph_record.idot     = raw_ephem(26);
eph_record.Omegadot = raw_ephem(25);
eph_record.delta_n  = raw_ephem(12);
eph_record.Cuc      = raw_ephem(14);
eph_record.Cus      = raw_ephem(16);
eph_record.Crc      = raw_ephem(23);
eph_record.Crs      = raw_ephem(11);
eph_record.Cic      = raw_ephem(19);
eph_record.Cis      = raw_ephem(21);
eph_record.toc      = raw_ephem(6);
eph_record.af0      = raw_ephem(9);
eph_record.af1      = raw_ephem(8);
eph_record.af2      = raw_ephem(7);
eph_record.tgd      = raw_ephem(4);
eph_record.valid    = 1;

