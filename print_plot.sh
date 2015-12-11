#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: print_plot.sh
# 
#         USAGE: ./print_plot.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/11/2015 14:33
#      REVISION:  2015-12-11 15:03
#===============================================================================


# prints plot for a movie. read from IMDB file and cut off first 4 characters.
print_details() {
    TMPFILE="out.tmp"
    get_details
    cat $TMPFILE
}
get_details() {
    offset=$( echo "$matches" | cut -f2 -d$'\t' )
    ( for off in $offset; do
        ./readbyte.rb $file $off "^----------"
        echo "=======================" 1>&2	
    done
    ) | cut -c4- > $TMPFILE
}
opt_max=100
ScriptVersion="1.0"
OPT_ONLY_NAME=

while [[ $1 = -* ]]; do
    case "$1" in
        -m|--max) shift
            OPT_MAX=$1
            shift
            ;;
        -l) shift
            OPT_ONLY_NAME=1
            ;;

        --interactive)
            # only ask for movie name, this way we can use the HIST file for foriegn names
            OPT_INTERACTIVE=1
            shift
            ;;
        -v|--version) echo "$0 -- Version $ScriptVersion"; exit 0   ;;

        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -h|--help)  usage; exit 0   ;;
        *)
            echo "Error: Unknown option: $1" >&2   # rem _
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done
if [  $# -eq 0 ]; then
    if [[ -n "$OPT_INTERACTIVE" ]]; then
        patt=$(rlwrap -pYellow -S 'Movie name? ' -H ~/.HISTFILE_MOVIETITLE -P "" -o cat)
    else
        echo -e "Movie name required" 1<&2
        exit 1
    fi
else
    patt="$*"
fi
file="./plot.list.utf-8"
idx="${file}.idx"
if [[ ! -f "$idx" ]]; then
    echo "File: $idx not found"
    exit 1
fi

matches=$( look "$patt"  $idx | head -$opt_max)
if [[ -n "$OPT_ONLY_NAME" ]]; then
    echo -e "$matches" | cut -f1
    exit 0
fi
print_details
