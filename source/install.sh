#!/bin/sh

_install_file () {
  local file srcfile dstfile dstdir

  file="$1"
  srcfile=${file#"${srcroot}/"}
  dstfile="${dstroot}/${srcfile}"
  dstdir=$(dirname "$dstfile")
  mkdir -p "$dstdir"
  cp --preserve=mode "$file" "$dstfile"
}

_install () {
  if [ -f "$1" -o -h "$1" ]
  then
    _install_file "$1"
  elif [ -d  "$1" ]
  then
    find "$1" -type f -print | while read f; \
    do
      _install_file "$f"
    done
  fi
}

srcroot="$1"
dstroot="$2"
_install "${3:-$1}"
