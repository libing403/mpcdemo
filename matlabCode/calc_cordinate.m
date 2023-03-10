function [x,y,z]=calc_cordinate(lat, lon, alt)
wgs84 = wgs84Ellipsoid('meter');
[x, y, z] = geodetic2ecef(wgs84,lat, lon, alt);