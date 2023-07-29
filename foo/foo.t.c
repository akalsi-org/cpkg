#include "foo/foo.h"

#include "3p/utest.h"

UTEST(foo, funcBasic) {
  ASSERT_NE(foo(), 0);
}
