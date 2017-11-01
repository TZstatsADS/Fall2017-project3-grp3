%manually set the image file directory as the current path/working folder
%load the .jpg file name from the current folder
imname = dir('*.jpg'); 
%determine how many files do we have
im_num = length(imname);
lbp = zeros(im_num, 59);%the dimension is usually 59


for i = 1:length(imname)
%read the file by name
img = imread(fullfile(imname(i).name));
try
    %if the image is colorful then transfer it to gray scale
    img = rgb2gray(img);
catch
    %rgb2gray will return error if input is a gray image, so use try catch
end
%extract LBP features from image
%need to install computer vision system toolbox
lbp(i,:) = extractLBPFeatures(img);
end

%export to a csv file
csvwrite('lbp.csv',lbp);
