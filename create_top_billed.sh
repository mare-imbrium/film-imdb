#!/usr/bin/env bash
# # TODO BUG 2015-12-27 - movies that still have date as (????) should b removed.
while [[ $1 = -* ]]; do
    case "$1" in
        --actress|--actresses)   shift
            stub="actresses"
            ;;
        --actor|--actors)   shift
            stub="actors"
            ;;
        --director|--directors)   shift
            stub="directors"
            ;;
        -V|--verbose)   shift
            opt_verbose=1
            ;;
        --debug)        shift
            opt_debug=1
            ;;
        -h|--help)
            cat <<!
            Use --actors or --actresses or --directors flag
!
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   # rem _
            echo "Use -h or --help for usage"
            exit 1
            ;;
    esac
done

[[ -z "$stub" ]] && { echo "Error: $stub blank." 1>&2; exit 1; }
TAB=$'\t'

# DESCRIPTION: removes TV,V,VG entries and non-topbilled movies from file, and creates topbilled file

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
echo "this program requires both gsed and sponge (moreutils)"
which gsed
[[ $? -eq 1 ]] && { perror "gsed not available. Exiting."; exit 1; }
which sponge
[[ $?  -eq 1 ]] && { perror "Error: sponge not available." 1>&2; exit 1; }
# removed check since this needs to be automated and its okay really
if [[ -f "$stub.topbilledXXXX" ]]; then
    perror "$stub.topbilled  will be overwritten, Pls delete or move before running this process."
    echo -n "Do you wish to continue? [yn] "
    read yesno
    if [[ $yesno =~ [Nn] ]]; then
        exit 1
    fi
    pdone "Continuing ..."
fi
echo
ifile=$stub.list.utf-8
pinfo "Checking for intro section in $ifile -- CRC in start of first line"
crc=$( head -1 $ifile | grep -c "^CRC" )
if (( $crc > 0 )); then
    pinfo "Removing the intro and end section of the $ifile file ..."

    sed  '1,/^\-\-\-\-		/d' $ifile | sed '/^SUBMITTING /,$d' > $stub.tmp
    #cp $stub.list.utf-8 $stub.tmp
    pdone
    wc -l $stub.tmp
    echo "....head ..."
    head $stub.tmp
    pdone "...tail ..."
    tail $stub.tmp
else
    echo "No intro found .. copying $ifile to $stub.tmp"
    cp $ifile $stub.tmp
fi

cat <<! 

Now we push the movie or TV show in the same line as director/actor
into the next line.
This way we can remove all TV and low ranked entries in one shot
and not have some low billed movie or TV show next to director

!
pinfo "Separating movie from $stub ..."
gsed "s/^\([^${TAB}]\+\)${TAB}/\1${TAB}${TAB}${TAB}/" $stub.tmp > t.t
pdone
echo
pinfo "Replacing ^M with newlines ..."
tr '' '\n' < t.t | sponge t.t
pdone "Done"
echo
pinfo "Removing TV VG and V entries ... (takes time ...)"

#egrep -v '(^		*"|^	.*\(TV\)|^	.*\(V\)|^	.*\(VG\))' t.t | sponge t.t
# NOTE that a director or actor can have a (V) in their name !!!
egrep -v '(^		*"|\(TV\)|^	.*\(V\)|\(VG\))' t.t | sponge t.t

wc -l t.t
ls -lh t.t

pdone

if [[ $stub != "directors" ]]; then
    # only actors and actresses have billings.
    pinfo "Removing all entries that are not billed in top 19. ..."

    # any line ending with 1-9 in angled brackets, or not starting with a tab, and blank line.
    #  # :WARNING:11/29/2015 20:23:: Earlier only first 9, now allowing more names
    #egrep '(<[1-9]>$|^[^	]|^$)' t.t > $stub.topbilled
    egrep '(<1?[0-9]>$|^[^	]|^$)' t.t > $stub.topbilled
    pdone
    echo

    pdone "checking for occurences of <..>"
    #count=$(grep -c '<[0-9][0-9]>' $stub.topbilled )
    count=$(grep -c '<[2-9][0-9]>' $stub.topbilled )
    if [[ $count -eq 0 ]]; then
        pdone " ... Okay"
    else
        perror "We seem to have $count lower billed entries"
        grep -m 2 '<[2-9][0-9]>' $stub.topbilled 
    fi
else
    pinfo "Skipping billins for directors"
    cp t.t $stub.topbilled
fi

wc -l $stub.list.utf-8 t.t $stub.topbilled 
ls -lh $stub.list.utf-8 t.t $stub.topbilled

echo
pinfo "Removing entries that have no films ..."
cp $stub.topbilled $stub.topbilled.bak
# I used XXX earlier but there were directors with that number

perl -00pe 's/^[^	]*\n\n/\n/' $stub.topbilled | grep -v '' | sponge $stub.topbilled
pdone
echo
wc -l $stub.topbilled 
ls -lh $stub.topbilled
echo
# print only those lines which have some data following, prints two lines at end. Use head -n -2 to remove
# awk -vRS='\n\n' -vORS='\n\n' '/^[^    ]*\n/ { print ;}' a.t | head -n -2
# 
head $stub.topbilled
pbold "Pls remove t.t and $stub.tmp files"
echo you may now generate movie.tsv from the topbilled files using create_movie_list.sh
