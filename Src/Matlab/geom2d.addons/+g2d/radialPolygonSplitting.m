function [E_r] = radialPolygonSplitting(gpoly, verbose)
% REWRITE ACCORDING TO PAPER
if nargin < 2; verbose = false; end
% if ~iscell(bpoly)||numel(mb.flattenPolygon(bpoly))==1
%     rings = bpoly;
%     cutinfo = [];
%     pcd = [];
%     return;
% end
%%
% import g2d.*;
% bpoly = mb.correctPolygon(vpoly);
% clearvars -except gpoly bpoly verbose

if verbose, cla, hold on, drawPolygon(gpoly), end;

gpoly_ringsizes = cellfun(@(x) size(x,1), gpoly);
gpoly_ringnum = numel(gpoly);

% get cw orientation of all rings
orientation = cellfun(@g2d.polygonIsCounterClockwise, gpoly, 'uniformoutput', false);
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

% calculate all convex angles of holes cw orientation required
[normal_angles, angles] = g2d.polygonRadialAngles(gpoly);

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
        % shift ring to start ad idpt
        ring_size = size(gpoly{idring}, 1);
        % transforms index to [0 ringsize] calcs circ and restores original
        % index
        e_r = [];
        e_r.begin = gpoly{idring}(idpt, :);
        e_r.normal = normal_angles{idring}(idpt, :);
        point_ids = (mod(idpt-2:idpt, ring_size)+1)';
%         ring_ids = repmat(idring,3,1);
        e_r.points = gpoly{idring}(point_ids,:);
%         e_r.previous_edge = [e_r.points(1, :) e_r.points(2,:)];
%         e_r.following_edge = [e_r.points(2, :) e_r.points(3,:)];
        e_r.is_merged = false;
        if verbose; drawPoint(e_r.points(2,:), 'og'); end
        e_r.normal_angles = normal_angles{idring}(point_ids,:); 
        
        e_r = g2d.calculateRadialEdges(e_r, gpoly);
        
%         h = drawEdge(e_r.edge);
%         delete(h);
        
        E_r{end+1} = e_r; %#ok<AGROW>
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
% bpoly = mb.visilibity2boost(vpoly);
E_r = g2d.radialPolygonSplitting(vpoly);

if numel(E_r) ~= 12
    error('Wrong number of edges');
end

%%
filename = 'res/floorplans/SmallFlat.dxf';
% [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);
cla
% polys = c_Poly(:,1);
% edges = c_Line(:,1);
% circles = c_Cir(:,1);
env = environment.load(filename);
env.obstacles = {};
env_comb = environment.combine(env);
% mb.drawPolygon(env_comb.combined);
vpoly = mb.boost2visilibity(env_comb.combined);
drawPolygon(vpoly);
drawPoint(vpoly{1})

E_r = g2d.radialPolygonSplitting(vpoly);

cellfun(@(x) drawEdge(x.edge), E_r)
