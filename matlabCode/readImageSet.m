function imageSet = readImageSet(dirName)
% readImageSet - 读取指定目录下的所有图像
% 输入参数：
%     dirName - 目录名
% 输出参数：
%     imageSet - 包含所有图像的cell数组

% 获取指定目录下的所有图像文件名
fileList = dir(fullfile(dirName, '*.png'));
numImages = length(fileList);

% 逐个读取图像文件并存储到cell数组中
imageSet = cell(numImages, 1);
for i = 1:numImages
    fileName = fullfile(dirName, fileList(i).name);
    imageSet{i} = imread(fileName);
    image(imageSet{i})
end
end
