#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: create_dir_list.sh
# 
#         USAGE: .fcreate_dir_list.sh
# 
#   DESCRIPTION: fix name of directors in given file. this is no longer used
#      since the idx file has too many similar names. I now use ./create_actor_list.sh using the 
#      topbilled files.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 11/30/2015 20:08
#      REVISION:  2015-12-01 00:16
#===============================================================================

#set -o nounset                              # Treat unset variables as an error
#set -euo pipefail

source ~/bin/sh_colors.sh
ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Changes the name format used by IMDB to a regular "firstname, lastname" format
  so we can query bothways. Creates a new file with both name formats, so we can map,
  This will help mapping between the JSON database and IMDB and help in queries.

  Usage :  ${0##/*/} [options] [--] 

  Options: 
  -h|--help       Display this message
  -v|--version    Display script version
  -V|--verbose    Display processing information
  --no-verbose    Suppress extra information
  --debug         Display debug information

	EOT
}    # ----------  end of function usage  ----------
stub=directors
INFILE="./$stub.list.utf-8.0.idx"
OFILE="$stub.tsv"

check() {
    errors=0
    if [[ ! -f "$INFILE" ]]; then
        perror "ERROR: File: $INFILE not found"
        (( errors++ ))
    fi
    if [[ "$INFILE" -nt "$OFILE" ]]; then
        pinfo "$OFILE needs to be regenerated"
        (( errors++ ))
    fi
    if [[ $errors -eq 0 ]]; then
        echo "Nothing to do." 1>&2
        exit 0
    else
        pinfo "$OFILE needs to be regenerated."
        exit 1
    fi
}
#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
OPT_VERBOSE=
OPT_DEBUG=
while [[ "$1" = -* ]]; do
case "$1" in
    --check)
        check
        exit
                     ;;
    -V|--verbose)   shift
                     OPT_VERBOSE=1
                     ;;
    --no-verbose)   shift
                     OPT_VERBOSE=
                     ;;
    --debug)        shift
                     OPT_DEBUG=1
                     ;;
    -h|--help)
        usage
        exit
    ;;
    *)
        echo "Error: Unknown option: $1" >&2   # rem _
        echo "Use -h or --help for usage"
        exit 1
        ;;
esac
done


pinfo Using $INFILE as input to generate new file. 
if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found"
    exit 1
fi
pinfo Adding name at end of row
awk  -F$'\t' '{ print $1, $1 }' OFS=$'\t' $INFILE > t.t
pdone
head t.t
pinfo fixing name to firstname lastname format and putting roman numbers at end
gsed  's/^\([^,]*\), \([^	]*\)/\2 \1/;' t.t | tee x.x | gsed  's/ \(([IVXL]*)\)\([^	]*\)/\2 \1/' > t.tt
pdone
head t.tt
pinfo switching first and last columns
echo Also sorting unique since directors file has some names duplicated ...
awk -F$'\t' '{ print $2, $1  }' OFS=$'\t' t.tt  | sponge t.tt
echo "Removing roman numerals from the end. We don't use them in newname"
gsed 's/ ([IVXL]\+)$//' t.tt | sponge t.tt
echo sorting unique
sort -u t.tt > $OFILE
pdone "created $OFILE"
head $OFILE
echo "..."
look 'Ozu, ' $OFILE
look 'Hitchcock, A' $OFILE
wc -l $OFILE $INFILE
pdone " Use this to import into movie.sqlite using create_director.sh and resolve directors names"
