function B=calc_bandwidth(im)
%����figure,���߾���(1,1.05),(10,0.6)��%1������Ϊ0.625
B=length(im(:,1))*length(im(1,:))*3/1024/1024;%Mb

end