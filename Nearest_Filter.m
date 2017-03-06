function result = Nearest_Filter(map, N)
%-----------------------------------------------------%
% classify the non region as the nearest region method
% Formula: result = Nearest_Filter(map, N);
% map is the initial fusion decision map;
% N is the number of the input images
%----------------------------------------------------%

%-------------------------Method 1---------------------------%
% % Find the non region
% tmap = (map == 0);
% btmap = imdilate(tmap, strel('disk', 2));
% 
% [L, num] = bwlabel(btmap, 8);
% 
% for ii = 1 : num
%     ind = (L == ii);
%     
%     % region map
%     r_map = map(ind);
%     
%     n1 = sum(r_map == 1);
%     % two ways to compute n2
% %     n2 = sum(r_map == 2);
%     n2 = sum(r_map) - n1;
%     
%     % count the index num corresponding to the source images
%     if n1 > n2
%        L(ind) = 1;
%     elseif n1 < n2
%        L(ind) = 2;
%     else
%        L(ind) = 0;   
%     end
% end
% 
% result = map + L .* tmap;


%-------------------------Method 2---------------------------%

% Get the dimensions
[yy, xx] = size(map);

% Find the non region
tmap = (map == 0);

tL = zeros(yy, xx);
% Process the Positive image, delete the small patches
[L, num] = bwlabel(tmap, 8);

% for each non regions, find the its bounding box
boxes  = regionprops(logical(L), 'BoundingBox');
len = length(boxes);

% Extended 1 pixel than the restricted bound
for ii = 1 : len
    x = fix(boxes(ii).BoundingBox(1));
    y = fix(boxes(ii).BoundingBox(2)); 
    
    w = boxes(ii).BoundingBox(3); 
    h = boxes(ii).BoundingBox(4); 

% % Original Bounding Box    
%     left = max(1, x - 1);
%     right = min(x + w, xx);
%     
%     top = max(1, y - 1);
%     bottom = min(y + h, yy);

    %% Large scale boundingbox
    left = max(1, x - 2);
    right = min(x + w + 1, xx);

    top = max(1, y - 2);
    bottom = min(y + h + 1, yy);
    
    %% This method is only true for two input images
    
    % Extract the block bounding from the map
    region = map(top : bottom, left : right);
    
    % Count the number of the regions in the bounding box
   	numCount1 = sum(sum(region == 1));
    numCount2 = sum(sum(region == 2));
    
    if numCount1 ~= numCount2
        if numCount1 > numCount2
             tL(L == ii) = 1;
%              tL(top : bottom, left : right) = 1;
        else 
             tL(L == ii) = 2; 
%              tL(top : bottom, left : right) = 2;
        end
    end
    
    %% Below is a method for two or more input images
%     region = map(top : bottom, left : right);
%     % Count the number of the regions in the bounding box
%     numCount = zeros(N, 1);
%     for jj = 1 : N 
%         numCount(jj) = sum(sum(region == jj));
%     end
%     
%     for jj = 1 : N - 1
%         maxCount = max(numCount(jj), numCount(jj + 1));
%         for kk = jj + 1 : N
%             isequal = (numCount(jj) == numCount(kk));
%         end
%     end
%     
%     ind = find(numCount == maxCount);
%     ppL(top : bottom, left : right) = ind(1) * (1 - isequal);
    
end

result = map + tL .* tmap;

return