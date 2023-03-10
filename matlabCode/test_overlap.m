clc
clear
close('all');
%定义矩形A
A=[0,0;
    2,0;
    2,2;
    0,2];
%定义矩形B
B=[0,0;
    2,0;
    2,2;
    0,2];
%旋转平移矩形
C=A;
for i=1:4
    p=[B(i,1);B(i,2);1];
    T=rotz(5);
    T(:,3)=[0.5,0.5,1];
    c1=T*p;
    C(i,:)=c1(1:2);
end
poly1=polyshape(A);
poly2 = polyshape(C);
%计算任意两个多边形的交集
[polyout,shapeID,vertexID] = intersect(poly1,poly2);
plot(poly1)
hold on
plot(poly2)
%绘制交集（重叠）的矩形面积
plot(polyout,"LineStyle","-","FaceColor","g");
axis equal
%计算重叠面积
overloap=polyarea(polyout.Vertices(:,1),polyout.Vertices(:,2));
fprintf("重叠面积 %f\n",overloap);
