% ��ȡ������ɫͼ��
img1 = imread('IMG_6330.JPG');
img2 = imread('IMG_6331.JPG');

% ��ʾ����ͼ��
subplot(1,2,1);
imshow(img1);
title('Image 1');

subplot(1,2,2);
imshow(img2);
title('Image 2');

% ��ȡ����ͼ���������
points1 = detectSURFFeatures(rgb2gray(img1));
points2 = detectSURFFeatures(rgb2gray(img2));

% ��ȡ����������
[features1, validPoints1] = extractFeatures(rgb2gray(img1), points1);
[features2, validPoints2] = extractFeatures(rgb2gray(img2), points2);

% ƥ������ͼ���������
indexPairs = matchFeatures(features1, features2);

% ѡ��ƥ���Ӧ��������
matchedPoints1 = validPoints1(indexPairs(:,1));
matchedPoints2 = validPoints2(indexPairs(:,2));

% ���㵥Ӧ�任����
tform = estimateGeometricTransform2D(matchedPoints1, matchedPoints2, 'projective');

% ��ʾ�任���ͼ��
img1_transformed = imwarp(img1, tform);
figure;
subplot(1,2,1);
imshow(img1_transformed);
title('Image 1 transformed');

subplot(1,2,2);
imshow(img2);
title('Image 2');

