#!/bin/sh

folders=$(find . -maxdepth 1 -type d)

top_level_folders() {
  find . -maxdepth 1 -type d | grep -v '\.$' | grep -v '\..$' | sed 's|^\./||'
}

optflags="-O0 -g -fprofile-arcs --coverage -fsanitize=address -fsanitize=leak"
cflags="${CFLAGS} -I$(pwd) -fvisibility=default -fPIC"
cxxflags="${CXXFLAGS} -I$(pwd) -fvisibility=default -fPIC"
ldflags="${LDFLAGS} -lasan -llsan -lgcov"

if [ "$DEBUG" != 1 ]; then
  optflags="-O3 -fno-omit-frame-pointer -DNDEBUG"
  ldflags="${LDFLAGS}"
else
  set -x
fi

[ "$TMPDIR" = '' ] && TMPDIR="/tmp"

compile_dir() {
  dir="$1"
  mkdir -p "out/$dir"
  comp_cmd="cc ${cflags} ${optflags}"
  find "$dir" -name '*.c' | xargs -I{} -P6 sh -c "mkdir -p \$(dirname {}) && echo cc {} && $comp_cmd -c {} -o out/{}.o" || exit 1
  [ -f "out/test-main.t.c.o" ] && return
  cat >"${TMPDIR}/utest-main.c" <<EOF
#include "3p/utest.h"

UTEST_MAIN()
EOF
  $comp_cmd -c ${TMPDIR}/utest-main.c -o out/test-main.t.c.o
}

link_dir() {
  dir="$1"
  kind="$2"
  deps=""
  [ -f "$dir/.deps" ] && deps="$(cat $dir/.deps | xargs -I{} echo "-l{}")"
  mkdir -p out/bin
  if [ "$kind" = bin ]; then
    echo ld "$dir"
    cc $(find "out/$dir" -name '*.o' ! -name '*.t.c.o' | xargs) -L out/lib ${deps} ${ldflags} -o "out/bin/${dir}" || exit 1
  else
    mkdir -p out/lib
    echo ar "$dir"
    ar rcs "out/lib/lib${dir}.a" $(find "out/$dir" -name '*.c.o' ! -name '*.t.c.o' | xargs) || exit 1
  fi
}

test_dir() {
  dir="$1"
  kind="$2"
  deps=""
  [ -f "$dir/.deps" ] && deps="$(cat $dir/.deps | xargs -I{} echo "-l{}")"
  mkdir -p out/bin
  if [ "$kind" = bin ]; then
      return
  else
    mkdir -p out/lib
    echo ld "${dir}_tests"
    cc $(find "out/$dir" -name '*.t.c.o' | xargs) out/test-main.t.c.o -L out/lib -l${dir} ${deps} ${ldflags} -o "out/bin/${dir}_tests" || exit 1
    echo run "${dir}_tests"
    "out/bin/${dir}_tests"
  fi
}

build_lib() {
  compile_dir "$1"
  link_dir "$1" lib
}

build_bin() {
  compile_dir "$1"
  link_dir "$1" bin
}

targets() {
  rm -fr out/
  for dir in $(top_level_folders); do
    test -f "${dir}/.kind" || continue
    compile_dir "${dir}"
  done
  for dir in $(top_level_folders); do
    test -f "${dir}/.kind" || continue
    kind=$(cat "${dir}/.kind")
    link_dir "${dir}" "${kind}"
  done
  for dir in $(top_level_folders); do
    test -f "${dir}/.kind" || continue
    kind=$(cat "${dir}/.kind")
    test_dir "${dir}" "${kind}"
  done
}

rm -fr ./out/
targets
