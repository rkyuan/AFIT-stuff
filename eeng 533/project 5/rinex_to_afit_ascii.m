function rinex_to_afit_ascii(rinex_obs_file, afit_ascii_file)
% function rinex_to_afit_ascii(rinex_obs_file, afit_ascii_file)

[fid,obs_header]=open_rinex_obs(rinex_obs_file);

fout=fopen(afit_ascii_file,'w');

h=waitbar(0,'Generating AFIT ascii file...');
first_pass=1;
disp_increment=300;

done=0;
while ~done
    
    data=get_next_epoch_rinex(fid,obs_header);
    
    if first_pass
        first_time=data.rcvr_time;
        next_display_time=first_time+disp_increment;
        first_pass=0;
    end
    
    for j=1:data.num_svs
        fprintf(fout,'%10.5f %3d %13.3f %13.3f %13.3f %13.3f %4.2f %4.2f %13.3f %13.3f %13.3f %4.2f\n',...
            data.rcvr_time,data.PRN(j),data.L1_CA_PR(j),data.L1_P_PR(j),data.L1_Phase(j),...
            data.L1_Doppler(j),data.L1_CA_CN0(j),data.L1_P_CN0(j),data.L2_P_PR(j),data.L2_Phase(j),...
            data.L2_Doppler(j),data.L2_P_CN0(j));
        
    end
    
    if data.rcvr_time >= next_display_time
        waitbar((data.rcvr_time-first_time)/86400,h);
        next_display_time = next_display_time + disp_increment;
    end
    
    if data.last_epoch
        done=1;
    end
    
end

close(h);
fclose(fid);
fclose(fout);


%% <date2j.m>
%% return integer  modified julian date given year month day
%
% Author: Charles Meertens, University of Utah/UNAVCO
% Date:   3 January 1994
%
function J = date2j(yy,mm,dd)
if mm <= 2
    yy=yy-1;
    mm=mm+12;
end
J=floor(365.25*yy)+floor(30.6001*(mm+1))+dd-679019;


function data = get_next_epoch_rinex(fid, obs_header_data)
% function data = get_next_epoch_rinex(fid, obs_header_data)
%
% This function returns data from the next epoch in the RINEX file
%
% data is a record which has the following elements:
%    data.rcvr_time: Time that the measurements were taken (according
%                    to receiver clock) (GPS week seconds)
%    data.num_svs: number of SVs for this epoch
%    data.PRN: vector of PRNs
%    data.L1_CA_PR: vector of L1 C/A-code pseudoranges (m)
%    data.L1_P_PR: vector of L1 P-code pseudoranges (m)
%    data.L1_Phase: vector of L1 carrier-phase measurements (cycles)
%    data.L1_Doppler: vector of L1 Doppler measurements (Hz)
%    data.L1_CA_CN0: vector of L1 C/A-code C/N0 values (dB Hz)
%    data.L1_P_CN0: vector of L1 P-code C/N0 values (dB Hz)
%    data.L2_P_PR: vector of L2 P-code pseudoranges (m)
%    data.L2_Phase: vector of L2 carrier-phase measurements (cycles)
%    data.L2_Doppler: vector of L2 Doppler measurements (Hz)
%    data.L2_P_CN0: vector of L2 P-code C/N0 values (dB Hz)
%    data.last_epoch: set to one if this is the last epoch in the data
%                   file, zero otherwise
%
% Written by John Raquet
% 9 May 05
%

header=obs_header_data;

% First, read until you get a valid epoch line with an epoch flag of 0
found_epoch=0;
while ~found_epoch
    %line=read_next_non_comment_line(fid);
    line=fgetl(fid);
    if length(line) >= 30
        if line(28)==32 && line(30)==32 && line(29) == 48
            found_epoch=1;
        end
    end
    if feof(fid)
        found_epoch = 1;
    end
end

d=sscanf(line,' %d %d %d %d %d %f',6);
year=d(1);
month=d(2);
day=d(3);
hour=d(4);
minute=d(5);
sec=d(6);

if year < 50
    year = 2000 + year;
else
    year = 1900 + year;
end
% Calculate GPS week seconds
day_of_week=mod(date2j(year,month,day)-4,7);
data.rcvr_time=day_of_week*86400+hour*3600+minute*60+sec;

% Now, figure out how many/which satellites have data
data.num_svs=str2num(line(31:32));
for j=1:min(data.num_svs,12)
    if strcmp(line(j*3+30),'G')
        data.PRN(j,1) = str2num(line(j*3+31:j*3+32));
    else
        data.PRN(j,1) = 0;
    end
end
if data.num_svs > 12
    line=fgetl(fid);
    line=line(33:end);
    for j=13:data.num_svs
        if strcmp(line((j-13)*3+1),'G')
            data.PRN(j,1) = str2num(line((j-13)*3+2:(j-13)*3+3));
        else
            data.PRN(j,1)=0;
        end
    end
end

% Initialize the output data
data.L1_CA_PR=zeros(data.num_svs,1);
data.L1_P_PR=zeros(data.num_svs,1);
data.L1_Phase=zeros(data.num_svs,1);
data.L1_Doppler=zeros(data.num_svs,1);
data.L1_CA_CN0=zeros(data.num_svs,1);
data.L1_P_CN0=zeros(data.num_svs,1);
data.L2_P_PR=zeros(data.num_svs,1);
data.L2_Phase=zeros(data.num_svs,1);
data.L2_Doppler=zeros(data.num_svs,1);
data.L2_P_CN0=zeros(data.num_svs,1);

% Now, read in the measurements

for j=1:data.num_svs
    num_line1=min([5 header.num_obs]);
    num_line2=min([5 header.num_obs-5]);
    num_line3=min([5 header.num_obs-10]);
    
    data_vec=zeros(12,1);
    meas_count=0;
    % First line
    line=fgetl(fid);
    for k=1:num_line1
        range_min=k*16-15;
        range_max=k*16-2;
        if length(line) >= range_max
            value=str2num(line(k*16-15:k*16-2));
        else
            value=0;
        end
        if length(value)==0
            value=0;
        end
        meas_count=meas_count+1;
        data_vec(header.obs_id(meas_count))=value;
    end
    % Second line
    if num_line2 > 0
        line=fgetl(fid);
    end
    for k=1:num_line2
        range_min=k*16-15;
        range_max=k*16-2;
        if length(line) >= range_max
            value=str2num(line(k*16-15:k*16-2));
        else
            value=0;
        end
        if length(value)==0
            value=0;
        end
        meas_count=meas_count+1;
        data_vec(header.obs_id(meas_count))=value;
    end
    % Third line
    if num_line3 > 0
        line=fgetl(fid);
    end
    for k=1:num_line3
        range_min=k*16-15;
        range_max=k*16-2;
        if length(line) >= range_max
            value=str2num(line(k*16-15:k*16-2));
        else
            value=0;
        end
        if length(value)==0
            value=0;
        end
        meas_count=meas_count+1;
        data_vec(header.obs_id(meas_count))=value;
    end
    
    % Now, assign the data to the output values
    data.L1_CA_PR(j)=data_vec(3);
    data.L1_P_PR(j)=data_vec(4);
    data.L1_Phase(j)=data_vec(5);
    data.L1_Doppler(j)=data_vec(6);
    data.L1_CA_CN0(j)=data_vec(7);
    data.L1_P_CN0(j)=data_vec(8);
    data.L2_P_PR(j)=data_vec(9);
    data.L2_Phase(j)=data_vec(10);
    data.L2_Doppler(j)=data_vec(11);
    data.L2_P_CN0(j)=data_vec(12);
    
end

i=find(data.PRN);

data.L1_CA_PR=data.L1_CA_PR(i);
data.L1_P_PR=data.L1_P_PR(i);
data.L1_Phase=data.L1_Phase(i);
data.L1_Doppler=data.L1_Doppler(i);
data.L1_CA_CN0=data.L1_CA_CN0(i);
data.L1_P_CN0=data.L1_P_CN0(i);
data.L2_P_PR=data.L2_P_PR(i);
data.L2_Phase=data.L2_Phase(i);
data.L2_Doppler=data.L2_Doppler(i);
data.L2_P_CN0=data.L2_P_CN0(i);
data.PRN = data.PRN(i);
data.num_svs=length(i);

if feof(fid)
    data.last_epoch=1;
else
    data.last_epoch=0;
end


function [rinex_obs_fid, obs_header_data]=open_rinex_obs(obs_file_name)
% function [rinex_obs_fid, obs_header_data]=open_rinex_obs(obs_file_name)

try
    fid=fopen(obs_file_name);
catch
    disp(sprintf('\nError opening %s',obs_file_name))
    lasterror
end

done=0;

while ~done
    
    line=fgetl(fid);
    
    if length(line) >= 79
        if strcmp(line(61:79),'APPROX POSITION XYZ')
            obs_data.approx_ecef_pos=sscanf(line,'%f ',[1,3]);
        end
    end
    
    if length(line) >= 79
        if strcmp(line(61:79),'# / TYPES OF OBSERV')
            obs_data.num_obs=str2num(line(1:6));
            num_first_line = min([obs_data.num_obs 9]);
            num_second_line = max([0, obs_data.num_obs-9]);
            for j=1:num_first_line
                obs_data.obs(j).type_str = line(j*6+5:j*6+6);
                obs_data.obs_id(j) = obs_string_to_col(obs_data.obs(j).type_str);
            end
            if num_second_line > 0
                line=fgetl(fid);
            end
            for j=1:num_second_line
                obs_data.obs(j+9).type_str = line(j*6+5:j*6+6);
                obs_data.obs_id(j+9) = obs_string_to_col(obs_data.obs(j+9).type_str);
            end
            
        end
    end
    
    if length(line) >= 73
        if strcmp(line(61:73),'END OF HEADER')
            done=1;
        end
    end
    
end

obs_header_data=obs_data;
rinex_obs_fid = fid;

function column = obs_string_to_col(obs_string)
if strcmp(obs_string,'L1')
    column=5;
elseif strcmp(obs_string,'L2')
    column=10;
elseif strcmp(obs_string,'C1')
    column=3;
elseif strcmp(obs_string,'P1')
    column=4;
elseif strcmp(obs_string,'P2')
    column=9;
elseif strcmp(obs_string,'D1')
    column=6;
elseif strcmp(obs_string,'D2')
    column=11;
elseif strcmp(obs_string,'S1')
    column=7;
elseif strcmp(obs_string,'S2')
    column=12;
else
    column=99;
end


function line=read_next_non_comment_line(fid)

done=0;
while ~done
    line=fgetl(fid);
    done=1;
    if length(line) >= 67
        if strcmp(line(61:67),'COMMENT')
            done=0;
        end
    end
end





