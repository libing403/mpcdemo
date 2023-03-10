clc
clear
close("all");

%已镶嵌好的马赛克面积Sk
Sk=1;
% 读取图像ft+1
img = imread('im1.jpg');

% 将图像转换为灰度图像
gray_img = rgb2gray(img);
% 计算图像ft+1的面积
Sft_1 = size(gray_img, 1) * size(gray_img, 2);
%面积归一化

%待补充
Sk1=Sk+alpha(Sft_1-gama*overlap);