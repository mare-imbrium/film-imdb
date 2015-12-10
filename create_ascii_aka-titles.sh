#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: create_ascii_titles.sh
# 
#         USAGE: ./create_ascii_titles.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/07/2015 23:52
#      REVISION:  2015-12-08 13:26
#===============================================================================

echo decoding aka-titles.tsv
./unidecode_names.rb aka-titles.tsv
echo
echo decoding movie.tsv
./unidecode_names.rb movie.tsv
IFILE=./ascii_aka-titles.tsv
IFILE2=./ascii_movie.tsv
OFILE=ascii_titles.tsv
echo
echo Step 2: Merge both output files into $OFILE
echo
echo "./ascii_aka-titles.tsv has a redundant field in the middle which we remove"
cut -f1,3 -d$'\t' $IFILE $IFILE2 | sort -u > $OFILE

echo testing $OFILE .. should have only 2 columns
grep 'Tokyo monogatari' $OFILE
echo Next should not give a result
grep 'Tokyo Story' $OFILE
echo
echo heading file
head $OFILE
echo 
echo Output is $OFILE
echo You may remove $IFILE and $IFILE2
echo Import $OFILE into ascii_titles table
echo Earlier $IFILE was imported into ascii_aka-titles table which may not be necessary
