function [in, on] = inmultipolygon(multipolygon, positions)
%% INMULTIPOLYGON calculates if one or many points are inside a multipolygon
%   

[in_multipolygon] = cell2mat(cellfun(@(poly) binpolygon(positions, poly), multipolygon, 'uniformoutput', false)');
in = any(in_multipolygon, 1);
% on = any(on_multipolygon, 1);

return;
%% TEST
% close all; 
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;
environment = Environment.load(filename);

options = config.workspace;
placeable_ring = mb.expandPolygon(environment.boundary.ring, -options.wall_distance);
p1 = min(placeable_ring{1}, [], 2);
p2 = max(placeable_ring{1}, [], 2);
[gx, gy] = meshgrid(p1(1):10:p2(1), p1(2):10:p2(2));
positions = [gx(:), gy(:)]';

in = mb.inmultipolygon([environment.obstacles, environment.occupied], positions);
Environment.draw(environment);
hold on;
mb.drawPoint(positions(:, ~in), '.g');
mb.drawPoint(positions(:, in), '.r');
