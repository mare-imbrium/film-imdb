#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
#         File: testindex.sh
#  Description: searches full/detailed original IMDB actors/ress file using byte index
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-23 - 18:47
#      License: MIT
#  Last update: 2015-11-30 12:41
# ----------------------------------------------------------------------------- #
#  testindex.sh  Copyright (C) 2012-2016 j kepler
#  DONT make this interactive, have a shell over this that is interactive and makes
#  calls to this.

#   Description: 
#   Args 1 : actors or actresses
#   Args 2 : Name to search on, 'Lastname, Firstname'
#
__ScriptVersion="0.0"
APPNAME=$0
#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
cat <<!

  Usage :  $APPNAME [options] [--] 

  Options: 
  -h|--help       Display this message
  -v|--version    Display script version
  --actor

  --actress       search for actress
  --director      search for director
  -m | --max <n>  print not more than <n> actors/actresses.
  -l              print only matching name, not films
  -h              print only matching films, hide name NOT IMPLEMENTED
  --interactive   with -l, allows selection of a name

  --debug         Display debug info

!
}    # ----------  end of function usage  ----------


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  search_name
#   DESCRIPTION:  given a name searches file for matches and prints result
#    PARAMETERS:  name or pattern
#       RETURNS:  ---
#-------------------------------------------------------------------------------
search_name ()
{
    patt="$1"
    matches=$( look "$patt"  $idx | head -$opt_max)
    print_details
}	# ----------  end of function search_name  ----------


# take a filter command on the select prompt
# e.g "| grep 1936" or | sed 's/(....)//g'
filter ()
{
    FILT="$*"
    FILT=$( echo "$FILT" | sed 's/^|//' )
    if [[ ! -f "$TMPFILE" ]]; then
        echo "File: $TMPFILE not found"
        exit 1
    fi
    CMD="cat $TMPFILE | $FILT"
    eval $CMD 
}	# ----------  end of function filter  ----------
prune ()
{
    if [[  -f "$TMPFILE" ]]; then
        egrep -v '(^		*"|^	.*\(TV\)|^	.*\(V\)|^	.*\(VG\))' $TMPFILE 
    else
        echo "Pls run a query first"
    fi
}	# ----------  end of function prune  ----------
topbilled ()
{
    if [[  -f "$TMPFILE" ]]; then
        egrep -v '(^		*"|^	.*\(TV\)|^	.*\(V\)|^	.*\(VG\))' $TMPFILE | grep '<[1-9]>$' 
    else
        echo "Pls run a query first"
    fi
}	# ----------  end of function prune  ----------
# prints movies for a director or actor or actress
print_details() {
    TMPFILE="out.tmp"
    get_details
    cat $TMPFILE
}
get_details() {
    offset=$( echo "$matches" | cut -f2 -d$'\t' )
    #echo offset is $offset
    ( for off in $offset; do
        ./readbyte.rb $file $off
        echo "=======================" 1>&2	
    done
    ) > $TMPFILE
}
#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
opt_verbose=
opt_max=100
opt_debug=
opt_only_name=
opt_interactive=
ScriptVersion="1.0"
stub="actors"
while [[ $1 = -* ]]; do
    case "$1" in
        --actress|--actresses)        shift
            stub="actresses"
            ;;
        --director|--directors)        shift
            stub="directors"
            ;;
        --actor|--actors)        shift
            stub="actors"
            ;;
        -m|--max) shift
            opt_max=$1
            shift
            ;;
        -l) shift
            opt_only_name=1
            ;;

        --interactive)   
            opt_interactive=1
            shift
            ;;
        -v|--version) echo "$0 -- Version $ScriptVersion"; exit 0   ;;

        -V|--verbose)   shift
            opt_verbose=1
            ;;
        --debug)        shift
            opt_debug=1
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
    echo -e "\\033[1m\\033[0;31mA name is required to search. See --help for more.\\033[22m\\033[0m" >&2
    exit
fi
patt=${1}
file=$stub.list.utf-8
idx="$file.0.idx"
echo "Testing search with $patt in $file using $idx" 1>&2	
matches=$( look "$patt"  $idx | head -$opt_max)
if [[ -n "$opt_only_name" ]]; then
    names=$( echo "$matches" | cut -f1 -d$'\t')
    if [[ -n "$opt_interactive" ]]; then
        IFS=$'\n'
        select name in $names; do
            if [[ -z "$name" ]]; then
                if [[ $REPLY == "prune" ]]; then
                    prune
                elif [[ $REPLY == "top" ]]; then
                    topbilled
                elif grep -q "^|" <<< "$REPLY"; then
                    # if first character is | then pipe the result through this filter
                    filter $REPLY
                else
                    echo "got:$REPLY."
                    exit
                fi
            else
                patt=$name
                matches=$( look "$patt"  $idx | head -$opt_max)
                print_details
            fi  
        done
        exit

    else
        echo "$names"
        exit 0
    fi
fi
print_details
#offset=$( look "$patt"  $idx | cut -f2 -d$'\t' | head -$opt_max)
