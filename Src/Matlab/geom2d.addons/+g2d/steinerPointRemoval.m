function [E_r] = steinerPointRemoval(gpoly, E_r, verbose)
% REWRITE ACCORDING TO PAPER
if nargin < 2; verbose = false; end

%%
import g2d.*;

is_steiner_points_free = false;
while ~is_steiner_points_free
    %%
    e_r_edges = cell2mat(cellfun(@(x) x.edge, E_r(:)', 'uniformoutput', false)');
    
    combs = comb2unique(1:size(e_r_edges, 1));
    e_r_intersections = intersectEdges(e_r_edges(combs(:,1), :), e_r_edges(combs(:,2), :));
    
    id_intersections = find(~isnan(e_r_intersections(:, 1)) & ~isinf(e_r_intersections(:,1)));
    is_merged = cellfun(@(x, y) (x.is_merged&~y.is_merged)|(y.is_merged&~x.is_merged), E_r(combs(id_intersections, 1)),  E_r(combs(id_intersections, 2)));
    dist_intersections = cellfun(@(x, y) distancePoints(x.begin, y.begin), E_r(combs(id_intersections, 1)),  E_r(combs(id_intersections, 2)));
    edge_dist = cellfun(@(x, y) min([distancePointEdge(y.begin, x.edge), distancePointEdge(y.end, x.edge)]), E_r(combs(id_intersections, 1)),  E_r(combs(id_intersections, 2)));
    
    priority_intersections = is_merged & (edge_dist > 1);  
    [idi] = id_intersections(find(priority_intersections, 1, 'first'));
    if isempty(idi)
        dist_filtered  =  dist_intersections ./ (edge_dist>1);
        [val_min, id_min] = min(dist_filtered);
        if ~isinf(val_min)
            idi = id_intersections(id_min);
        end
    end
    
    %%
    if ~isempty(idi)
        id_edges = combs(idi, :);
        edges = E_r(id_edges);
        
%         h = cellfun(@(x) drawPoint([x.begin;x.end]), edges);
        if edges{1}.is_merged == false && edges{2}.is_merged == false
            new_edge = [];
            new_edge.begin = edges{1}.begin;
            new_edge.end = edges{2}.begin;
            new_edge.edge = [new_edge.begin, new_edge.end];
            new_edge.is_merged = true;
            E_r{end+1} = new_edge;
            
            reflex_points = checkForReflexPoints(edges);
            radial_edges = calculateRadialEdges(reflex_points, gpoly);
            
            E_r = [E_r(:) radial_edges(:)];
            
        else
            merged_edge = [];
            radial_edge = [];
            if edges{1}.is_merged
                merged_edge = edges{1};
                radial_edge = edges{2};
            end
            if edges{2}.is_merged
                merged_edge = edges{2};
                radial_edge = edges{1};
            end
            
            intersect_point = e_r_intersections(idi, :);
            dist_begin = distancePoints(merged_edge.begin, intersect_point);
            dist_end = distancePoints(merged_edge.end, intersect_point);
            
            new_edge = radial_edge;
            
            if dist_begin >= dist_end
                new_edge.end = merged_edge.begin;
            else
                new_edge.end = merged_edge.end;
            end
            new_edge.edge = [new_edge.begin, new_edge.end];
            E_r{end+1} = new_edge;
            E_r{end+1} = merged_edge; % other one will be removed
            
            reflex_points = checkForReflexPoints(edges);
            radial_edges = calculateRadialEdges(reflex_points, gpoly);
            
            E_r = [E_r(:) radial_edges(:)];
        end
        
%         h1 = drawEdge(edges{1}.edge);
%         h2 = drawEdge(edges{2}.edge);
%         h3 = drawEdge(new_edge.edge);
        %     pause;
%         delete(h1); delete(h2); delete(h3); delete(h);
        E_r(combs(idi, :)) = [];
        
    else
        is_steiner_points_free = true;
    end
    
end

return;
%% Tests
filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
E_r = g2d.radialPolygonSplitting(vpoly);
E_r = g2d.steinerPointRemoval(vpoly, E_r)

if numel(E_r) ~= 10
    error('Wrong number of Edges');
end

%% Test with merge

filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);
cla;
hold on;
axis equal;

vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
%%%
vpoly{1} = [vpoly{1}; vpoly{1}(1,1) 5000; vpoly{1}(1,1)+200 4500; vpoly{1}(1,1) 4000];
drawPolygon(vpoly);
%%%
E_r = g2d.radialPolygonSplitting(vpoly);
[E_r] = g2d.steinerPointRemoval(vpoly, E_r)

if numel(E_r) ~= 11
    error('Wrong number of Edges');
end


%%
cla;
cellfun(@(x) drawEdge(x.edge), E_r);
