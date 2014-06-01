function edges = ring2edges(ring)
%% RING2EDGES converts a boost ring representation to edge representation 
%   ring = [v1, v2, ..., vn] -> [[v1; v2], [v2; v3], ... ; [vn-1; vn]] = edges

edges = [r