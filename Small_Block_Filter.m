function newmap = Small_Block_Filter(map, N, small_size)
%------------------------
% small_size is the defined number for small regions
% map is the initial fusion decision map;
% N is the number of the input images

%% define the size of the small region
P = small_size;
conn = 4;
if N == 2
    map1 = (map == 1);
    map2 = (map == 2);
    
    % Process the Positive image, delete the small patches
    tmap1 = bwareaopen(map1, P, conn);
    tmap2 = bwareaopen(map2, P, conn);
    
    % sum map
    sum_map = (tmap1 & tmap2);
    
    % the final decision map
    newmap = (tmap1 + tmap2 * 2) .* (1 - sum_map);
    
else
   % if there are only two input images 
    for ii = 1 : N
        ptmap = (map == ii);
        tmap = bwareaopen(ptmap, P, conn);
        
%%-----------------Explicit details to delete small regions------------------%%        
%         % Process the Positive image, delete the small patches
%         pL = bwlabel(ptmap, 4);
%         % Compute the area of each component.
%         pS = regionprops(pL, 'Area');
%         % Remove small objects.
%         ppL = ismember(pL, find([pS.Area] >= P));
%         tmap = (ppL > 0);
%%---------------------------------------------------------------------------%%
        result(:,:,ii) = tmap;
    end

    % Find if there are confused pixels
    sCount = sum(result, 3);
    Tag = (sCount == 1);
    newmap = zeros(size(map));

    for ii = 1 : N
       newmap = newmap + ii * result(:,:,ii) .* Tag;
    end
end