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
                    merged_edge = [];
            radial_edge = [];
        
        %         h = cellfun(@(x) drawPoint([x.begin;x.end]), edges);
        if edges{1}.is_merged == false && edges{2}.is_merged == false
            new_edge = [];
            new_edge.begin = edges{1}.begin;
            new_edge.end = edges{2}.begin;
            new_edge.edge = [new_edge.begin, new_edge.end];
            new_edge.normal = edgeAngle(new_edge.edge);
            new_edge.is_merged = true;
            
        else

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
            new_edge.normal = edgeAngle(new_edge.edge);
            
            
            radial_testing_edge = g2d.calculateRadialEdges(new_edge, gpoly);
            length_nearest_poly_xing = edgeLength(radial_testing_edge.edge);
            length_new_edge = edgeLength(new_edge.edge);
            
            %compare lenghts and use poly intersection if it occurs before
            if length_nearest_poly_xing < length_new_edge
                new_edge = radial_testing_edge;
            end
            
            E_r{end+1} = merged_edge; % other one will be removed    
        end
        
            reflex_points = g2d.checkForReflexPoints(edges);
            %%
            for id_reflex = 1:numel(reflex_points)
                %%
            flt_edges_pt_fw = distancePoints(reflex_points{id_reflex}.begin, e_r_edges(:, 1:2))<=1;
            flt_edges_pt_fw(id_edges) = 0;
            ids_edges_pt_fw = find(flt_edges_pt_fw);
            
            flt_edges_pt_bw = distancePoints(reflex_points{id_reflex}.begin, e_r_edges(:, 3:4))<=1;
            flt_edges_pt_bw(id_edges) = 0;
            ids_edges_pt_bw = find(flt_edges_pt_bw);
            is_merged = arrayfun(@(x) E_r{x}.is_merged, ids_edges_pt_bw); 
            
            ids_edges_pt_bw(~is_merged) = [];
            edges_originating = [e_r_edges(ids_edges_pt_fw, :); e_r_edges(ids_edges_pt_bw, [3:4, 1:2]); new_edge.edge];
            edge_angles = [normalizeAngle(edgeAngle(edges_originating)); reflex_points{id_reflex}.ang_2_1];
            
            angle_begin = reflex_points{id_reflex}.ang_2_3;
            reflex_points{id_reflex}.is_needed = false;
            while ~isempty(edge_angles)
                %%
                [angle_size, id_end] = min(arrayfun(@(x) normalizeAngle(angleDiff(angle_begin, x)), edge_angles));
                if angle_size > pi
                    reflex_points{id_reflex}.is_needed = true;
                end
                angle_begin = edge_angles(id_end);
                edge_angles(id_end) = [];
            end
            end
            %%
            is_needed = cellfun(@(x) ~x.is_needed, reflex_points);
            reflex_points(is_needed) = [];
            radial_edges = calculateRadialEdges(reflex_points, gpoly);
            %%
            E_r = [E_r(:); radial_edges(:)];
        
        E_r{end+1} = new_edge;
        
%         h1 = drawEdge(edges{1}.edge, 'color', 'g', 'linewidth', 2);
%         h2 = drawEdge(edges{2}.edge, 'color', 'k', 'linewidth', 2);
%         h3 = drawEdge(new_edge.edge, 'color', [1 1 0]);
%         h4 = drawEdge(e_r_edges, 'linestyle', ':');
%         is_merged = cellfun(@(x) x.is_merged, E_r);
%         for id_merged_er = 1:numel(E_r)
%             if E_r{id_merged_er}.is_merged
%                 drawEdge(E_r{id_merged_er}.edge, 'color', [1 0 0], 'linewidth', 2);
%             end
%         end
        %     pause;
%         delete(h1); delete(h2); delete(h3); delete(h4); %delete(h5)  %delete(h);
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

%%
%% Complicated tests
clear variables;
cla;
axis equal
hold on;
% axis off

% xlim([0 165]);
% ylim([0 100]);

filename = 'res/floorplans/LargeFlat.dxf';
% [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% polys = c_Poly(:,1);
% edges = c_Line(:,1);
% circles = c_Cir(:,1);
env = environment.load(filename);
env.obstacles = {};
env_comb = environment.combine(env);
% mb.drawPolygon(env_comb.combined);
%%%
vpoly_full = mb.boost2visilibity(env_comb.combined);
vpoly = cellfun(@(x) simplifyPolyline(x, 80), vpoly_full, 'uniformoutput', false);
drawPolygon(vpoly);

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
%%%
E_r = g2d.radialPolygonSplitting(vpoly);
% cellfun(@(x) fun_draw_edge(x.edge), E_r);
%%%
E_r = g2d.steinerPointRemoval(vpoly, E_r);
P_c = g2d.convexPolygonCreation(vpoly, E_r);
cellfun(@(x) drawPolygon(x), P_c);

