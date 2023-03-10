clc
close("all")
%º”‘ÿÕº∆¨
imgset=load('Filedataset.mat');
dataset=imgset.dataset;
fig=figure;
N=length(dataset);
data={};

img_m = mymosaic(dataset{1:30}, 3);
 drawnow
imshow(img_m);
axis equal
imwrite(img_m,'../mosaicResult/result-origion.jpeg','jpeg','Quality',100);
% imwrite(img_m,['../mosaicResult/result-',num2str(k2),'.jpeg'],'Quality',100,'Mode','lossless');

