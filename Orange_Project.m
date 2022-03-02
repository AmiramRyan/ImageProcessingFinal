clc; clear all ; close all;
%get input images
[fileName,path] = uigetfile('*.*','Enter an Image');
fileName = strcat(path,fileName);

[fileName1,path1] = uigetfile('*.*','Enter an Image1');
fileName1 = strcat(path1,fileName1);

%filter images
rgbImg = imread(fileName);
rgbImg = imresize(rgbImg, [512, 512]);
grayImg = rgb2gray(rgbImg);

rgbImg1 = imread(fileName1);
rgbImg1 = imresize(rgbImg1, [512, 512]);
grayImg1 = rgb2gray(rgbImg1);

%thresholding this 
[imgA,t, iterations] =  OptimalTVal(grayImg,0.5);
e = edge(imgA,'Prewitt');
e = imfill(e,'holes');

%create bounding boxes
imshow(rgbImg);
hold on;
areas = regionprops(e,'Area');
bboxes = regionprops(e,'BoundingBox');

for j= 1:length(areas) %draw on top of the original img all the bounding boxes that match the condition
    if (areas(j).Area<1600) && (areas(j).Area>124)
      currBb = bboxes(j).BoundingBox;
      rectangle('Position',[currBb(1),currBb(2),currBb(3),currBb(4)],'EdgeColor','b');
    end  
end
%if the bd box histogram is more white => most likely wax or
%reflection dosent matter to us
%if the bd box histogram is more brown or black => decay or disease not
%good
hold off;
figure;
 

[imgB,t1, iterations1] =  OptimalTVal(grayImg1,0.5);
e1 = edge(imgB,'Prewitt');
e1 = imfill(e1,'holes');

%create bounding boxes
imshow(rgbImg1);
hold on;
areas1 = regionprops(e1,'Area');
bboxes1 = regionprops(e1,'BoundingBox');

for j= 1:length(areas1) %draw on top of the original img all the bounding boxes that match the condition
    if (areas1(j).Area<1600) && (areas1(j).Area>124)
      currBb = bboxes1(j).BoundingBox;
      rectangle('Position',[currBb(1),currBb(2),currBb(3),currBb(4)],'EdgeColor','b');
    end  
end
hold off;
figure;

%show comperisons
subplot(5,2,1);
imshow(rgbImg);

subplot(5,2,2);
imshow(rgbImg1);

subplot(5,2,3);
imshow(grayImg);

subplot(5,2,4);
imshow(grayImg1);

subplot(5,2,5);
imhist(grayImg);

subplot(5,2,6);
imhist(grayImg1);

subplot(5,2,7);
imshow(imgA);

subplot(5,2,8);
imshow(imgB);

%subplot(5,2,9);
%imshow(ImgAR);

%subplot(5,2,10);
%imshow(ImgBR);

%%Functions

function [BDM,t, iterations] =  OptimalTVal(grayScaleImage,tValue)
    grayScaleImage = im2double(grayScaleImage);
    finished = false; %stop condition for out while loop
    iterations = 0; %iteration counter
    %selecting initial estimation for this image
    while ~finished
        div = grayScaleImage > tValue;
        %devide into 2 groups
        m1 = mean(grayScaleImage(div));
        m2 = mean(grayScaleImage(~div));
        newT = 0.5 * (m1 + m2); %computing new T value
        finished = newT <= tValue; %if the value convers we stop the loop
        tValue = newT;
        iterations = iterations + 1; %counting the iterations
    end
BDM = im2bw(grayScaleImage,tValue);
t = tValue;
end %Return a logical img with the optimal tvalue



