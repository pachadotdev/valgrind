#' @title Debug Packages Containing C++ Code with 'valgrind'
#'
#' @description
#' 'valgrind' is a system for debugging and profiling that runs on
#' Unix-based systems. With 'valgrind' you can detect memory leaks in a variety
#' of ways. This package provides an R interface to the 'valgrind' tool suite.
#' It allows you to run 'valgrind' from R, retrieve the output, and process it
#' in R.
#'
#' @name valgrind-package
#' @importFrom utils install.packages
#' @useDynLib valgrind, .registration = TRUE
"_PACKAGE"

#' @title Sum Two Integers
#' @description Takes two integers and returns their sum.
#' @param a An integer.
#' @param b An integer.
#' @return The sum of the two integers.
#' @examples
#' a_plus_b(1, 2)
#' @export
a_plus_b <- function(a, b) {
  a_plus_b_(a, b)
}

# #' @title Sum Two Integers
# #' @description Takes two integers and returns their sum.
# #' @param a An integer.
# #' @param b An integer.
# #' @return Error!
# #' @examples
# #' intentional_leak(1, 2)
# #' @export
# intentional_leak <- function(a, b) {
#   intentional_leak_(a, b)
# }
