#!/bin/bash

export NDEBUG=1
source ./build.sh

set -euo pipefail

INSTALL_DIR=out/install
mkdir -p $INSTALL_DIR

for dir in $(top_level_folders); do
  test -f "${dir}/.kind" || continue
  mkdir -p ${INSTALL_DIR}/include/${dir}
  cp -f ${dir}/*.{h,hh,hpp} ${INSTALL_DIR}/include/${dir}/ || true
  rmdir ${INSTALL_DIR}/include/${dir} || true
done

cp -Rf out/lib ${INSTALL_DIR}/lib
cp -Rf out/bin ${INSTALL_DIR}/bin
rm -fr ${INSTALL_DIR}/bin/*_tests
rmdir ${INSTALL_DIR}/bin || true
