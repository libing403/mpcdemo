clc;
clear;
close("all")

T_f = 'gpsData.mat';
gpsData = load(T_f);
T = gpsData.T;

overlap_N=0;
img_Num=169;
for idx=1:img_Num-1
A = imread(['imageFile/',T.img{idx}]);
B = imread(['imageFile/',T.img{idx+1}]);
% relative bearing between two location points,azimuth()计算最大圆方位角
az = abs(180-azimuth(T.lat(idx), T.lon(idx), T.lat(idx + 1), T.lon(idx + 1)));
% Define two GPS coordinates
lat1 = T.lat(idx); % latitude of point 1
lon1 = T.lon(idx); % longitude of point 1
lat2 = T.lat(idx + 1); % latitude of point 2
lon2 = T.lon(idx + 1);  % longitude of point 2

% Convert GPS coordinates to Cartesian coordinates
wgs84 = wgs84Ellipsoid('meter');
[x1, y1, z1] = geodetic2ecef(wgs84, lat1, lon1, 579.275268817204);
[x2, y2, z2] = geodetic2ecef(wgs84, lat2, lon2, 579.7451171875);

% Compute Euclidean distance between the two points
dist = pdist2([x1, y1, z1], [x2, y2, z2]);

% Calculate the displacement
Tx = dist * sind(az) * 3284 / (185  ) ;
Ty =  dist * cosd(az)  * 3284  / (185 ) ;
t = [Tx; Ty; 1];

s = 1; % always equal to 1
% homography transformation matrix
H = [s*cosd(az) -s*sind(az) 0;
    s*sind(az) s*cosd(az) 0;
    0 0 1];
H(:,3) = t;

% Normalised the right-corner element to 1
H = H / H(3,3);

% t时刻已镶嵌的图像归一化面积，正常情况是已知的
gray_imgA = rgb2gray(A);
% 计算图像面积，每张图片一样只需计算一次
S_area = size(gray_imgA, 1) * size(gray_imgA, 2);
% 计算图像非零像素数
nonzero_pixels = nnz(gray_imgA);
% 计算像素面积归一化面积
AMsk = nonzero_pixels / S_area;

gray_imgB = rgb2gray(B);
B_area = size(gray_imgB, 1) * size(gray_imgB, 2);
Aft=B_area/B_area;

%计算重叠面积
[polyout,area]=overlap_area(A,B,H);
if(area>100)
    overlap_N=overlap_N+1;
end
overlap=area/B_area;
%计算增加ft+1后的马赛克面积，根据公式4
alpha=1;gama=1;
AMsk1=calc_mosaics_area(AMsk,Aft,overlap,alpha,gama);
%显示图像
pause(0.001)
clf
subplot(1, 3, 1);
imshow(A);
title('ft');
axis equal

subplot(1, 3, 2);
imshow(B);
title('ft+1');
axis equal

subplot(1, 3, 3);
imshow(A);
hold on
title('ft+1');
plot(polyout,"LineStyle","-","FaceColor","g");
title('cropped 1');
axis equal

%计算图像的熵
Dt=image_entropy(B);
%计算网络带宽
Bt=calc_bandwidth(gray_imgB,0.01);
%计算效用值


end
