function [polyout,area] = overlap_area(img1, img2,H)

% 将图像转换为灰度图像
gray_img1 = rgb2gray(img1);
gray_img2 = rgb2gray(img2);

% 计算图像顶点坐标
x1 = size(gray_img1, 2);
y1 = size(gray_img1, 1);

x2 = size(gray_img2, 2);
y2 = size(gray_img2, 1);

v1=[0,0;0,y1;x1,y1;x1,0];
v2=[0,0;0,y2;x2,y2;x2,0];
for i=1:4
    tmp=H*[v1(i,1);v1(i,2);1];
    v1(i,:)=tmp(1:2);
end

poly1 = polyshape(v1);
poly2 = polyshape(v2);
polyout= intersect(poly1,poly2);
area=polyarea(polyout.Vertices(:,1),polyout.Vertices(:,2));

end
