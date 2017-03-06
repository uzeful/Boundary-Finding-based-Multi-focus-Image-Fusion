function decision_map = decision_map_detection(L, FM1, FM2, Conn)
    % Usage: decision_map = decision_map_detection(L, FM1, FM2, Conn)
    % Input: L, FM1, FM2, Conn
    % ---L: Input line map
    % ---Conn£ºformat of connectinos £¨4 conn or 8 conn£©
    % ---FM1 or FM2: Focus measures of input image 1 and image 2
    % Output: decision_map
    % ---decision_map: Focus detection result of the segemented regions by
    % the input line map L.
    
    %% Find the connected regions
    [Conn_Reg, num] = bwlabel(L, Conn); 
    decision_map = Conn_Reg;

    %% Focus detection
    % first, the detected focused reions (Just consider two images)
    for ii = 1 : num
        % Find the ii-th region
        tag = (Conn_Reg == ii);

        % Initialise the lable
        label = 0;

        % Compute the focus measure of this region
        sumFM1 = sum(sum(FM1 .* tag));
        sumFM2 = sum(sum(FM2 .* tag));

        % Comparing the focus-measures
        if sumFM2 > sumFM1
            label = 2;
        elseif sumFM2 < sumFM1
            label = 1;
        end

        % Define this region
        decision_map(tag) = label;
    end

end