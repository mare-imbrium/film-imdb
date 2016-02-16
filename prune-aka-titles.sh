#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: prune-aka-titles.sh
# 
#         USAGE: ./prune-aka-titles.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/28/2015 12:39
#      REVISION:  2015-12-28 19:15
#===============================================================================

source ~/bin/sh_colors.sh
# remove TV title
# remove blanks from beginning
unset GREP_OPTIONS
echo "grep seems to fail if multibyte character after our pattern"
echo "ggrep picks it fine ..."
echo -n "Checking for ggrep "
if hash ggrep 2>/dev/null; then
    echo ok
else
    echo fail
    echo "ggrep required due to multibyte data in file. pls install using brew install homebrew/dupes/diffutils. Aborting." 1>&2
    exit 1
fi
hash sponge 2>/dev/null || { echo >&2 "I require sponge but it's not installed (moreutils).  Aborting."; exit 1; }
hash convertiso8859toutf8.sh 2>/dev/null || { echo >&2 "I require convertiso8859toutf8.sh but it's not installed.  Aborting."; exit 1; }
# prunes the utf-8 file and creates aka-titles.pru
INFILE=./aka-titles.list.utf-8
INFILE=./listfiles/aka-titles.list
OFILE=./aka-titles.pru
pinfo "Cleaning up aka-titles data using $INFILE as source"
if [[ ! -f "$INFILE" ]]; then
    echo "File: $INFILE not found"
    exit 1
fi
echo This file has a slightly different format from others as far as intro is concerned
echo So need to clean intro separately.
head -1 $INFILE | grep "^CRC"
found=$( head -1 $INFILE | grep "^CRC" )
if [[ -n "$found" ]]; then
    echo found intro ... removing ...
    sed  '1,/^\=\=\=\=/d' $INFILE > t.t
else
    echo No intro found.
fi
head t.t
wc -l t.t
pdone
pinfo removing TV and other entries ...
ggrep -vE -a '^"|\(aka "|\(TV\)$|\(TV\)\)|\(VG\)$|\(VG\)\)|\(V\)$|\(V\)\)|SUSPENDED|\(\?\?\?\?' t.t | sponge t.t
echo checking ...
ggrep -a "(TV)" t.t | head
ggrep -a '(aka "' t.t | head
error=$(ggrep -a "(TV)" t.t )
if [[ -n "$error" ]]; then
    echo -e "\\033[1m\\033[0;31mThere are still TV entries!!!\\033[22m\\033[0m" >&2
    exit 1
fi
error=$( ggrep -a '(aka "' t.t )
if [[ -n "$error" ]]; then
    echo -e "\\033[1m\\033[0;31mThere are still aka entries!!!\\033[22m\\033[0m" >&2
    exit 1
fi
error=$(ggrep -a "(????" t.t )
if [[ -n "$error" ]]; then
    echo -e "\\033[1m\\033[0;31mThere are still (????!!!\\033[22m\\033[0m" >&2
    exit 1
fi
wc -l t.t
pinfo removing blank lines from start of file
sed '/./,$!d' t.t | sponge t.t
wc -l t.t
echo removing unneeded lines from end of file
error=$( grep -n "^--*$" t.t )
if [[ -n "$error" ]]; then
    line=$( echo "$error" | cut -f1 -d':' )
    echo -e "There is a hyphenated line at $line. Removing data following it." 1<&2
    # sed crashed with illegal byte sequence
    gsed  '/^--*$/,$d' t.t | sponge t.t
    #gsed  '/^--*$/,$d' t.t > t.t1
    #wc -l t.t t.t1
    # head -n -1 t.t could work if we knew that in future junk won't follow.
fi
wc -l t.t
pinfo squeezing consecutive blank lines
grep -A1 . t.t | grep -v "^--$" | sponge t.t
wc -l
echo checking t.t for iso8859
file -I t.t 
error=$( file -I t.t | grep 8859 )
if [[ -n "$error" ]]; then
    echo -e "Seems output file is iso8859, converting ..." 1<&2
    convertiso8859toutf8.sh t.t 
    mv t.t.utf-8 t.t
    file -I t.t
fi
echo done ... head t.t
head t.t
echo ... tail t.t
tail t.t
echo ...
if [[ -f "aka-title.pru" ]]; then
    echo diffing output with earlier file.
    diff t.t $OFILE | head
fi
echo renaming t.t to aka-title.pru 
mv t.t $OFILE
echo you may now run ./normalize on $OFILE.
