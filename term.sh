#!/bin/bash
#
# SSH Menu script version 1.0.2  by Jan Larsson 2020-05-24 Info@janlarsson.net
# This script lists SSH sessions to servers and builds the menu dynamically by the filenames.
# Note: all .txt files in the current folder will be part of the menu.

# group the menu by creating different server lists:
# home.txt
# customer.tx

# Fill the files with 2 columns:
# user@server description
#
# When executed a new terminal will be opened and a SSH session started.

myPath=$PWD

##### def
##########################
# Read user input and list all servers for that choice
##########################
listServers()
{
clear
printf "################\n"
printf "# ${BRed}SSH sessions${NC} #\n"
printf "################\n\n"

count=1

while read -r line desc
do
        line[$count]=$line
        desc[$count]=$desc

        printf "$count: ${line[$count]} ${desc[$count]} \n"
        (( count++ ))
done < "$myPath/${file[$choice]}"

printf "\nx. back\n\n"
# len=${#line[@]}
# ld=${#desc[@]}
# printf "\n\nLine: $len \n"
# printf "Desc: $ld \n\n"	
}

#############################
# Open SSH for the selected choice
############################
selectFromList()
{
read -p 'server: ' server
if [[ server -eq "x" ]]
then
	printf "Backing."
else
	echo ssh ${line[$server]} > $myPath/scriptfile
	chmod +x $myPath/scriptfile
	open -a Terminal.app scriptfile
fi

# ssh ${line[$server]}	
}

####################################33
# list files
####################################
list_files()
{
c=1
for file in *.txt
do
	file[$c]=$file
	printf "$c - ${file[$c]}" | sed 's/.txt//g'
	(( c++ ))
done
}

####################################
##### Main
####################################
BRed='\033[1;31m'
RED='\033[0;31m'
NC='\033[0m' # No Color

while true
do
	clear
	printf "##################\n"
	printf "# ${BRed}SSH Menu${NC}       #\n"
	printf "##################\n\n"
	list_files
	printf "\nX. Exit\n\n"
	read -p 'Choose: ' choice
	if [[ choice -eq "x" ]]
	then
		exit
	fi

	listServers
	selectFromList
done


