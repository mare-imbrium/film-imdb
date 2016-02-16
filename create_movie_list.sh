#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: create_movie_list.sh
# 
#         USAGE: ./create_movie_list.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/08/2015 10:42
#      REVISION:  2015-12-27 20:01
#===============================================================================
#  sample of row in topbilled file
#    
#		All Things Fall Apart (2011)  (as Curtis '50 cent' Jackson)  [Deon]  <1>
#			Babel (2006/I)  [Richard]  <1>
#			Birdman: Or (The Unexpected Virtue of Ignorance) (2014)  [Bartender (Tommy)]  <19>
#
echo this file is to be run AFTER generating actors and actresses.topbilled files
echo since it takes only those movies that have actors and actresses who have cast information
echo
OFILE=movie.tsv
echo creating $OFILE ...
# grep all rows that start with TAB
# squeeze tab so we can take second field which has movie name
# Take out all the portion uptp movie data leaving the rest information
# We are going till the date which can be (1990) or (2010/IV) . Earlier I was not careful and other stuff
#   was being caught like (11 years).
#grep '^	' actors.topbilled actresses.topbilled | fgrep -v '(????' | tr -s $'\t' | cut -f2 | sed 's~^\(.*([12][089][0-9][0-9][/IVX]*)\).*~\1~' | sort -u > t.t
grep '^	' actors.topbilled actresses.topbilled | fgrep -v '(????' | tr -s $'\t' | cut -f2 > t.t
wc -l t.t
ct1=$( wc -l t.t | cut -f1 -d' ')
echo "Catching everything till the date, discarding rest"
echo BEFORE ======================
head t.t

sed 's~^\(.*([12][089][0-9][0-9][/IVXL]*)\).*~\1~' t.t > t.t1
echo AFTER =======================
head t.t1
grep -m 1 'Sign Language (2010' t.t1
ct2=$( wc -l t.t1 | cut -f1 -d' ')
if [[ $ct2 -lt $ct1 ]]; then
    echo -e "Error: lines have been lost in previous operation. $ct1 $ct2" 1<&2
    exit 1
else
    echo "No lines lost: $ct1 and $ct2"
fi
echo press enter
read
sort -u t.t1 > t.t2
ct3=$( wc -l t.t2 | cut -f1 -d' ')
echo "===== After sort unique we have $ct3 lines"

echo now duplicate the year at end
#gsed 's/(\([0-9]\{4\}\))$/(\1)	\1/' t.t > $OFILE
# echo also duplicate the bare title without year just in case we need to match
# BUG: first transform misses out year with characters /IVX so no year in them.
#gsed 's/(\([0-9]\{4\}\))$/(\1)	\1/;s/\([^	]*\) \(([0-9]\{4\}.*\)/\1	\1 \2/' t.t > $OFILE
# BUG, not we lose the /IVX part
gsed 's/(\([0-9]\{4\}\))$/(\1)	\1/;s~(\([0-9]\{4\}\)\(/[IVXL]*\))$~(\1\2)	\1~' t.t2 > $OFILE

wc -l $OFILE
echo duplicated year at end. checking
grep -m 1 'Sign Language (2010' $OFILE
echo press enter
read
echo duplicate bare title without year
sed 's/\([^	]*\) \(([0-9]\{4\}.*\)/\1	\1 \2/' $OFILE > t.t
head t.t
grep -m 1 'Sign Language (2010' t.t
read
echo "now switch the bare title to the end: title, year, baretitle"
awk -F$'\t' '{ print $2, $3, $1  }' OFS=$'\t' t.t  | sponge $OFILE

echo check if sorted
sort --check $OFILE
wc -l $OFILE
rm t.t t.t1 t.t2
echo
head $OFILE
echo
look 'Casablanca ' $OFILE
echo
look 'Life of Pi ' $OFILE
echo "checking Babel (2006/I) for year"
look 'Babel' $OFILE
echo checking to see how many rows do not have year.
grep -c "		" $OFILE
echo if all well you may import data using create_movie.sh in dataset
