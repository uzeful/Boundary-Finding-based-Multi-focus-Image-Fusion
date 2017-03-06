function result = boundary_reconstruction(decision_map, Boundary, block_sz)
% boundary_reconstruction is used to reconstruct the Boundaries.

    % delete the small isolated regions
    decision_map = Small_Block_Filter(decision_map, 2, block_sz);

    % Nearest block filter
    decision_map = decision_map - Boundary;
    decision_map = Nearest_Filter(decision_map, 2);

    % Refine the boundaries in the decision map
    result = refine_boundary(decision_map, Boundary);
end