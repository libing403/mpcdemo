clc
clear
close("all");

%����Ƕ�õ����������Sk
Sk=1;
% ��ȡͼ��ft+1
img = imread('im1.jpg');

% ��ͼ��ת��Ϊ�Ҷ�ͼ��
gray_img = rgb2gray(img);
% ����ͼ��ft+1�����
Sft_1 = size(gray_img, 1) * size(gray_img, 2);
%�����һ��

%������
Sk1=Sk+alpha(Sft_1-gama*overlap);