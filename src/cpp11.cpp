// Generated by cpp11: do not edit by hand
// clang-format off


#include "cpp11/declarations.hpp"
#include <R_ext/Visibility.h>

// code.cpp
int a_plus_b_(int a, int b);
extern "C" SEXP _valgrind_a_plus_b_(SEXP a, SEXP b) {
  BEGIN_CPP11
    return cpp11::as_sexp(a_plus_b_(cpp11::as_cpp<cpp11::decay_t<int>>(a), cpp11::as_cpp<cpp11::decay_t<int>>(b)));
  END_CPP11
}

extern "C" {
static const R_CallMethodDef CallEntries[] = {
    {"_valgrind_a_plus_b_", (DL_FUNC) &_valgrind_a_plus_b_, 2},
    {NULL, NULL, 0}
};
}

extern "C" attribute_visible void R_init_valgrind(DllInfo* dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
