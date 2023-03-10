function H=calc_hom_transform(az,t,s)
H = [s*cosd(az) -s*sind(az) 0;
    s*sind(az) s*cosd(az) 0;
    0 0 1];
H(:,3) = t;
% Normalised the right-corner element to 1
H = H / H(3,3);