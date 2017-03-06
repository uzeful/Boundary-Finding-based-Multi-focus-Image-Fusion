function result = maker_watershed(img, marker_img, opt)
% maker_watershed utilizes marker based watershed algorithm to adjust boundaries

    if isempty(opt)
        % default: using the original grayscale feature
        waterimg = img;
    else
        [Gmag,Gdir] = imgradient(img, opt);
        waterimg = Gmag; 
    end

    % Marker based watershed
    waterimg = imimposemin(waterimg, marker_img);
    Lwatershed = watershed(waterimg);

    % return the watershed algorithm result
    result = (Lwatershed==0);

end