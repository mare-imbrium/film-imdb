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
#      REVISION:  2015-12-09 14:48
#===============================================================================

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
grep '^	' actors.topbilled actresses.topbilled | fgrep -v '(????' | tr -s $'\t' | cut -f2 | sed 's~^\(.*([12][09][0-9][0-9][/IVX]*)\).*~\1~' | sort -u > t.t

echo now duplicate the year at end
#gsed 's/(\([0-9]\{4\}\))$/(\1)	\1/' t.t > $OFILE
# echo also duplicate the bare title without year just in case we need to match
gsed 's/(\([0-9]\{4\}\))$/(\1)	\1/;s/\([^	]*\) \(([0-9]\{4\}.*\)/\1	\1 \2/' t.t > $OFILE
echo "now switch the bare title to the end: title, year, baretitle"
awk -F$'\t' '{ print $2, $3, $1  }' OFS=$'\t' $OFILE  | sponge $OFILE

echo check if sorted
sort --check $OFILE
wc -l $OFILE
rm t.t
echo
head $OFILE
echo
look 'Casablanca ' $OFILE
echo
look 'Life of Pi ' $OFILE
