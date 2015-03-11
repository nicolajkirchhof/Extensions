/**************************************************************************************
 * MATLAB MEX LIBRARY bclipper_lib.dll
 *
 * EXPORTS:
 *  void bclipper(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])
 *   whereas prhs = (ref_poly, clip_poly, method )
 *
 * PURPOSE: engine to compute boolean operations on two polygons
 *
 *  INPUTS:
 *  ref_poly, clip_poly = [chooseable, INT64 or DOUBLE supported]
 *          ring [2 n],
 *          polygon {[2 n], [...]}
 *
 *  method  = [int]
 *          0 - Difference (RefPol - ClipPol)
 *          1 - Intersection (Default)
 *          2 - Xor
 *          3 - Union
 *
 *  OUTPUTS:
 *  prhs {{[2 n], [...]}{...}}
 * Compilation:
 *  TO BE DONE
 * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>
 * History
 *  Original: 19-Dec-2012
 **************************************************************************************/

#include "stdafx.h"
#include "../clipper_ver6.2.1/cpp/clipper.hpp"
#pragma once

namespace bclipper {

#ifndef NO_MATLAB
void output_usage()
{
    mexPrintf(
        "/**************************************************************************************    \n"
        " * MATLAB MEX LIBRARY bclipper_lib.dll                                                     \n"
        " *                                                                                         \n"
        " * EXPORTS:                                                                                \n"
        " *  void bclipper(int & nlhs, mxArray *plhs[], int & nrhs, const mxArray *prhs[])          \n"
        " *   whereas prhs = (ref_poly, clip_poly, method, )                                        \n"
        " *                                                                                         \n"
        " * PURPOSE: engine to compute boolean operations on two polygons                           \n"
        " *                                                                                         \n"
        " *  INPUTS:                                                                                \n"
        " *  ref_poly, clip_poly = [chooseable, INT64 or DOUBLE supported]                          \n"
        " *          ring [2 n],                                                                    \n"
        " *          polygon {[2 n], [...]}                                                         \n"
        " *                                                                                         \n"
        " *  method  = [int]                                                                        \n"
        " *          0 - Difference (RefPol - ClipPol)                                              \n"
        " *          1 - Intersection (Default)                                                     \n"
        " *          2 - Xor                                                                        \n"
        " *          3 - Union                                                                      \n"
        " *                                                                                         \n"
        " *  OUTPUTS:                                                                               \n"
        " *  prhs {{[2 n], [...]}{...}}                                                             \n"
        " * Compilation:                                                                            \n"
        " *  TO BE DONE                                                                             \n"
        " * Author: Nicolaj Kirchhof <nicolaj.kirchhof@gmail.com>                                   \n"
        " * History                                                                                 \n"
        " *  Original: 19-Dec-2012                                                                  \n"
        " **************************************************************************************/   \n"
    );
}
#endif

std::ostringstream err;

namespace fn_prhs {
enum names {
    REF_POLY       = 0,
    CLIP_POLY      = 1,
    METHOD         = 2
    
};
}


enum ClipMethods {
    UNKNOWN_METHOD = -1,
    DIFFERENCE = 0,
    INTERSECTION = 1,
    XOR = 2,
    UNION = 3
};

ClipperLib::Path read_polygon(mxArray const * mx_array){

    ClipperLib::Path path_out;

    size_t num_points = mxGetN(mx_array);
    path_out.resize(num_points);

    size_t point_sz = mxGetM(mx_array);


    if (point_sz != 2) {
        mexErrMsgTxt("Point size is not [2 n] !!!");
    };
    
    int64_T(*ml_array_ptr)[2] = (int64_T(*)[2]) mxGetPr(mx_array);

    for (size_t id_point = 0; id_point < num_points; ++id_point){
        ClipperLib::IntPoint pt(ml_array_ptr[id_point][0], ml_array_ptr[id_point][1]);
        path_out[id_point] = pt;
    }
    return path_out;
}

ClipperLib::Paths read_polygons(mxArray const *mx_array)
{
    ClipperLib::Paths paths_out;
    // check if ring or polygon is given
    if (!mxIsCell(mx_array)) {
        paths_out << read_polygon(mx_array);
    } else {
        // we do not care for column or row vector of multi_polygon
        size_t sz = mxGetM(mx_array) > mxGetN(mx_array) ? mxGetM(mx_array) : mxGetN(mx_array);

        // check if multi_poly is empty (size == 0)
        if (sz == 0) { return paths_out; }

        // resize to num of polygons
        paths_out.resize(sz);

        for(unsigned idp = 0; idp < sz; ++idp) {
           paths_out[idp] = read_polygon(mxGetCell(mx_array, idp));
        }
    }
    return paths_out;

}

mxArray *write_multipolygon(const ClipperLib::Paths & poly_out)
{
  
    mxArray *mpoly_out_matlab = mxCreateCellMatrix(1, poly_out.size());


    //for (ClipperLib::Paths::const_iterator it = poly_out.begin(); it != poly_out.end(); ++it){
    for (size_t id = 0; id < poly_out.size(); ++id){
        // assign outer ring
        size_t num_points = poly_out[id].size();
        mxArray *points_out_matlab = mxCreateNumericMatrix(2, num_points, mxINT64_CLASS, mxREAL);
        int64_T(*ml_array_ptr)[2] = (int64_T(*)[2]) mxGetPr(points_out_matlab);

        for (int idmla = 0; idmla < num_points; ++idmla) {
            ml_array_ptr[idmla][0] = poly_out[id][idmla].X;
            ml_array_ptr[idmla][1] = poly_out[id][idmla].Y;
        }

        mxSetCell(mpoly_out_matlab, id, points_out_matlab);
    }
    return mpoly_out_matlab;
}

#define MIN_ARGUMENTS 2
#define MAX_ARGUMENTS 3

//=========================Exported=========================//
void bclipper(int &nlhs, mxArray *plhs[],
               int &nrhs, const mxArray *prhs[])
{
    // check input size
    if((nrhs < MIN_ARGUMENTS) || (nrhs > MAX_ARGUMENTS)) {
        output_usage();
        return;
    }

    ClipperLib::ClipType clip_type = ClipperLib::ClipType::ctIntersection;
    if(nrhs >= fn_prhs::METHOD ) {
        int ct_in = (int)mxGetScalar(prhs[fn_prhs::METHOD]);
        switch (ct_in)
        {
        case ClipMethods::INTERSECTION:
            clip_type = ClipperLib::ClipType::ctIntersection;
            break;
        case ClipMethods::DIFFERENCE:
            clip_type = ClipperLib::ClipType::ctDifference;
            break;
        case ClipMethods::UNION:
            clip_type = ClipperLib::ClipType::ctUnion;
            break;
        case ClipMethods::XOR:
            clip_type = ClipperLib::ClipType::ctXor;
            break;
        default:
            err << "Cliptype: " << ct_in << " is unknown! ";

        }
        }
        

    const mxArray *p_clip = prhs[fn_prhs::CLIP_POLY];
    const mxArray *p_ref = prhs[fn_prhs::REF_POLY];

    if (nlhs > 1){
        plhs[1] = mxCreateDoubleScalar(0);
    }

    //// fast lane, check if one of the polygons is empty
    if (mxIsEmpty(p_ref)) {
        if(clip_type == ClipperLib::ClipType::ctIntersection || clip_type == ClipperLib::ClipType::ctDifference) { 
            plhs[fn_prhs::REF_POLY] = mxCreateCellMatrix(1, 1); 
        }
        else { plhs[0] = mxDuplicateArray(p_clip); }

    } else if (mxIsEmpty(p_clip)) {
        if(clip_type == ClipperLib::ClipType::ctIntersection) { plhs[0] = mxCreateCellMatrix(1, 1); }
        else { plhs[0] = mxDuplicateArray(p_ref); }

    }
    else{
        ClipperLib::Paths ref_poly = read_polygons(prhs[fn_prhs::REF_POLY]);
        ClipperLib::Paths clip_poly = read_polygons(prhs[fn_prhs::CLIP_POLY]);
        ClipperLib::Clipper clipper;
        clipper.AddPaths(ref_poly, ClipperLib::PolyType::ptSubject, true);
        clipper.AddPaths(clip_poly, ClipperLib::PolyType::ptClip, true);
        ClipperLib::Paths out_poly;
        clipper.Execute(clip_type, out_poly);

        plhs[0] = write_multipolygon(out_poly);

        if (nlhs > 1){
            double area = 0;

            for (ClipperLib::Paths::const_iterator it = out_poly.begin(); it != out_poly.end(); ++it){
                area += ClipperLib::Area(*it);
            }

            *mxGetPr(plhs[1]) = area;
        }

    }

}

};
