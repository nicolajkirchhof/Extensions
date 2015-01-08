function [P_c] = convexPolygonCreation(vpoly, E_r)
% REWRITE ACCORDING TO PAPER
if nargin < 2; verbose = false; end

%% Calculate all additional polygon points and all polygon edges


for id_er = 1:numel(E_r)
    vpoly_edges_cell = cellfun(@(x) [x(1:end, :), [x(2:end, :);x(1,:)]], vpoly, 'uniformoutput', false);
    distance_polypoints = cellfun(@(x) distancePoints(E_r{id_er}.end, x), vpoly, 'uniformoutput', false);
    is_poly_point = any(cellfun(@(x) any(x <= 1), distance_polypoints));
    
    if ~is_poly_point
        %%
        distance_polyedges = cellfun(@(x) distancePointEdge(E_r{id_er}.end, x), vpoly_edges_cell, 'uniformoutput', false);
        id_poly = cellfun(@(x) any(x <= 1), distance_polyedges);
        id_edge = find(distance_polyedges{id_poly} <= 1);
        vpoly{id_poly} = [vpoly{id_poly}(1:id_edge, :); E_r{id_er}.end; vpoly{id_poly}(id_edge+1:end, :)];
    end
end
%%
vpoly_edges_cell = cellfun(@(x) [x(1:end, :), [x(2:end, :);x(1,:)]], vpoly, 'uniformoutput', false);
vpoly_edges = cell2mat(vpoly_edges_cell(:));

%     cla
%     drawEdge(vpoly_edges)
E_r_edges_cell = cellfun(@(x) [x.edge; [x.end, x.begin]], E_r, 'uniformoutput', false);
E_r_edges = cell2mat(E_r_edges_cell(:));

%%
convex_rings = {};
while ~isempty(E_r_edges)
    %%
    ring = E_r_edges(1, :);
    E_r_edges = E_r_edges(2:end, :);
    %%
    while distancePoints(ring(1,1:2), ring(end, 3:4))>1
        %%
        e_r = ring(end, :);
        next_er_dist = distancePoints(e_r(3:4), E_r_edges(:, 1:2));
        next_er_cand = next_er_dist < 1;
        next_er_ang = edgeAngle(E_r_edges(next_er_cand, :));
        %% diff of ang starting at the same point
%         next_er_ang_diff = arrayfun(@(x) angleAbsDiff(edgeAngle(e_r([3:4, 1:2])), x), next_er_ang); 
        next_er_ang_diff = arrayfun(@(x) normalizeAngle(angleDiff(edgeAngle(e_r([3:4, 1:2])), x)), next_er_ang); 
        % exclude backward edge
        next_er_ids = find(next_er_cand);
        bw_edge_id = find(next_er_ang_diff < 1e-6);
        if ~isempty(bw_edge_id)
            next_er_ids(bw_edge_id) = [];
%             next_er_ang(bw_edge_id) = [];
            next_er_ang_diff(bw_edge_id) = [];
        end
        
        
        next_poly_dist_fw = distancePoints(e_r(3:4), vpoly_edges(:, 1:2) );
        next_poly_cand_fw = next_poly_dist_fw < 1;
        
        next_poly_dist_bw = distancePoints(e_r(3:4), vpoly_edges(:, 3:4) );
        next_poly_cand_bw = next_poly_dist_bw < 1;
        
        next_poly_edges = [vpoly_edges(next_poly_cand_fw, :); vpoly_edges(next_poly_cand_bw, [3:4, 1:2])];
        next_poly_ang = edgeAngle(next_poly_edges);
%         next_poly_ang_diff = arrayfun(@(x) angleAbsDiff(edgeAngle(e_r([3:4, 1:2])), x), next_poly_ang); 
        next_poly_ang_diff = arrayfun(@(x) normalizeAngle(angleDiff(edgeAngle(e_r([3:4, 1:2])), x)), next_poly_ang); 
        next_poly_ids = [find(next_poly_cand_fw), find(next_poly_cand_bw)];
               
        if  (isempty(next_poly_ang_diff) && ~isempty(next_er_ang_diff))... 
                || (~isempty(next_poly_ang_diff) && ~isempty(next_er_ang_diff) && min(next_er_ang_diff) < min(next_poly_ang_diff))
            [~, id_min] = min(next_er_ang_diff);
            ring = [ring; E_r_edges(next_er_ids(id_min), :)];
            E_r_edges(next_er_ids(id_min), :) = [];            
            
        elseif (~isempty(next_poly_ang_diff) && isempty(next_er_ang_diff))... 
                || (~isempty(next_poly_ang_diff) && ~isempty(next_er_ang_diff) && min(next_er_ang_diff) > min(next_poly_ang_diff))
            [~, id_min] = min(next_poly_ang_diff);
            ring = [ring; next_poly_edges(id_min, :)];
            vpoly_edges(next_poly_ids(id_min), :) = [];
        else
            error('This cannot happen');
        end
%         cla
%         h0 = drawEdge(vpoly_edges);
%         h1 = drawEdge(next_poly_edges, 'marker', 'o', 'color', [0 1 0]);
%         h2 = drawEdge(e_r, 'marker', 'o', 'color', [0 1 0]);
%         h3 = drawEdge(ring, 'marker', 'x', 'color', [1 0 0]);
%         delete([h0(:); h1(:); h2(:); h3(:)]);
    end
    convex_rings = [convex_rings(:); {ring}];
end
P_c = cellfun(@(x) x(:, 1:2), convex_rings, 'uniformoutput', false);



return;
%% Tests
filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);
cla;
axis equal;
% vpoly = c_Poly(:,1);
vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
% vpoly{4} = circshift(vpoly{4}, -1, 1);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
drawPolygon(vpoly);
% vpoly(1) = cellfun(@reversePolygon, vpoly(1), 'UniformOutput', false);
% bpoly = mb.visilibity2boost(vpoly);
E_r = g2d.radialPolygonSplitting(vpoly);
[E_r] = g2d.steinerPointRemoval(vpoly, E_r);
P_c = g2d.convexPolygonCreation(vpoly, E_r);

if numel(P_c) ~= 8
    error('Number of Polygons wrong');
end


%% Test with merge
filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);
cla;
hold on;
axis equal;
% vpoly = c_Poly(:,1);
vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
% vpoly{4} = circshift(vpoly{4}, -1, 1);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
%%%
vpoly{1} = [vpoly{1}; vpoly{1}(1,1) 5000; vpoly{1}(1,1)+200 4500; vpoly{1}(1,1) 4000];
% vpoly(1) = cellfun(@reversePolygon, vpoly(1), 'UniformOutput', false);
drawPolygon(vpoly);
E_r = g2d.radialPolygonSplitting(vpoly);
% [E_r] = mb.steinerPointRemoval(vpoly, E_r)
[E_r] = g2d.steinerPointRemoval(vpoly, E_r);
cellfun(@(x) drawEdge(x.edge), E_r);
%%%
P_c = g2d.convexPolygonCreation(vpoly, E_r);

if numel(P_c) ~= 10
    error('Number of Polygons wrong');
end

cla;
cellfun(@(x) drawEdge(x.edge), E_r);

%%

