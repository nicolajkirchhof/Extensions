
#include "stdafx.h"
#include "bclipper.hpp"

#ifndef NO_MATLAB
void mexFunction(int nlhs, mxArray *plhs[],
                           int nrhs, const mxArray *prhs[])
{
    bclipper::bclipper(nlhs, plhs, nrhs, prhs);
}
#endif
