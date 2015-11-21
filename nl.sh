#!/usr/bin/env zsh 
#===============================================================================
#
#          FILE: nl.sh
# 
#         USAGE: ./nl.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 11/18/15 23:16
#      REVISION:  ---
#===============================================================================
#
items=$(nl)
max=15
leni=$( echo -e "${items}" | grep -c . )
if (( leni > max )); then
    print -rC2 "${(@f)$(print -l -- $items)}"
else
    echo -e "$items"
fi
