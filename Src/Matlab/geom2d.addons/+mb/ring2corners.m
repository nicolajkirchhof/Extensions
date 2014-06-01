function corners = ring2corners(ring)
%% RING2EDGES converts a boost ring representation to corner representation 
%   ring = [v1, v2, ..., vn] -> [[vn; v1; v2], [v1; v2; v3], ... ; [vn-1; vn; v1]] = edges

ringcl = mb.closeRing(ring);
corners = [circshift(ringcl(:,1:end-1), 1, 2); ringcl(:, 1:end-1); ringcl(:, 2:end)];


return

%% TEST test if function works
ring = randi(100, 2, 5);
corners = mb.ring2corners(ring);
log_test(~isempty(corners), 'Test if output is created');