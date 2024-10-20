#include <cpp11.hpp>
using namespace cpp11;

[[cpp11::register]] int a_plus_b_(int a, int b) {
  return a + b;
}

// intentional memory leak
// [[cpp11::register]] int intentional_leak_(int a, int b) {
//   // allocate memory on the heap and do not free it
//   int* leak = new int[10];  // intentional memory leak

//   // return the first element of the leaked memory to avoid compiler optimization
//   return leak[0];
// }
