function bpoly = mergePoints(bpoly, dist)
%%
gpoly = mb.boost2visilibity(bpoly);
is_cell = iscell(gpoly);
if ~is_cell
    gpoly = {gpoly};
end
    

fun_edge_lengths = cellfun(@(x) edgeLength([x circshift(x, -1, 1)]) > dist, gpoly, 'uniformoutput', false);
gpoly = cellfun(@(x, flt) x(flt, :), gpoly, fun_edge_lengths, 'uniformoutput', false);


if ~is_cell
    gpoly = gpoly{1};
end

bpoly = mb.visilibity2boost(gpoly);

