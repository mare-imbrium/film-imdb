#!/usr/bin/env bash

stub=${1:-"actors"}
file=$stub.list.utf-8
patt=${2:-"Tierney, Gene"}
echo testing searche with $patt in $file using $file.idx
offset=$( look "$patt"  $file.0.idx | cut -f2 -d$'\t' )
echo offset is $offset

./readbyte.rb $file $offset
