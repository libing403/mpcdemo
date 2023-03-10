function entropy = image_entropy(image)
% IMAGE_ENTROPY Compute the entropy of an RGB image
%   entropy = IMAGE_ENTROPY(image) returns the entropy of the image.
%   image should be a 3-dimensional matrix representing an RGB image.

% Convert the RGB image to a grayscale image
gray_image = rgb2gray(image);

% Get the histogram of the grayscale image
histogram = imhist(gray_image);

% Normalize the histogram so it sums to 1
histogram = histogram / numel(gray_image);

% Compute the entropy
entropy = -sum(histogram(histogram > 0) .* log2(histogram(histogram > 0)));

end