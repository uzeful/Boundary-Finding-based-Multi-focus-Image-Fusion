function refined_decision_map = refine_boundary(decision_map, Boundary)
    % Usage: refined_decision_map = refine_boundary(decision_map)
    % Input: decision_map
    % ---decision_map: Input decision map with the boundary needing
    % ---Boundary: Initial boundary
    % refinement
    %
    % Output: decision_map
    % ---refined_decision_map: the refined decision map without isolated
    % boundary lines.

    % Initialize the refined decision map
    refined_decision_map = decision_map;
    
    % find the boundary positions
    [row, col] = find(Boundary);
    len = length(row);
    box_sz = 3;
    
    % padding the image for convinient computation
    domain = ones(box_sz);
    pad_dfmap = hPadImage(decision_map, domain, 'symmetric');
    
    % count and filter the isolated boundaries
    for ii = 1 : len
        x = row(ii);
        y = col(ii);
        box_data = pad_dfmap(x : x + box_sz - 1, y : y + box_sz - 1);

        %% maximum number filter
        ind1 = find(box_data == 1);
        ind2 = find(box_data == 2);    

        tag = 0;

        if ~isempty(ind1) && isempty(ind2)
            tag = 1;
        end   

        if isempty(ind1) && ~isempty(ind2)
            tag = 2;
        end

        refined_decision_map(x, y) = tag;

    end
end