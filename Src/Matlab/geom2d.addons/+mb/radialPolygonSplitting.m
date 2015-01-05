function [E_r] = radialPolygonSplitting(bpoly, verbose)
% REWRITE ACCORDING TO PAPER
if nargin < 2; verbose = false; end
% if ~iscell(bpoly)||numel(mb.flattenPolygon(bpoly))==1
%     rings = bpoly;
%     cutinfo = [];
%     pcd = [];
%     return;
% end
%%
import g2d.*;
% bpoly = mb.correctPolygon(vpoly);
% clearvars -except gpoly bpoly verbose
gpoly = mb.boost2visilibity(bpoly);
if verbose, cla, hold on, drawPolygon(gpoly), end;
gpoly_ringsizes = cellfun(@(x) size(x,1), gpoly);
gpoly_ringnum = numel(gpoly);

% get cw orientation of all rings
orientation = cellfun(@polygonIsCounterClockwise, gpoly, 'uniformoutput', false);
% outer ring must be ccw in order to get interior angles, holes must be cw
% in order to get exterior angles
if orientation{1} < 0
    gpoly{1} = flipud(gpoly{1});
end
for idring = 2:gpoly_ringnum
    if orientation{idring} > 0
        gpoly{idring} = flipud(gpoly{idring});
    end
end
%
% calculate all convex angles of holes cw orientation required
% angles = mb.polygonAngles(bpoly);
[normal_angles, angles] = polygonNormalAngles(gpoly);

flt_convex_angles = cellfun(@(x) x>pi, angles, 'uniformoutput', false);
% special case, polygon has no holes and is already convex
if numel(flt_convex_angles) == 1 && all(flt_convex_angles{1} == 0)
    rings = bpoly;
    cutinfo = [];
    pcd  = [];
    return;
end

% E_r contains polylines consisting of two segments
E_r = {};
for idring = 1:numel(gpoly)
    ids_ringpoints = find(flt_convex_angles{idring});
    for idpt = ids_ringpoints'
        %%
        % assign points, normal angles and rays
        pl = createReferingPolyline();
        % shift ring to start ad idpt
        ring_size = size(gpoly{idring}, 1);
        % transforms index to [0 ringsize] calcs circ and restores original
        % index
        pl.begin = gpoly{idring}(idpt, :);
        pl.normal = normal_angles{idring}(idpt, :);
        pl.point_ids = (mod(idpt-2:idpt, ring_size)+1)';
        pl.ring_ids = repmat(idring,3,1);
        pl.points = gpoly{idring}(pl.point_ids,:);
        if verbose; drawPoint(pl.points(2,:), 'og'); end
        pl.normal_angles = normal_angles{idring}(pl.point_ids,:); 
        
        pl_xings = cell2mat(cellfun(@(x) intersectRayPolygon(createRay(pl.begin, pl.normal), x), gpoly, 'uniformoutput', false)');
        pl_dists = distancePoints(pl.begin, pl_xings);
        [~, pl_xing_id] = min(pl_dists(pl_dists > 1));
        pl.edge = [pl.begin, pl_xings(pl_xing_id, :)];
        pl.end = pl_xings(pl_xing_id, :);
        
        E_r{end+1} = pl; %#ok<AGROW>
    end
end




return;
%% Testing
filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% vpoly = c_Poly(:,1);
vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
% vpoly{4} = circshift(vpoly{4}, -1, 1);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
% vpoly(1) = cellfun(@reversePolygon, vpoly(1), 'UniformOutput', false);
bpoly = mb.visilibity2boost(vpoly);

