% Origin
p0lat = 39.7592*pi/180;
p0lon = -84.19381*pi/180;
p0alt = 1000;

% WGS-84 values for geoid semi-major axis and eccentricity squared
a=6378137.0;   % WGS-84 values
e2=0.00669437999013;

vel = 300; % meters/sec
heading = 135*pi/180; % northeast

dt = 1;
dpos = dt*vel;
timeVec = [0:dt:3600]';

% Create output structure
llaOut = zeros(length(timeVec),4);
llaOut(:,1) = timeVec;
llaOut(1,2) = p0lat;
llaOut(1,3) = p0lon;
llaOut(:,4) = p0alt;  % Flying at constant altitude

for j=2:size(llaOut,1)
    
    dnorth = dpos * cos(heading);
    deast = dpos * sin(heading);
    
    latOld = llaOut(j-1,2);
    lonOld = llaOut(j-1,3);
    altOld = llaOut(j-1,4);
    
    % Calculate conversions from delta-lat/lon to meters
    sin2lat=(sin(latOld))^2;
    Rm=a*(1-e2)/((1-e2*sin2lat)^(3/2));
    lat_factor=Rm + altOld;
    Rp=a/sqrt(1-e2*sin2lat);
    lon_factor=cos(latOld)*(Rp + altOld);
    
    dlat = dnorth / lat_factor;
    dlon = deast / lon_factor;
    
    % increment latitude and longitude and save
    llaOut(j,2) = latOld + dlat;
    llaOut(j,3) = lonOld + dlon;
    
end

save('proj1_flight_trajectory.dat','-ascii','-double','llaOut')

figure(1)
clf
ax = usamap({'OH','FL','ME'});
%ax = worldmap;
set(ax, 'Visible', 'off')
latlim = getm(ax, 'MapLatLimit');
lonlim = getm(ax, 'MapLonLimit');
states = shaperead('usastatehi',...
        'UseGeoCoords', true, 'BoundingBox', [lonlim', latlim']);
geoshow(ax, states, 'FaceColor', [1 1 1])
hold on
geoshow(llaOut(:,2)*180/pi, llaOut(:,3)*180/pi,'Color','r')
