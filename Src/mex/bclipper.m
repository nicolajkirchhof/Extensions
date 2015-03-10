%/**************************************************************************************
% * MATLAB MEX LIBRARY bclipper_lib.dll
% *
% * EXPORTS:
% *  void bclipper(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
% *   whereas prhs = (ref_poly, clip_poly, method )
% *
% * PURPOSE: engine to compute boolean operations on two polygons
% *
% *  INPUTS:
% *  ref_poly, clip_poly = [chooseable, INT64 or DOUBLE supported]
% *          ring [2 n],
% *          polygon {[2 n], [...]}
% *
% *  method  = [int]
% *          0 - Difference (RefPol - ClipPol)
% *          1 - Intersection (Default)
% *          2 - Xor
% *          3 - Union
% *
% *  OUTPUTS:
% *  prhs {{[2 n], [...]}{...}}
% * Compilation:
% *  TO BE DONE
% * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
% * History
% *  Original: 19-Dec-2012
% **************************************************************************************/
