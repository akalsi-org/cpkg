#!/bin/bash

dir="$(readlink -f "$1")"
name="$(basename "$dir")"

mkdir -p "$dir"

files-to-copy() {
  cat <<EOF
.clang-format
.gitignore
build.sh
comp-db.sh
install.sh
pkg.sh
EOF
}

for f in $(files-to-copy); do
  echo "cp ${f}"
  mkdir -p $(dirname "${dir}/${f}")
  cp -f "${f}" "${dir}/${f}"
done

echo "mk .package"
cat >"${dir}/.package" <<EOF
import https://raw.githubusercontent.com/sheredom/utest.h/master/utest.h -> ${name}-3p
EOF
mkdir "${dir}/${name}-3p"
echo lib >"${dir}/${name}-3p/.kind"

echo
echo "pkg import"
cd "$dir"
./pkg.sh import

echo "git init"
git init . -b main

sed -i "s|3p/|${name}-3p/|g" build.sh
