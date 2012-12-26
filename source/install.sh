#!/bin/sh

bin_install=${bin_install:-install}
bin_xargs=${bin_xargs:-xargs}
bin_find=${bin_find:-find}

_install_file () {
  local file srcfile dstfile dstdir

  file="$1"
  srcfile=${file#"${srcroot}/"}
  dstfile="${dstroot}/${srcfile}"
  dstdir=$(dirname "$dstfile")
  mkdir -p "$dstdir"
  $bin_install "$file" "$dstfile"
}

_install () {
  if [ -f "$1" ]
  then
    _install_file "$1"
  elif [ -d  "$1" ]
  then
    $bin_find "$1" -type f -print | while read f; \
    do
      _install_file "$f"
    done
  fi
}

srcroot="$1"
dstroot="$2"
_install "${3:-$1}"
