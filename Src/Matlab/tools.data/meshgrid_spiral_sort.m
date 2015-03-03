function [grid_sorted] = meshgrid_spiral_sort(grid_x, grid_y)

% grid_x = grid_x;
% grid_y = grid_y;
grid_sorted = nan(2, numel(grid_x));
[y_length, x_length] = size(grid_x);
num_rings = ceil(min([y_length, x_length])/2);
% num_rings = ceil(y_length/2);
cnt = 1;
ring = 0;
%%
while ring < num_rings
    %%
    
    num_line = x_length-ring*2;
    x_up_index = 1+ring:x_length-ring;
    grid_sorted(:, cnt:cnt+num_line-1) = [grid_x(ring+1, x_up_index); grid_y(ring+1, x_up_index)];
    cnt = cnt+num_line;
    
    num_line = y_length-1-ring*2;
    y_up_index = ring+2:y_length-ring;
    grid_sorted(:, cnt:cnt+num_line-1) = [grid_x(y_up_index, end-ring), grid_y(y_up_index, end-ring)]';
    cnt = cnt+num_line;
    
    num_line = x_length-1-ring*2;
    x_down_index = x_length-1-ring:-1:ring+1;
    grid_sorted(:, cnt:cnt+num_line-1) = [grid_x(end-ring, x_down_index); grid_y(end-ring, x_down_index)];
    cnt = cnt+num_line;
    
    num_line = y_length-2-ring*2;
    y_down_index = y_length-1-ring:-1:2+ring;
    grid_sorted(:, cnt:cnt+num_line-1) = [grid_x(y_down_index, ring+1), grid_y(y_down_index, ring+1)]';
    cnt = cnt+num_line;
    
    ring = ring+1;
end
%%
return;

%% TEST uneven
[gx, gy] = meshgrid([1:3], [1:3]);
ref_gs = [ 1, 2, 3, 3, 3, 2, 1, 1, 2 ; 1, 1, 1, 2, 3, 3, 3, 2, 2 ];
gs = meshgrid_spiral_sort(gx, gy);
log_test(all(all(gs==ref_gs)), 'Uneven number of rows');

%% TEST even
[gx, gy] = meshgrid([1:4], [1:4]);

gs = meshgrid_spiral_sort(gx, gy);

cla, hold on;
for i = 1:size(gs,2)
    mb.drawPoint(gs(:,i))
    pause
end
    
end


