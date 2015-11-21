#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
#         File: searchimdb.sh
#  Description: 
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-17 - 20:58
#      License: MIT
#  Last update: 2015-11-18 12:58
# ----------------------------------------------------------------------------- #
#  YFF Copyright (C) 2012-2014 j kepler
#  Last update: 2015-11-18 12:58

# 1. option for search topbilled
#    option for forcing use of long file and not pruned
# 2. look for pruned file. if not then long file
# 3. check if index available for ifile, use if true.
# 4. check that index is not outdated.
# 5. flag for ignore index, or force usage of index even if date < data
# 6. 
source ~/bin/sh_colors.sh
opt_index=1
opt_pru=1
opt_topbilled=
ftype="2"
stub="actors"

while [[ $1 = -* ]]; do
case "$1" in
    -f|--filename)   shift
                     filename=$1
                     ;;
    --pruned)   shift
                ftype="2"
                     ;;
    --topbilled|--top)   shift
                ftype="3"
                     ;;
    --actresses)   shift
                stub="actresses"
                     ;;
    -h|--help)
cat <<!
$0 Version: 0.0.0 Copyright (C) 2015 jkepler
This program searches the IMDB data giving detailed listings.
These searches take longer than other programs which query very restricted data.
One can search the full file, a pruned file (that has TV data removed) and a file
that contains only topbilled (1-9) roles.

You may search for the movies of a director or actor or actress.
Rough sizes of files are:
1. Full actor file: 1 GB (15 seconds without index, 5 seconds with index).
2. Pruned actor file:
3. Actors top billed:

If found, the program utilizes an index which cuts down the time for results appreciably.
!
        # no shifting needed here, we'll quit!
        exit
        ;;
    *)
        echo "Error: Unknown option: $1" >&2   # rem _
        echo "Use -h or --help for usage"
        exit 1
        ;;
esac
done

patt=""
if [ $# -eq 0 ]
then
    perror "This program expects a name to search on"
    exit 1
else
    pdone "Got $*"
    patt="$*"
fi

ifile="$stub.list.utf-8"
case $ftype in
    "1")
        echo Using default big file..
        ;;
    "2")
        ifile="$ifile.pru"
        ;;
    "3")
        ifile="$stub.topbilled"
        ;;
esac
pinfo "using file $ifile"
if [[ ! -f "$ifile" ]]; then
    perror "$ifile not found"
    exit 1
fi
idx="$ifile.2.idx"
if [[ ! -f "$idx" ]]; then
    perror "$idx not found, Proceeding without index."
    opt_index=
fi
lens=${#patt}
if (( lens < 4 )); then
    perror "Pattern too short. Should be at least 4 characters"
    exit 1
fi
key=${patt:0:2}
key=$( echo "$key" | tr '[:lower:]' '[:upper:]' )
if [[ -n "$opt_index" ]]; then
    # pick up index
    echo "Trying with 2 char index file $idx, key is $key"
    grep -A 1 "^${key}" $idx 
    IFS=$'\n' lines=($( grep -A 1 "^${key}" $idx | cut -f2 -d: ) )
    rangest=${lines[@]:0:1}
    rangeen=${lines[@]:1:1}
    echo "range is  $rangest to $rangeen"
    time (sed -n "$rangest,${rangeen}p" $ifile  | sed -n "/^${patt}/,/^$/p" )
else
    pinfo "Simple search without index"
    time (sed -n "/^${patt}/,/^$/p" $ifile )
fi

# decide which infile to use
#
exit
export TAB=$'\t'
IFS=$'\n\t'
APPNAME=$( basename $0 )
# cron jobs can't access my env, and i don't want to expose mailid to spammers

ext=${1:-"default value"}
today=$(date +"%Y-%m-%d-%H%M")
curdir=$( basename $(pwd))

read yesno
if [[ $yesno =~ [Yy] ]]; then
else
fi

# print a message to stderr, preceded by the script name
function warn {
  echo -e "$0: $*" >&2
}

