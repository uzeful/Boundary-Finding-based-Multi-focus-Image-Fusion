% -------------------------------------------------------------------------
% Matlab demo code for "Boundary find Based Multi-focus Image Fusion through Multi-scale Morphological Focus-measure, Information Fusion 35 (2017) 81-101". 
% Implemented by ZhangYu, Electronic Engineering Department, Tsinghua University
% Email: uzeful@163.com
% -------------------------------------------------------------------------


% ----------------------- Clear history and memory -----------------------
clc;clear;close all;


% -------------------------- Read the image set -------------------------- 
names = {'clock',  'lab', 'pepsi', 'book', 'flower', 'desk', 'seascape', 'temple', 'leopard', 'wine', 'balloon', 'calendar', 'corner', 'craft', 'leaf', 'newspaper', 'girl', 'grass', 'toy'};
name = names{2};    % image name
type = '.bmp';      % image type
N = 2;              % default image number

% if fusing 'toy' image set, the image number should be set as 3
if strcmp(name, 'toy')
    N = 3;
end

% Get the input image data
img1 = imread (strcat('Datasets\',name,num2str(1),type));
img2 = imread (strcat('Datasets\',name,num2str(2),type));

% if the image have 3 channel
if size(img1, 3) == 3
    img1 = rgb2gray(img1);
    img2 = rgb2gray(img2);
end 

img1= double(img1);
img2= double(img2); 


% ----------------------- parameters Settings ----------------------------- 
sw_sz = 7;  % search window size
scales = 5; % weighted focus-measure scales
b_sz = 20;  % boundary refinement in a local boundary region


% --------------------------- Image Fusion -------------------------------- 
if N == 2                           % if there are only two source images
    [decision_map, fimg] = boundary_finding(img1, img2, sw_sz, scales, b_sz);
elseif N > 2                        % if there are more than two source images
    tic
    [decision_map, fimg] = boundary_finding(img1, img2, sw_sz, scales, b_sz);
    img1 = double(fimg);
    for ii = 3 : N
       img2 = double(imread (strcat('Datasets\',name,num2str(ii),type)));
       [decision_map, fimg] = boundary_finding(img1, img2, sw_sz, scales, b_sz);
       img1 = double(fimg);
    end
end

% -------------------------  show the  fusion image -----------------------
figure, imshow(fimg)