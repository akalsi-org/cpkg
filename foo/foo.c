#include "foo/foo.h"

#include "3p/evio.h"

int foo() {
  return (int)evio_now();
}
