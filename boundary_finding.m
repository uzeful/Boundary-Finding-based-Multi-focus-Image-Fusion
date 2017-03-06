function [decision_map, fimg] = boundary_finding(img1, img2, sw_sz, scales, b_sz)

    %% Compute saliency for each image   
    % Focus-measure: Multiscale morphological focus-measure
    scale_num = scales;
    FM1 = multiscale_morph(img1, scale_num);
    FM2 = multiscale_morph(img2, scale_num);
    
    % Sum of the focus-measure
    H = ones(sw_sz);
    sumFM1 = imfilter(FM1, H, 0);   
    sumFM2 = imfilter(FM2, H, 0);   

	maxFM = max(FM1, FM2);              % Max and min of the focus-measure

    max_sumFM = max(sumFM1, sumFM2);    % Max and min of the sum of the focus-measure
    min_sumFM = min(sumFM1, sumFM2);

    %% detect the boundary regions
    sum_maxFM = imfilter(maxFM, H, 0);
    sum_minFM = sumFM1 + sumFM2 - sum_maxFM;

    dif_max_min_sum = max_sumFM - min_sumFM;
    dif_sum_max_min = sum_maxFM - sum_minFM;

    dfmap = (dif_max_min_sum >= 0.8 * dif_sum_max_min) & (dif_max_min_sum >= sw_sz ^ 2);    % the boundary regions

    %% Thin the boundaries
    % Get the dimensions of the input images
    [p1,p2,p3] = size(img1);
    large_dfmap = zeros(p1 + 4, p2 + 4);    % Before thin the bold lines, the map should be extended
    large_dfmap(3 : end - 2, 3 : end - 2) = dfmap;

    line_map = bwmorph(~large_dfmap, 'thin', Inf);
    line_map = line_map(3 : end - 2, 3 : end - 2);

    %% Remove the short lines
    [L, num] = bwlabel(line_map, 8);
    pL = regionprops(L, 'Area');

    area_num = [pL.Area];
    area_sort = sort(area_num, 'descend');

    line_num = ceil(num * 0.2);
    large_area = area_sort(1:line_num);

    th = mean(large_area);
    ppL = ismember(L, find([pL.Area] >= th));
    L = ~ppL;                                               % The tempoary boundary lines L
    decision_map = decision_map_detection(L, FM1, FM2, 4);  % Detect the focused regions
    Boundary = (decision_map == 0);                         % Extract the boundaries
   
    %% Boundary Reconstruction: the third step of reconstruction in the paper
    smallsz = round(p1 * p2 / 40);
    decision_map0 = boundary_reconstruction(decision_map, Boundary, smallsz);

    %% To find a more accurate boundary, by marker based watershed segmentation in the gradient domain
    SE = strel('disk', b_sz);
    map = imerode(decision_map0, SE);    % The stitching regions
    marker_img = (map > 0);              % Marker image

    % Gradient type opt: Gradient operator, specified as one of the text strings:¡®Sobel', ¡®Prewitt', 'CentralDifference', 'IntermediateDifference', or ¡®Roberts'.
    opt = 'Prewitt';
    
    B1 = maker_watershed(FM1, marker_img, opt);
    B2 = maker_watershed(FM2, marker_img, opt);

    % Regenerate the decision maps for other boundaries
    Conn = 4;
    decision_map1 = decision_map_detection(~B1, FM1, FM2, Conn);
    decision_map2 = decision_map_detection(~B2, FM1, FM2, Conn);

    % To select a best boundary by comparing of the fused images
     fimg1 = fusion_image(img1, img2, decision_map1);
     fimg2 = fusion_image(img1, img2, decision_map2);

    % Compare the MS-FM  
    F_FM1 = mean2(multiscale_morph(fimg1, scale_num));
    F_FM2 = mean2(multiscale_morph(fimg2, scale_num));
    
    % boundary fusion, with size sz
    bf_sz = 3;
    
    % image with high focus-measure is selected as the final fused image
    if F_FM1 > F_FM2
        B = B1;
        decision_map = decision_map1;
    else
        B = B2;
        decision_map = decision_map2;
    end
    
    %% Refine the boundaries in the decision map
    decision_map = boundary_reconstruction(decision_map, B, smallsz);
      
    %% Boundary fusion
    [decision_map, fimg] = boundary_fusion(img1, img2, decision_map, bf_sz);
end