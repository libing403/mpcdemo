clc
clear
close('all');
%�������A
A=[0,0;
    2,0;
    2,2;
    0,2];
%�������B
B=[0,0;
    2,0;
    2,2;
    0,2];
%��תƽ�ƾ���
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
%����������������εĽ���
[polyout,shapeID,vertexID] = intersect(poly1,poly2);
plot(poly1)
hold on
plot(poly2)
%���ƽ������ص����ľ������
plot(polyout,"LineStyle","-","FaceColor","g");
axis equal
%�����ص����
overloap=polyarea(polyout.Vertices(:,1),polyout.Vertices(:,2));
fprintf("�ص���� %f\n",overloap);
