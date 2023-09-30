#!/bin/bash
#
# version 1.0
# Retrieves the latest ip list of TOR exits.
# List contains both ipv4 and ipv6
# schedule as a crontab task to run daily

old=`cat tor.list | wc -l`
mv tor.list tor_1.list
curl https://secureupdates.checkpoint.com/IP-list/TOR.txt -o tor.list
new=`cat tor.list | wc -l`

diff tor.list tor_1.list
printf "\nOld list: $old - New list: $new\n\n"

