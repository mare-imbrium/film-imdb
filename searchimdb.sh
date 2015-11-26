#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
#         File: searchimdb.sh
#  Description: searches imdb full/pruned/topbilled files for actor or actress.
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-17 - 20:58
#      License: MIT
#  Last update: 2015-11-23 18:28
# ----------------------------------------------------------------------------- #
#  YFF Copyright (C) 2012-2014 j kepler
#  Last update: 2015-11-23 18:28

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

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  new_indexed_search
#   DESCRIPTION:  Searches actor or actress file with new byte index
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
new_indexed_search (){
    idx="$ifile.0.idx"
    if [[ ! -f "$idx" ]]; then
        perror "$idx not found, Proceeding without index."
        opt_index=
    fi
    lens=${#patt}
    if (( lens < 4 )); then
        perror "Pattern too short. Should be at least 4 characters"
        exit 1
    fi
    if [[ -n "$opt_index" ]]; then
        ./testindex.sh $stub "$patt"
    else
        pinfo "Simple search without index"
        sed -n "/^${patt}/,/^$/p" $ifile 
    fi
}
#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  usage
#   DESCRIPTION:  print usage information
#-------------------------------------------------------------------------------
usage () {
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

Use --pruned for faster listing that doesn't print TV and VG entries

Use --topbilled for even faster listings that don't print low billing appearances

Use --actresses to see movies for an actress. Default is actors.

If found, the program utilizes an index which cuts down the time for results appreciably.
!
}
# ---- end of usage ----------------

while [[ $1 = -* ]]; do
case "$1" in
    --full)   shift
                ftype="1"
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
        usage
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
    perror "This program expects an actor name to search on"
    exit 1
else
    pdone "Got $*"
    patt="$*"
fi

ifile="$stub.list.utf-8"
case $ftype in
    "1")
        echo Using default big file $ifile
        echo "Use --pruned or --topbilled for smaller listings"
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
    perror "File: $ifile not found"
    exit 1
fi
new_indexed_search $ifile "$patt"
exit

#----------------- DEPRECATED --------------------------------------#
old_index_search (){
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
        sed -n "$rangest,${rangeen}p" $ifile  | sed -n "/^${patt}/,/^$/p" 
    else
        pinfo "Simple search without index"
        sed -n "/^${patt}/,/^$/p" $ifile 
    fi
}

