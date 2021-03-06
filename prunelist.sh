if [  $# -eq 0 ]; then
    echo "Pass actor or actress"
else
    stub="$1"
fi
TAB=$'\t'

#   DESCRIPTION: removes only TV/V/VG entries from incoming IMDB file, creating .pru file

export COLOR_RED="\\033[0;31m"
export COLOR_GREEN="\\033[0;32m"
export COLOR_BLUE="\\033[0;34m"
export COLOR_YELLOW="\\033[1;33m"
export COLOR_WHITE="\\033[1;37m"
export COLOR_DEFAULT="\\033[0m"
export COLOR_BOLD="\\033[1m"
export COLOR_BOLDOFF="\\033[22m"

pbold() {
    echo -e "${COLOR_BOLD}$*${COLOR_BOLDOFF}"
}
pinfo() {
    echo -e "${COLOR_BOLD}${COLOR_YELLOW}$*${COLOR_BOLDOFF}${COLOR_DEFAULT}"
}
perror() {
    echo -e "${COLOR_BOLD}${COLOR_RED}$*${COLOR_BOLDOFF}${COLOR_DEFAULT}" <&2
    #echo -e "$0: $*" >&2
}
pdone() {
    text=${*:-"Done."}
    echo -e "${COLOR_BOLD}${COLOR_GREEN}${text}${COLOR_BOLDOFF}${COLOR_DEFAULT}" <&2
}
cat <<!

   This program removes TV and Video entries from the list file. 
   This way we continue to have low billed actors, but the file is 
   roughly 50% or the original and faster for querying.

!
ifile=$stub.list.utf-8
if [[ ! -f "$ifile" ]]; then
    echo "File: $ifile not found"
    exit 1
fi
ofile="${ifile}.pru"
if [[ -n "$FALSEXXX" ]]; then
    pinfo "Removing the intro and end section of the $ifile file ..."
    sed  '1,/^\-\-\-\-		/d' $ifile | sed '/^SUBMITTING /,$d' > $stub.tmp
    pdone
    wc -l $stub.tmp
    pdone "head ..."
    head $stub.tmp
    pdone "...tail ..."
    tail $stub.tmp
fi

echo
wc -l $ifile
ls -lh $ifile
echo
pinfo "Removing TV and Video entries from $ifile (this takes a minute or so)..."
egrep -v '(^		*"|^	.*\(TV\)|^	.*\(V\)|^	.*\(VG\))' $ifile > $ofile
# NOTE that a director or actor can have a (V) in their name !!!
#egrep -v '(^		*"|\(TV\)|^	.*\(V\)|\(VG\))' t.t | sponge t.t

pdone
ct=$( egrep '(VG)|(TV)' $ofile | wc -l | cut -f1 -d' ' )
echo "There are still $ct lines with TV or VG present since they are on the same row with name"
ct=$( egrep '(????' $ofile | wc -l | cut -f1 -d' ' )
echo "There are $ct lines with (????"

echo
wc -l $ofile
echo
echo
if [[ $stub == "actors" ]]; then
    pinfo "Timing search for Tracy Spencer without index..."
    time (sed -n '/^Tracy, Spencer/,/^$/p'  $ofile >/dev/null)
elif [[ $stub == "actresses" ]]; then
    pinfo "Timing search for Meryl Streep without index..."
    time (sed -n '/^Streep, Meryl/,/^$/p'  $ofile >/dev/null)
fi

ls -lh $ofile
