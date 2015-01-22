function bpoly = mergePoints(bpoly, dist)
%%
gpoly = mb.boost2visilibity(bpoly);

fun_edge_lengths = cellfun(@(x) edgeLength([x circshift(x, -1, 1)]) > dist, gpoly, 'uniformoutput', false);
gpoly = cellfun(@(x, flt) x(flt, :), gpoly, fun_edge_lengths, 'uniformoutput', false);

bpoly = mb.visilibity2boost(gpoly);
