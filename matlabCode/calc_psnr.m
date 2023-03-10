function im_psnr = color_to_gray_psnr(orig_image, distorted_image)
% COLOR_TO_GRAY_PSNR Compute the PSNR of two color images after converting them to grayscale
%   psnr = COLOR_TO_GRAY_PSNR(orig_image, distorted_image) returns the PSNR of the two
%   color images after converting them to grayscale. orig_image and distorted_image
%   should be 3-dimensional matrices representing RGB images.

% Convert the images to grayscale
orig_gray = rgb2gray(orig_image);
distorted_gray = rgb2gray(distorted_image);

% Compute the PSNR of the grayscale images
im_psnr = psnr( distorted_gray,orig_gray);

end

