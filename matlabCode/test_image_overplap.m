clc
clear
close("all")
T_f = 'gpsData.mat';
gpsData = load(T_f);
T = gpsData.T;
N=length(T.img);
fig1=subplot(1, 3, 1); axis equal
fig2=subplot(1, 3, 2); axis equal
fig3=subplot(1, 3, 3); axis equal
for i=1:169-1
    ks=i;
    kt=i+1;
    lat1 = T.lat(ks); % latitude of point 1
    lon1 = T.lon(ks); % longitude of point 1
    lat2 = T.lat(kt); % latitude of point 2
    lon2 = T.lon(kt); % longitude of point 2
    alt1=T.alt(ks);
    flyH1=T.flyH(ks);
    alt2=T.alt(kt);
    flyH2=T.flyH(kt);
    flyH=(flyH1+flyH2)/2;
    [az,dist]=calc_euclidean_distance(lat1,lon1,lat2,lon2,alt1,alt2);
    %compute homography transformation matrix
    t=calc_displacement(az, dist,flyH);
    s=1;
    H=calc_hom_transform(az,t,s);  
    %compute overlap
    A = imread(['imageFile/',T.img{ks}]);
    B = imread(['imageFile/',T.img{kt}]);  
    [polyout,area]=overlap_area(A,B,H);
    pause(0.001)
    cla(fig1);
    cla(fig2);
	
    fig1=subplot(1, 3, 1);
    imshow(A,'initialmagnification',500);
    title(['ft,id=',num2str(ks)]);
    axis equal
    fig2=subplot(1, 3, 2);
    imshow(B,'border','tight','initialmagnification','fit');
    title(['ft+1,id=',num2str(kt)]);
    axis equal
    fig3=subplot(1, 3, 3);
    imshow(B,'border','tight','initialmagnification','fit');
    title('ft+1');
    hold on
    plot(polyout,"LineStyle","-","FaceColor","g");
    title('overlap of ft+1 and ft');
    axis equal      
    
end