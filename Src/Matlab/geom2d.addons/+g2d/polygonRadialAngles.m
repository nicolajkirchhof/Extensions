function [ normal_angles, poly_angles ] = polygonRadialAngles( gpoly )
%POLYGONVERTICIES Summary of this function goes here
%   Detailed explanation goes here
import g2d.*;
poly_angles = polygonAngles(gpoly);
extract = false;
if ~iscell(gpoly)
    gpoly = {gpoly};
    extract = true;
end
 
fun_lineangles = @(x) angle2Points(x, circshift(x,-1));
lineangles = cellfun(fun_lineangles, gpoly, 'uniformoutput', false);

fun_anglediff = @(x, y) angle(exp(1i*(x+y.*0.5)));
normal_angles = cellfun(fun_anglediff, lineangles, poly_angles, 'uniformoutput', false);

if extract
    normal_angles = cell2mat(normal_angles);
    poly_angles = cell2mat(poly_angles);
end


return
%% Testing

gpoly = {[
        5868         552
        5868        4543
        2570        4540
        2570        4640
        5868        4643
        5868        8735
        2570        8735
        2570        5535
        2470        5535
        2470        7715
         107        7715
         107        5915
        1765        5915
        1765        5815
        1365        5815
        1365        3645
        1791        3645
        1791        3545
        1365        3545
        1365         552
        3091         552
        3091        3545
        2570        3545
        2570        3645
        3191        3645
        3191         552]};
    
% polygon_corners = cellfun(@(x) [circshift(x, 1), x, circshift(x, -1)], gpoly, 'uniformoutput', false);
% polygon_angles = cellfun(@(x) angle3Points(x(:, 1:2), x(:, 3:4), x(:, 5:6)), polygon_corners, 'uniformoutput', false);

% g2d.polygonRadialAngles(gpoly);