function [array_1, array_2] = split_array_wo_index(array, index)
%% SPLIT_ARRAY splits an array into two parts based on the given index, whose 
%   element won't be part of the splits

[array_1] = array(1:index-1);
[array_2] = array(index+1:end);