function B=calc_bandwidth(im)
%根据figure,曲线经过(1,1.05),(10,0.6)，%1降级变为0.625
B=length(im(:,1))*length(im(1,:))*3/1024/1024;%Mb

end