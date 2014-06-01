function edges = ring2edges(ring)
%% RING2EDGES converts a boost ring representation to edge representation 
%   ring = [v1, v2, ..., vn] -> [[v1; v2], [v2; v3], ... ; [vn-1; vn]] = edges

ringcl = mb.closeRing(ring);
edges = [ringcl(:, 1:end-1); ringcl(:, 2:end)];


return

%% TEST test if function works
ring = randi(100, 2, 5);
edges = mb.ring2edges(ring);
log_test(~isempty(edges), 'Test if output is created');
