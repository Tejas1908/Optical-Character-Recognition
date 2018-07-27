clc;
close all;
%-------------------------------------------------------------------------
I = imread('download.jpg');
%IMAGE READING AND PREPROCESSING
figure(4)
imshow(I);
I = rgb2gray(I);
I = medfilt2(I);
level = graythresh(I);
b = im2bw(I,level);
binv = not(b);
figure(1);
imshow(binv);
%-------------------------------------------------------------------------
se = strel('square',4);                  %MORPHOLOGICAL IMAGE PROCESSING 
imc = imclose(binv,se);
% image closing operation performs a dilation followed by an erosion
figure(2)
imshow(imc);
% Remove all object containing less than 150 pixels
% This command will remove unwanted info from the image
imc = bwareaopen(imc,150); 
figure(3)
imshow(imc);
%-------------------------------------------------------------------------
load templates                               %CHARACTER SEGMENTATION                 
carnum = [];                                     
number = size(templates,2);
stats = regionprops(imc,'BoundingBox');
bb = round(reshape([stats.BoundingBox], 4, []).');
% bb is the boundingbox variable and we use the round command to round off the coordinate values
% reshape produces a vector with size n; here our vector is stats.BoundingBox
% and size of vector is 4
figure(2)
imshow(imc);
for idx=1:numel(stats)
    rectangle('Position',bb(idx,:),'edgecolor','green');
end
% we use a cell array to store the segmented characters

chars = cell(1,numel(stats));
for idx=1:numel(stats)
    chars{idx} = imc(bb(idx,2):bb(idx,2)+bb(idx,4)-1,bb(idx,1):bb(idx,1)+bb(idx,3)-1);
end
scores = [];
% The correlation values xx will be stored in the scores array
for idx = 1:numel(stats)
  ch = chars{idx};
  snap = imresize(ch,[42 24]);
%   figure(idx+2)
%   imshow(snap);
  [letter,xx] = readLetter(snap,number);
  scores = [scores,xx];
  carnum = [carnum letter]; 
end
figure;
plot(scores,'*');
% The correlation scores are plotted
% higher similarity implies higher correlation values 
fid1 = fopen('carnum.txt','w');
fprintf(fid1,'%s',carnum);
fclose(fid1);
winopen('carnum.txt');
