#ifndef POLYMAKE_WRAP_INCLUDES
#define POLYMAKE_WRAP_INCLUDES

#include <string>
#include <iostream>

#include "jlcxx/jlcxx.hpp"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wlogical-op-parentheses"
#pragma clang diagnostic ignored "-Wshift-op-parentheses"

#include <polymake/Main.h>
#include <polymake/Matrix.h>
#include <polymake/Vector.h>
#include <polymake/Set.h>
#include <polymake/Array.h>
#include <polymake/IncidenceMatrix.h>
#include <polymake/Rational.h>
#include <polymake/QuadraticExtension.h>
#include <polymake/polytope/solve_LP.h>

#include <polymake/perl/calls.h>

#include <polymake/perl/macros.h>
#include <polymake/perl/wrappers.h>

#pragma clang diagnostic pop

#endif
