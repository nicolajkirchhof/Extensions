function [poly_merged, is_changed] = mergePolygonPointsAngularDist(poly, phi, center, debug)
%% mergePolygonPointsAngularDist(poly, phi) merges the points in a polygon 
% depending on their angular distance with respect to the center, which is a 
% point of the poly. By default center is the first point.


poly_merged = [];
if isempty(poly)
    is_changed = false;
    return;
end

if nargin < 4 || isempty(debug)
    debug.verbose = false;
    debug.log = @(txt) write_log(txt);
else
    debug.log = @(txt) 1;
end
is_changed = true;
while is_changed
% if nargin > 2
    %%
    point_center = int64(center(1:2));
    is_center = (poly(1,1:end-1)==point_center(1))&(poly(2,1:end-1)==point_center(2));
    if any(is_center)
         id_center = find(is_center);
    else
        dist_center = sum(bsxfun(@minus, poly(:,1:end-1), point_center).^2,1);
        [~, id_center] = min(dist_center);
    end
    poly = [circshift(poly(:, 1:end-1), -(id_center-1),2), point_center];
% else
%     point_center = poly(:,1);
% end
%%%
outer_ring = poly(:, 2:end-1);
id_start = 1;
id_next = 2;

id_end = size(outer_ring, 2);
id_previous = id_end -1;

ids_outer_ring = [id_start, id_end];
point_dists = sqrt(sum((bsxfun(@minus, outer_ring, point_center).^2), 1));
merge_dists = point_dists.*tan(phi);
is_all_merged = false;
is_changed = false;
tag = [];
if debug.verbose
    cla;
gh = {};
% Environment.draw(environment, false);
mb.drawPolygon(poly);
hold on;
end
%%
while ~is_all_merged 
    %%
    if debug.verbose; 
        cellfun(@delete, gh); 
        gh = {}; 
        gh{end+1} = mb.drawPoint(outer_ring(:,[id_previous, id_end]), 'color', [0.3 0.3 0.3], 'marker', '+', 'markersize', 20);
        gh{end+1} = mb.drawPoint(outer_ring(:,[id_start, id_next]), 'color', [0.6 0.6 0.6], 'marker', '+', 'markersize', 20);
    end
    merge_dist_min_forward = min(merge_dists([id_start, id_next]));
    merge_dist_min_backward = min(merge_dists([id_previous, id_end]));
    
    edge_length_forward = sqrt(sum((outer_ring(:,id_start)-outer_ring(:, id_next)).^2, 1));
    edge_length_backward = sqrt(sum((outer_ring(:,id_previous)-outer_ring(:, id_end)).^2, 1));

    is_mergeable_forward = merge_dist_min_forward > edge_length_forward;
    is_mergeable_backward = merge_dist_min_backward > edge_length_backward;
    
    %%% check if merge point is valid
    is_inside_foreward = true;
    if is_mergeable_forward
    poly_forward = [point_center, outer_ring(:,[id_start, id_next+1]), point_center];
    is_inside_foreward = binpolygon(outer_ring(:,id_next), poly_forward,10);
%      if is_inside_foreward
%         debug.log('left tagged')
%         tag = [tag, id_next];
%     end
    if debug.verbose
      gh{end+1} = mb.drawPoint(outer_ring(:,id_next), 'color', 'k');
      gh{end+1} = mb.drawPolygon(poly_forward, 'color', 'm');
    end
    end
    is_inside_backward = true;
    if is_mergeable_backward 
    poly_backward = [point_center, outer_ring(:,[id_previous-1, id_end]), point_center];
    is_inside_backward = binpolygon(outer_ring(:,id_previous), poly_backward,10);
%     if is_inside_backward
%         debug.log('right tagged');
%         tag = [tag, id_previous];
%     end
    if debug.verbose
    gh{end+1} = mb.drawPoint(outer_ring(:,id_previous), 'color', 'r');
    gh{end+1} = mb.drawPolygon(poly_backward, 'color', 'b');
    end
    end
%%%
    if id_next < id_previous
        % pt must be added
        if is_inside_foreward
            ids_outer_ring = [ids_outer_ring, id_next];
            id_start = id_next;
        end
        if is_inside_backward
            ids_outer_ring = [ids_outer_ring, id_previous];
            id_end = id_previous;
        end
        if ~is_inside_foreward && ~is_inside_backward
            is_changed = true;
        end
        id_next = id_next + 1;
        id_previous = id_previous - 1;
    elseif id_next == id_previous
        if is_inside_foreward || is_inside_backward
            ids_outer_ring = [ids_outer_ring, id_next];
        end
        is_all_merged = true;
    end
    % last index
    if id_next > id_previous
        if is_inside_backward && is_inside_foreward
            is_all_merged = true;
        elseif is_mergeable_forward
            id_previous = id_next;
        else%if is_mergeable_backward
            id_next = id_previous;
        end
%         is_all_merged = true;
    end
    if debug.verbose
    fprintf(1, 'ids=%d idn=%d idp=%d ide=%d merged=%d changed=%d\n ids:',  [id_start, id_next, id_previous, id_end, is_all_merged, is_changed]);
    fprintf(1, '%d ', ids_outer_ring);
%      fprintf(1, '\n changed: %');
%     fprintf(1, '%d ', tag);
    fprintf(1, '\n');
    end 
end
%%
ids_outer_ring_sorted = unique(ids_outer_ring);
poly = [point_center, outer_ring(:, ids_outer_ring_sorted), point_center];
end
poly_merged = poly;


% tags = false(1, size(poly_merged, 2));
% [~, id_tags] = intersect( ids_outer_ring_sorted, tag );
% tags(id_tags+1) = true;
% mb.drawPoint(poly_merged(:, tags), 'color', 'r');

return;
%%
phi = 0.1047;
poly = [ 1365, 5819, 2570, 2570, 2470, 1447, 1365, 1365 ; 4360, 4173, 8103, 5090, 5090, 5370, 5370, 4360 ;  ];
center = [ 5819 ; 4173 ; 2.26164 ;  ];

debug.verbose = true;
%     center = sensor_poses(:, id_vfov);
%     poly = vfovs{id_vfov};
    [poly_m, tags] = mb.mergePolygonPointsAngularDist(poly, phi, center,debug);
%     [poly_s, tags] = mb.mergePolygonPointsAngularDist(poly_m, phi, center, debug);
    
    cla;
%    Environment.draw(environment, false); 
mb.drawPolygon(poly, 'color', 'r');
mb.drawPoint(poly, 'color', 'r', 'marker', '*');
mb.drawPolygon(poly_m, 'color', 'g');
mb.drawPoint(poly_m, 'color', 'g');
mb.drawPoint(poly_m(:, tags), 'color', 'm', 'marker', '^', 'markersize', 18);
%         mb.drawPolygon(poly_s, 'color', 'm');
%     mb.drawPoint(poly_s, 'color', 'k', 'marker', '+', 'markersize', 20);

disp(id_vfov);
pause;

%% TEST with equal number of ring points to merge
phi = 0.06;
poly = int64([ 344, 3844, 3844, 3464, 344, 344 ; 4351, 1200, 1587, 1587, 4764, 4351 ;  ]);
center = [ 3844 ; 1200 ; 1.5708 ;  ];
%%
poly_m = mb.mergePolygonPointsAngularDist(poly, phi, center);

mb.drawPolygon(poly, 'color', 'r');
mb.drawPoint(poly, 'color', 'r', 'marker', '*');
mb.drawPolygon(poly_m, 'color', 'g');
mb.drawPoint(poly_m, 'color', 'g');

%%
phi = 0.06;
poly = int64([ 344, 3844, 3844, 3464, 344, 344, 344 ; 4351, 1200, 1587, 1587, 4764, 4666, 4351 ;  ]);
center = [ 3844 ; 1200 ; 1.5708 ;  ];
%%
poly_m = mb.mergePolygonPointsAngularDist(poly, phi, center);

mb.drawPolygon(poly, 'color', 'r');
mb.drawPoint(poly, 'color', 'r', 'marker', '*');
mb.drawPolygon(poly_m, 'color', 'g');
mb.drawPoint(poly_m, 'color', 'g');

%% TEST
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
options = Configurations.Discretization.iterative;

environment = Environment.load(filename);
options.workspace.positions.additional = 50;

workspace_positions = Discretization.Workspace.iterative( environment, options );

% options = config;
%%%
% for npts = randi(800, 1, 20)
% npts = 100;
options.sensorspace.poses.additional = 0;
%%%
cla
Environment.draw(environment, false);
environment.obstacles{end+1} = environment.mountable;
environment.mountable = {};
options.sensorspace.resolution.angular = deg2rad(5);
debug.remove_spikes = false;

%% angular merge and spike not included
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, options, debug);
vfovs = mb.flattenPolygon(vfovs);
%% both included
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, options);
% Discretization.Sensorspace.draw(sensor_poses);
% cellfun(@(p) mb.drawPoint(p{1}{1}(:,2), 'color', 'g'), vfovs)
% Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
% Discretization.Sensorspace.draw(sensor_poses_initial_in, 'r');
% disp(npts);
%%
for id_vfov = 1:numel(vfovs)
    %%
    phi = deg2rad(6);
    debug.verbose = false;
    center = sensor_poses(:, id_vfov);
    poly = vfovs{id_vfov};
    [poly_m, tags] = mb.mergePolygonPointsAngularDist(poly, phi, center,debug);
%     [poly_s, tags] = mb.mergePolygonPointsAngularDist(poly_m, phi, center, debug);
    
    cla;
   Environment.draw(environment, false); 
mb.drawPolygon(poly, 'color', 'r');
mb.drawPoint(poly, 'color', 'r', 'marker', '*');
mb.drawPolygon(poly_m, 'color', 'g');
mb.drawPoint(poly_m, 'color', 'g');
mb.drawPoint(poly_m(:, tags), 'color', 'm', 'marker', '^', 'markersize', 18);
%         mb.drawPolygon(poly_s, 'color', 'm');
%     mb.drawPoint(poly_s, 'color', 'k', 'marker', '+', 'markersize', 20);

disp(id_vfov);
pause;
end


%%%
%% fast merge test
is_mergeable = true;
dist_merge = sum((bsxfun(@minus, outer_ring, point_center).^2), 1).*tan(phi);
for id_edge = 1:size(outer_ring, 2)-1
    
dist_merge_mins = arrayfun(@(p1, p2) min([p1, p2]), dist_merge(1:end-1), dist_merge(2:end));
length_edges = sum((outer_ring(:,1:end-1)-outer_ring(:, 2:end)).^2, 1);
% length_edges_min = min(length_edges);

is_mergeable = dist_merge_mins > length_edges;
% fill to move merged points to right location
is_mergeable = [is_mergeable(1:ceil(end/2)), is_mergeable(ceil(end/2):end)];
%%
outer_ring = outer_ring(:,~is_mergeable);
end