#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: create_plot_index.sh
# 
#         USAGE: ./create_plot_index.sh 
# 
#   DESCRIPTION: Creates a byte index for the plot.list table, and also skips TV entries
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/11/2015 11:19
#      REVISION:  2015-12-11 14:32
#===============================================================================


source ~/bin/sh_colors.sh
export TAB=$'\t'



ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Usage :  ${0##/*/} [options] [--] 

  Options: 
  -h|--help       Display this message
  -v|--version    Display script version
  -V|--verbose    Display processing information
  --no-verbose    Suppress extra information
  --debug         Display debug information

	EOT
}    # ----------  end of function usage  ----------


#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
OPT_VERBOSE=
OPT_DEBUG=
while [[ $1 = -* ]]; do
case "$1" in
    -f|--filename)   shift
                     filename=$1
                     shift
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

IFILE=./plot.list.utf-8
OFILE=${IFILE}.idx
wc -l $IFILE
if [[ ! -f "$IFILE" ]]; then
    echo "File: $IFILE not found"
    exit 1
fi
pinfo "Generating byteoffsets and removing TV video SUSPENDED and ???? entries ... "
#grep -b '^MV: [^"]' $IFILE | egrep -v "(TV)|(V)$|(VG)$|(????)|SUSPENDED" > t.t
grep -b '^MV: [^"]' $IFILE |  egrep -v '\(TV\)$|\(V\)$|\(VG\)$|\(\?\?\?\?\)|SUSPENDED' > t.t
wc -l t.t
tail t.t

echo
pinfo "Switching columns ..."
cut -f1,3- -d':' t.t | awk -F':' '{ print $2, $1  }' OFS=$'\t' | sed 's/^ //' > t.t1
wc -l t.t1
echo
pinfo "Sorting file ..."
sort t.t1 > ${OFILE}
wc -l $OFILE

pinfo "Checking $OFILE"
look 'Casablanca' $OFILE
echo "...."
echo "Looking for Casablanca (1942) ..."
look 'Casablanca (1942)' $OFILE
echo "...."
look 'Gone with the Wind' $OFILE


echo
echo "Use readbyte.rb with offset and '^----' to get the plot from $IFILE"
