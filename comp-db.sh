#!/bin/bash

NORUN=1 source ./build.sh

exec 1<>"compile_commands.json"

sep="["
for dir in $(top_level_folders); do
  test -f "${dir}/.kind" || continue
  comp_cmd="cc ${cflags} ${optflags}"
  for f in $(find "${dir}" -name '*.c'); do
    echo "${sep}{ \"directory\": \"$(pwd)\", \"command\": \"$comp_cmd -c ${f} -o out/${f}.o\", \"file\": \"${f}\" }"
    sep=","
  done
done
echo "]"
