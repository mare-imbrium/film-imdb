#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
#         File: searchactor.sh
#  Description: Helps to get the actor name correct so we can further query
#              Assume you don't know how it is in the imdb database.
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-19 - 14:20
#      License: MIT
#  Last update: 2015-11-19 20:58
# ----------------------------------------------------------------------------- #
#  searchactor.sh  Copyright (C) 2012-2016 j kepler
#  Last update: 2015-11-19 20:58


#-----------------------------------------------------------------------
#  Check number of command line arguments
#-----------------------------------------------------------------------

source ~/bin/sh_colors.sh

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Usage :  ${0##/*/} [options] [--] 

  Options: 
  -h|help       Display this message
  -v|version    Display script version

	EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
opt_verbose=
opt_debug=
ScriptVersion="1.0"
filename="actors";
while [[ $1 = -* ]]; do
    case "$1" in

        -v|--version) echo "$0 -- Version $ScriptVersion"; exit 0   ;;

        -t|--type)   shift
            type=$1
            case $type in
                "f"|"actress")
                    filename="actresses";;
                "m"|"actor")
                    filename="actors";;
                "d"|"director")
                    filename="directors";;
            esac
            shift
            ;;
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

if [ $# -eq 0 ]
then
    echo -n "Enter part of the name: "
    read patt
    #perror "\n\tUsage:  ${0##/*/} <Name (part of)>\n"; exit 1; 
fi
actfile="${filename}.t"
if [[ ! -f "$actfile" ]]; then
    perror "$actfile not found"
    exit 1
fi
patt="$*"
pinfo "Showing matches for: $patt"
items=$(grep -i "$patt" $actfile )
lenitems=$( echo -e "${items}" | grep -c . )
if (( $lenitems < 1 )); then
    pbold "No matches for $patt"
    exit -1
fi
pinfo "$lenitems items"
echo "$items" | ./nl.sh
if (( $lenitems == 1 )); then
    exit
fi
if (( $lenitems > 100 )); then
    echo -n "Select item [1 - ${lenitems}] or enter another part of name: "
else
    echo -n "Select item [1 - ${lenitems}]: "
fi
read index
[[ -z "$index" ]] && { exit 1; }
if [[ "$index" = +([0-9]) ]]; then
    if (( $index > 0 || $index <= $lenitems )); then 
        choice=$(echo -e "$items" | sed "${index}!d")
        echo $choice
    fi
elif [[ $index =~ [a-zA-Z] ]]; then
    items1=$(echo -e "$items" | grep -i "${index}")
    echo -e "$items1"
fi



