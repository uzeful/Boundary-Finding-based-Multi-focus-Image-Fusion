function fimg = fusion_image(img1, img2, decision_map)
% Usage: fimg = fusion_image(img1, img2, decision_map)
% Input: img1, img2, decision_map
% ---img1, img2: the input source images for image fusion
% ---decision_map: Input decision map for image fusion
%
% Output: fimg
% ---fimg: the fused image by combination of the source images according to
% the decision map.

    map1 = double(decision_map == 1); 
    map2 = double(decision_map == 2); 
    map3 = double(decision_map < 1);
    
    img1 = double(img1);  img2 = double(img2);
    fimg = uint8 (map1 .* img1 + map2 .* img2 + map3 .* (img1 + img2) / 2);
end