function [map, fimg] = boundary_fusion(img1, img2, dfmap, sz) 
% boundary_fusion fuses two source images accoring to decision map

    % define the size of structuring element 
    SE = strel('disk', sz);

    % A simple way to expand the boundary
    map = imerode(dfmap, SE);
    
	% focused regions
    map1 = (map == 1);
	map2 = (map == 2);
    
	% distance transform
    D1 = bwdist(map1);
    D2 = bwdist(map2);
    
    % distance sum
    D = D1 + D2;
    
    % distance weight
    coeff1 = D2 ./ (D + eps);
	coeff2 = D1 ./ (D + eps);
    
    % Boundary region
    breg = (map == 0);
    
    % Initial Image
    fimg = uint8(map1 .* img1 + map2 .* img2);
    
    % boundary region fusion image
    bimg = uint8((img1 .* coeff1 + img2 .* coeff2) .* breg);
    
    % final fusion image
    fimg = fimg + bimg;
end