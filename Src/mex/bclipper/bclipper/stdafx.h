// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include <iostream>
#include <list>
#include <string>
#include <sstream>
#include <vector>

#ifndef NO_MATLAB
//Gives Matlab interfacing.  Linkage block specifies linkage
//convention used to link header file; makes the C header suitable for
//C++ use.  "mex.h" also includes "matrix.h" to provide MX functions
//to support Matlab data types, along with the standard header files
//<stdio.h>, <stdlib.h>, and <stddef.h>.
#include <math.h>
#include <mex.h>
//#include <engine.h>
//#define  BUFSIZE 256
#endif

