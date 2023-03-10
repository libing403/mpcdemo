% 读取两个彩色图像
img1 = imread('IMG_6330.JPG');
img2 = imread('IMG_6331.JPG');

% 显示两个图像
subplot(1,2,1);
imshow(img1);
title('Image 1');

subplot(1,2,2);
imshow(img2);
title('Image 2');

% 提取两个图像的特征点
points1 = detectSURFFeatures(rgb2gray(img1));
points2 = detectSURFFeatures(rgb2gray(img2));

% 提取特征描述子
[features1, validPoints1] = extractFeatures(rgb2gray(img1), points1);
[features2, validPoints2] = extractFeatures(rgb2gray(img2), points2);

% 匹配两个图像的特征点
indexPairs = matchFeatures(features1, features2);

% 选出匹配对应的特征点
matchedPoints1 = validPoints1(indexPairs(:,1));
matchedPoints2 = validPoints2(indexPairs(:,2));

% 计算单应变换矩阵
tform = estimateGeometricTransform2D(matchedPoints1, matchedPoints2, 'projective');

% 显示变换后的图像
img1_transformed = imwarp(img1, tform);
figure;
subplot(1,2,1);
imshow(img1_transformed);
title('Image 1 transformed');

subplot(1,2,2);
imshow(img2);
title('Image 2');

