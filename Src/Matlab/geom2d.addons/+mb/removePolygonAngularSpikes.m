function [poly_cleaned] = removePolygonAngularSpikes(poly, phi, center)
%% mergePolygonPointsAngularDist(poly, phi) merges the points in a polygon
% depending on their angular distance with respect to the center, which is a
% point of the poly. By default center is the first point.

poly_cleaned = poly;
if isempty(poly)
    return;
end

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
% outer_ring_cleaned = [];
outer_ring = poly(:, 2:end-1);

num_points = size(poly, 2);
id_first = 1;
id_second = 2;
id_third = 3;
point_dists = sqrt(sum((bsxfun(@minus, outer_ring, point_center).^2), 1));
merge_dists = [inf, point_dists.*tan(phi), inf];
% uniform indexing
point_dists = [0, point_dists, 0];

% fun_check_edge_spike = @(pe1, pe2, p3, dmin) mb.distancePointEdge(p3, [pe1;pe2]) < dmin;
poly_cleaned = [];
fun_pointOnEdge = @(p1, p2, pos) int64(double(p1)+double(-p1+p2)*pos);
hpt = [];
hply = [];
%%
while id_third <= num_points
    %%
    %     if ~isempty(hpt)
    %         delete(hpt); delete(hply);
%     %     end
%     cla
    p1 = poly(:, id_first);
    p2 = poly(:, id_second);
    p3 = poly(:, id_third);
    
%     hpt = mb.drawPoint([p1, p2, p3], 'marker',  '+');
%     hply = mb.drawPolygon([p1, p2, p3, p1], 'color', 'm');
    
    is_merged = false;
    [dist_merge_spike] = mb.distancePoints(p3, p1);
    inner_angle = mb.angle3PointsFast(p1,p2,p3);
    merge_dist_test = max(merge_dists([id_first, id_third]));
    if inner_angle < phi
    if dist_merge_spike < merge_dist_test...
            && mb.distancePoints(p2, p1) > dist_merge_spike && mb.distancePoints(p2, p3) > dist_merge_spike
%         poly_test = [point_center, [p1, p3], point_center];
%         if ~binpolygon(p2, poly_test,10);
%             write_log('mergeable')
%             mb.drawPoint([p1, p3], 'color', 'r');
            poly_cleaned = [poly_cleaned p1];
            is_merged = true;
%         end
    else
        [dist_left, nearest_left] = mb.distancePointEdge(p1, [p2; p3]);
        if  dist_left < merge_dist_test ...
            && nearest_left > 0 && nearest_left < 1
%             poly_test = [point_center, [p2, p3], point_center];
%             if ~binpolygon(p1, poly_test,10);
%                 write_log('left')
%                 mb.drawPoint([p1], 'color', 'r');
                point_nearest = fun_pointOnEdge(p2,p3, nearest_left);
                poly_cleaned = [poly_cleaned, point_nearest, p3];
                is_merged = true;
%             end
        else
            [dist_right, nearest_right] = mb.distancePointEdge(p3, [p1; p2]);
            if dist_right < merge_dist_test ...
                    && nearest_right > 0 && nearest_right < 1
%                 poly_test = [point_center, [p1, p2], point_center];
%                 if ~binpolygon(p1, poly_test,10);
%                     write_log('right')
%                     mb.drawPoint([p3], 'color', 'r');
                    point_nearest = fun_pointOnEdge(p1,p2, nearest_right);
                    poly_cleaned = [poly_cleaned, p1, point_nearest];
                    poly(:, id_third) = point_nearest;
                    is_merged = true;
%                 end
            end
        end
    end
    end
%     fprintf(1, 'ismerged : %d\n', is_merged)
%     fprintf(1, 'idf = %d, ids = %d, idt = %d \n', id_first, id_second, id_third);
    %%
    if is_merged
        %%
        id_first = id_third;
        id_second = id_first+1;
        id_third = id_second + 1;
        if id_third > num_points
            poly_cleaned = [poly_cleaned, poly(:, id_first)];
        end
    else
        poly_cleaned = [poly_cleaned, p1];
        id_first = id_second;
        id_second = id_third;
        id_third = id_third + 1;
    end
end
%%
if id_first <= num_points
    poly_cleaned = [poly_cleaned, poly(:, id_first)];
    if id_second <= num_points
        poly_cleaned = [poly_cleaned, poly(:, id_second)];
    end
end


return;
%% TEST with equal number of ring points to merge
phi = deg2rad(6);
poly = int64([ 344, 3844, 3844, 3464, 344, 344 ; 4351, 1200, 1587, 1587, 4764, 4351 ;  ]);
center = [ 3844 ; 1200 ; 1.5708 ;  ];
%%
poly_m = mb.mergePolygonPointsAngularDist(poly, phi, center);
poly_s = mb.removePolygonAngularSpikes(poly_m, phi, center);
%%
poly = fliplr(poly);
poly_m = mb.mergePolygonPointsAngularDist(fliplr(poly), phi, center);
poly_s = mb.removePolygonAngularSpikes(poly_m, phi, center);
%%
cla
mb.drawPolygon(poly, 'color', 'r');
mb.drawPoint(poly, 'color', 'r', 'marker', '*');
mb.drawPolygon(poly_m, 'color', 'g');
mb.drawPoint(poly_m, 'color', 'g');

mb.drawPolygon(poly_s, 'color', 'm');
mb.drawPoint(poly_s, 'color', 'm', 'marker', '+');

%% TEST Spike Middle
phi = deg2rad(6);
poly = int64([ 344, 3844, 3844, 3464, 344, 344 ; 4351, 1200, 1587, 1587, 4764, 4351 ;  ]);
center = [ 3844 ; 1200 ; 1.5708 ;  ];

%%
phi = deg2rad(6);
poly = int64([ 344, 3844, 3844, 3464, 344, 344, 344 ; 4351, 1200, 1587, 1587, 4764, 4666, 4351 ;  ]);
center = [ 3844 ; 1200 ; 1.5708 ;  ];
%%
poly_m = mb.mergePolygonPointsAngularDist(poly, phi, center);
poly_s = mb.removePolygonAngularSpikes(poly, phi,center);

cla
mb.drawPolygon(poly, 'color', 'r');
mb.drawPoint(poly, 'color', 'r', 'marker', '*');
mb.drawPolygon(poly_m, 'color', 'g');
mb.drawPoint(poly_m, 'color', 'g');

mb.drawPolygon(poly_s, 'color', 'm');
mb.drawPoint(poly_s, 'color', 'k', 'marker', '+', 'markersize', 20);
%% TEST
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
discretization.workspace.positions.additional = 50;

workspace_positions = Discretization.Workspace.iterative( environment, discretization );

% options = config;
%%%
% for npts = randi(800, 1, 20)
% npts = 100;
discretization.sensorspace.poses.additional = 0;
%%%
cla
Environment.draw(environment, false);
environment.obstacles{end+1} = environment.mountable;
environment.mountable = {};
discretization.sensorspace.resolution.angular = deg2rad(5);
debug.remove_spikes = false;
%%%
%% angular merge and spike not included
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, discretization, debug);
vfovs = mb.flattenPolygon(vfovs);
%% both included
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, discretization);
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
    poly_in = vfovs{id_vfov};
    [poly, tags] = mb.mergePolygonPointsAngularDist(poly_in, phi, center, debug);
%     [poly_s, tags] = mb.mergePolygonPointsAngularDist(poly, phi, center, debug);
    poly_s = mb.removePolygonAngularSpikes(poly, phi, center);
    cla;
    Environment.draw(environment, false);
    mb.drawPolygon(poly_in, 'color', 'r');
    mb.drawPoint(poly_in, 'color', 'r', 'marker', '*');
    mb.drawPolygon(poly, 'color', 'g');
    mb.drawPoint(poly, 'color', 'g');
    
        mb.drawPolygon(poly_s, 'color', 'm');
    mb.drawPoint(poly_s, 'color', 'k', 'marker', '+', 'markersize', 20);
    
%     mb.drawPolygon(poly_s, 'color', 'm');
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