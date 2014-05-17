function [distances, pointcombinations] = polygonInterpointDistances(bpoly)

    bpoly_double = cell2mat(mb.flattenPolygon(bpoly));
    pointcombinations = comb2unique(1:size(bpoly_double,2)-1);
    distances = sqrt(sum((bpoly_double(:,pointcombinations(:,1))-bpoly_double(:,pointcombinations(:,2))).^2, 1));