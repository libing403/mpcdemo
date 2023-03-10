function [n,inter]=lineIntersection(A,B,C,D)
x1=A(1);
y1=A(2);
x2=B(1);
y2=B(2);
x3=C(1);
x4=D(1);
y4=D(2);
inter=zeros(2,2);
if(max(x1, x2) < min(x3, x4) || max(y1, y2) < min(y3, y4) || min(x1, x2) > max(x3, x4) || min(y1, y2) > max(y3, y4))
    n=0; 
elseif()
    
end