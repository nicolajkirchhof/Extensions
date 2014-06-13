function [dist, pos] = distancePointEdge(varargin)
%wrapper for transposed points

varargin = cellfun(@fun_transp, varargin, 'uniformoutput', false);
[dist, pos] = distancePointEdge(varargin{:});

function x = fun_transp(x)
if isnumeric(x)
    x = double(x');
end

return;
%% TEST

p1 = int64([0; 0]);
p2 = int64([0; 20]);
p3 = int64([5; 10]); d3 = 5;
p4 = int64([10; 30]); d4 = sqrt(2*10^2);
%%%
d3t = mb.distancePointEdge(p3, [p1; p2])
log_test(d3t==d3, 'Defined input');

%%%
d4t = mb.distancePointEdge(p4, [p1;p2])
log_test(abs(d4t-d4)<eps, 'Defined input');