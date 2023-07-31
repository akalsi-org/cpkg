#!/bin/bash

# Run lcov from '.' to produce HTML files

command -v lcov >/dev/null 2>&1 || {
  echo "lcov not found"
  exit 1
}

lcov --directory . --capture --output-file coverage.info
lcov --remove coverage.info '/usr/*' --output-file coverage.info
lcov --remove coverage.info '*.t.c' --output-file coverage.info
lcov --remove coverage.info '/tmp*' --output-file coverage.info
lcov --list coverage.info
if [ -f coverage.info ]; then
  genhtml coverage.info --output-directory html
  rm coverage.info
fi

if [ -d html ] && [ "$NOSERVER" != 1 ]; then
  # Run web server
  python3 -m http.server --directory html 8081
fi
