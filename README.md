
<!-- README.md is generated from README.Rmd. Please edit that file -->

# valgrind <img src="man/figures/logo.svg" align="right" height="139" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/pachadotdev/valgrind/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pachadotdev/valgrind/actions/workflows/R-CMD-check.yaml)
[![BuyMeACoffee](https://raw.githubusercontent.com/pachadotdev/buymeacoffee-badges/main/bmc-donate-white.svg)](https://buymeacoffee.com/pacha)
<!-- badges: end -->

The goal of valgrind is to use the ‘Valgrind’ tool to detect memory
leaks in R packages that contain C++ code.

## Installation

**On Windows, ‘Valgrind’ is only available from the Windows Subsystem
for Linux (WSL).**

You can install the development version of valgrind from GitHub with:

``` r
remotes::install_github("pachadotdev/valgrind")
```

## Example

**If you use compiler optimizations, check how to disable those for
easier debugging in my [C++ for R
Users](https://pacha.dev/cpp11-for-r-users/08-r-packages-expanded.html#compiler-setup)
guide.**

If you have an R package containing the next C++ function:

``` cpp
[[cpp11::register]] int a_plus_b_(int a, int b) {
  return a + b;
}
```

You can save a script with a name such as `dev/test.R` and include the
next code:

``` r
a_plus_b_(1, 2)
```

And then test your code with the next command:

``` r
valgrind::test_memory(".", "dev/test.R")  
```

The output will be the following list:

``` r
> valgrind::test_memory(".", "dev/test.R")  
$heap_summary
[1] "in use at exit: 46,156,337 bytes in 10,032 blocks"                        
[2] "total heap usage: 21,450 allocs, 11,418 frees, 65,445,430 bytes allocated"

$leak_summary
[1] "definitely lost: 0 bytes in 0 blocks"                        
[2] "indirectly lost: 0 bytes in 0 blocks"                        
[3] "possibly lost: 0 bytes in 0 blocks"                          
[4] "still reachable: 46,156,337 bytes in 10,032 blocks"          
[5] "of which reachable via heuristic:"                           
[6] "newarray           : 4,264 bytes in 1 blocks"                
[7] "suppressed: 0 bytes in 0 blocks"                             
[8] "Rerun with --leak-check=full to see details of leaked memory"

$error_summary
[1] "ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)"
```
