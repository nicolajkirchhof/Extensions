function bpoly = mergePoints(bpoly, dist)
%%
gpoly = mb.boost2visilibity(bpoly);
is_cell = iscell(gpoly);
if ~is_cell
    gpoly = {gpoly};
end


fun_edge_lengths = cellfun(@(x) edgeLength([x circshift(x, -1, 1)]) > dist, gpoly, 'uniformoutput', false);
gpoly = cellfun(@(x, flt) x(flt, :), gpoly, fun_edge_lengths, 'uniformoutput', false);
gpoly = gpoly(~cellfun(@isempty, gpoly));
gpoly = gpoly(cellfun(@(p) size(p, 1)>2, gpoly));

if isempty(gpoly)
    bpoly=gpoly;
    
else
    
    if ~is_cell
        gpoly = gpoly{1};
    end
    
    bpoly = mb.visilibity2boost(gpoly);
end
