#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: create_actor_list.sh
# 
#         USAGE: ./create_actor_list.sh 
# 
#   DESCRIPTION: this creates a list of actors and actresses from the topbilled files
#                which are what goes into the movie.sqlite for movie-actor association.
#                Earlier i tried to take all actors and actresses, but there were too many
#                by the same name. Now we will have only those who have a movie in the movie-actor
#                (cast) table.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/01/2015 15:04
#      REVISION:  2015-12-01 15:12
#===============================================================================

set -o nounset                              # Treat unset variables as an error
source ~/bin/sh_colors.sh
APPNAME=$( basename $0 )
ext=${1:-"default value"}
today=$(date +"%Y-%m-%d-%H%M")
curdir=$( basename $(pwd))
set -euo pipefail
export TAB=$'\t'

IFILE=actors.topbilled
for IFILE in actors.topbilled actresses.topbilled
do
if [[ ! -f "$IFILE" ]]; then
    echo "File: $IFILE not found"
    exit 1
else
    echo Using $IFILE
fi
gender="M"
if [[ $IFILE == "actresses.topbilled" ]]; then
    gender="F"
fi
#grep "^[^-$TAB]" $IFILE > t.t
echo "Doubling the name field from $IFILE"
grep "^[[:alpha:]]" $IFILE | awk -F$'\t' '{ print $1, $1 }' OFS=$'\t' > t.t
wc -l t.t
echo Fixing the name and removing roman numbering in first column
# there are some rows that fail this check since there is no comma in the name
# just some crap name.
#gsed 's/^\([^,]*\), \([^(]*\)\(.*\)/\1, \2\3 	 \2 \1	M/' t.t | tr -s ' ' > t.tt
# this works but only for the case of command and (XX)
#gsed 's/^\([^,]*\), \([^(]*\)([IVX]*)/\2 \1/' t.t | tr -s ' ' > t.tt
# second case takes care of names with no number
gsed 's/^\([^,]*\), \([^(]*\)([IVX]*)/\2 \1/;s/^\([^,]*\), \([^(]*\)	/\2 \1	/' t.t | tr -s ' ' > t.tt
wc -l t.tt
echo Adding M and switching 1 and 2 cols
awk -v a_gen=$gender -F$'\t' '{ print $2, $1, a_gen }' OFS=$'\t' t.tt > $gender.t
wc -l $gender.t t.tt
done
echo sorting ...
sort M.t F.t > names.tsv
wc -l names.tsv
echo checking for double quotes in names
grep -c '"' names.tsv
echo escaping double quotes and sorting again
sed 's/"/\\"/g' names.tsv | sort | sponge names.tsv
wc -l names.tsv
exit
IFILE=actresses.topbilled
if [[ ! -f "$IFILE" ]]; then
    echo "File: $IFILE not found"
    exit 1
fi
grep "^[^$TAB]" $IFILE > t.t
gsed 's/^\([^,]*\), \([^(]*\)\(.*\)/\1, \2\3 	 \2 \1	F/' t.t | tr -s ' ' >> t.tt
wc -l t.tt
# sort unique since some names are duplicated in the actor and actress file
sort -u t.tt > names.tsv
