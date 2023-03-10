function cprFile=calc_jpeg_compression(im,degradation)
quality=100-degradation;
cprFile='comprtemp.JPG';
imwrite(im,cprFile,'Quality',quality);

