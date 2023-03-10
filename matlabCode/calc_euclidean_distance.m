function [az,dist]=calc_euclidean_distance(lat1,lon1,lat2,lon2,alt1,alt2)
% relative bearing between two location points,azimuth()计算最大圆方位角
az = abs(180-azimuth(lat1, lon1, lat2, lon2));
% Convert GPS coordinates to Cartesian coordinates
wgs84 = wgs84Ellipsoid('meter');
[x1, y1, z1] = geodetic2ecef(wgs84, lat1, lon1, alt1);
[x2, y2, z2] = geodetic2ecef(wgs84, lat2, lon2, alt2);
% Compute Euclidean distance between the two points
dist = pdist2([x1, y1, z1], [x2, y2, z2]);
end