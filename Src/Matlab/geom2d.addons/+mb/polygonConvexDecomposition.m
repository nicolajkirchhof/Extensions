function [P_c, E_r] = polygonConvexDecomposition(bpoly)

vpoly = mb.boost2visilibity(bpoly);
E_r = g2d.radialPolygonSplitting(vpoly);
E_r = g2d.steinerPointRemoval(vpoly, E_r);
P_c = g2d.convexPolygonCreation(vpoly, E_r);

return; 

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
bpoly = mb.visilibity2boost(vpoly);
P_c = mb.polygonConvexDecomposition(bpoly);
%%

%%
cla;
cellfun(@(x) drawEdge(x.edge), E_r);

%%
