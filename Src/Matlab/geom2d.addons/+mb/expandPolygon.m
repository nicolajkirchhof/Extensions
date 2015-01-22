function bpoly = expandPolygon( bpoly, dist, varargin)
%EXPANDPOLYGON expands a polygon by the given distance
%   parameters :
% bpoly : input polygon in boost form
% distance : the expanding distance
% expandRing = @(x) expandPolygon(double(mb.boost2visilibity(x)), dist);
gpoly = mb.correctPolygon2Geom(bpoly);
expandRingDist = @(x) mb.visilibity2boost(expandRing(x, dist));
bpoly = mb.foreachRing(gpoly, expandRingDist);
end

function out_ring = expandRing(in_ring, dist)
    out_rings = expandPolygon(in_ring, dist);
    out_rings = cellfun(@(x) x(~isinf(x(:,1)), :), out_rings, 'uniformoutput', false);
    if numel(out_rings) > 2
        warning('expand returned more than one, using biggest');
        areas = zeros(1,numel(out_rings));
        for idr = 1:numel(out_rings)
            areas(idr) = polygonArea(out_rings{idr});
        end
        [~, idmax] = max(areas);
        out_ring = out_rings{idmax};
    else
        out_ring = out_rings{1};
    end
end