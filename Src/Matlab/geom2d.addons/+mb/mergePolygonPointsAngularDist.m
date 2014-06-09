function [poly] = mergePolygonPointsAngularDist(poly, phi, center)
%% mergePolygonPointsAngularDist(poly, phi) merges the points in a polygon 
% depending on their angular distance with respect to the center, which is a 
% point of the poly. By default center is the first point.


if nargin < 3
    %%
    point_center = int64(center(1:2));
    is_center = (poly(1,1:end-1)==center(1))&(poly(2,1:end-1)==center(2));
    poly = [circshift(poly(:, 1:end-1), -(find(is_center)-1),2), point_center];
    outer_ring = poly(:, 2:end-1);
end

%% fast merge test
dist_merge = sum((bsxfun(@minus,poly(:, 2:end-1), point_center).^2)*tan(phi), 1);
dist_merge_mins = arrayfun(@(p1, p2) min([p1, p2]), dist_merge(1:end-1), dist_merge(2:end));
length_edges = sum((poly(:, 2:end-2)-poly(:, 3:end-1)).^2, 1);
% length_edges_min = min(length_edges);

is_mergeable = dist_merge_mins > length_edges;
ids_to_merge = find(is_mergeable);
% id from -> id to
merge_list = zeros(numel(ids_to_merge), 2); 
%%
for id = ids_to_merge
    if id <= numel(is_mergeable)/2
        merge_list
    end
end


% if dist_center_max 

%%

num_points = size(poly_open, 2);

id_start = 2;
id_end = num_points-1;
while id_start < id_end
    %% forward
    if point



return;
%% TEST with POly to merge
phi = deg2rad(0.06);
poly = int64([ 344, 3844, 3844, 3464, 344, 344 ; 4351, 1200, 1587, 1587, 4764, 4351 ;  ]);
center = [ 3844 ; 1200 ; 1.5708 ;  ];


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
npts = 100;
options.sensorspace.poses.additional = npts;
%%%
cla
Environment.draw(environment, false); 
%%%
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, options);

Discretization.Sensorspace.draw(sensor_poses);
cellfun(@(p) mb.drawPoint(p{1}{1}(:,2), 'color', 'g'), vfovs)
% Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
% Discretization.Sensorspace.draw(sensor_poses_initial_in, 'r');
% disp(npts);
%%
phi = deg2rad(0.1);
poly = int64([ 3765, 344, 344, 740, 1057, 1180, 2004, 2804, 3464, 3464, 3844, 3844, 3765, 3765 ; 5231, 8312, 2398, 2398, 1354, 1362, 1512, 1758, 2052, 2577, 2577, 3490, 3599, 5231 ;  ]);
center = [ 344 ; 8312 ; 4.71239 ;  ];
