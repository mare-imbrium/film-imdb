stub="actors"
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
if [[ -f "$stub.topbilled" ]]; then
    perror "$stub.topbilled  will be overwritten, Pls delete or move before running this process."
    echo -n "Do you wish to abort? [yn] "
    read yesno
    if [[ $yesno =~ [Yy] ]]; then
        exit 1
    fi
    pdone "Continuing ..."
fi
echo
ifile=$stub.list.utf-8
pinfo "Removing the intro and end section of the $ifile file ..."

sed  '1,/^\-\-\-\-		/d' $ifile | sed '/^SUBMITTING /,$d' > $stub.tmp
#cp $stub.list.utf-8 $stub.tmp
pdone
wc -l $stub.tmp
pdone "head ..."
head $stub.tmp
pdone "...tail ..."
tail $stub.tmp

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

pdone
pinfo "Removing all entries that are not billed in top 9. ..."
#echo "We don't touch the first film as that would remove the actor too"

egrep '(<[1-9]>$|^[^	]|^$)' t.t > $stub.topbilled
pdone
echo

pdone "checking for occurences of <..>"
count=$(grep -c '<[0-9][0-9]>' $stub.topbilled )
if [[ $count -eq 0 ]]; then
    pdone " ... Okay"
else
    perror "We seem to have $count lower billed entries"
    grep -m 2 '<[0-9][0-9]>' $stub.topbilled 
fi

wc -l $stub.list.utf-8 t.t $stub.topbilled 
ls -lh $stub.list.utf-8 t.t $stub.topbilled

echo
pinfo "Removing entries that have no films ..."
# I used XXX earlier but there were directors with that number

perl -00pe 's/^[^	]*\n\n/\n/' $stub.topbilled | grep -v '' | sponge $stub.topbilled
pdone
echo
wc -l $stub.topbilled 
ls -lh $stub.topbilled
echo
cat <<!
The joinlines program expects an entry next to dir/act name, we
need to check it out.

!
# print only those lines which have some data following, prints two lines at end. Use head -n -2 to remove
# awk -vRS='\n\n' -vORS='\n\n' '/^[^    ]*\n/ { print ;}' a.t | head -n -2
# 
head $stub.topbilled
pbold "Pls remove t.t and $stub.tmp files"
