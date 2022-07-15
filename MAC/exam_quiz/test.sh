#!/bin/bash
#
# Question and answers in random or squenze by Jan Larsson 2022-07-15 Info@janlarsson.net
# create a file named 'question.txt' in the same folder as this script
# syntax in file
# Q: a Question?
# A: an answer
# A: the answer can be several lines.
# --
# Q: Next question, that also can be on several lines.
# Q: Still the same question you see.
# A: Do you get it?
# --
#
# When this code was written only God and I knew the content,
# Today only God does.
# Don't think you can improve the code, you will certanly fail and waste your time.
# If you still are going to try, please update the counter below:
#
# wastedHoursTrying=254

myPath=$PWD

readfile()
{
# clear
printf "start reading questions\n\n"
count=1
nr=0
set=0

while read -r line
do
	if [[ ${line:0:2} == "Q:" ]]
	then
		if [[ ${set} == "Q" ]]
		then
			printf "Follow up Q"
		else
			(( nr++ ))
		fi
	
		question[$nr]+=$nr" - "${line}"\n"
		printf "${question[$nr]} \n"
		set="Q"
	fi
	if [[ ${line:0:2} == "A:" ]]
	then
		set="A"
		answer[$nr]+=${line}"\n"
                printf "${answer[$nr]} \n"
	fi

        # printf "${line}  \n"
        (( count++ ))
done < "$myPath/question.txt"
}

displayOrder()
{
orderNr=1
while [ ${orderNr} -le ${nr} ]
do
	clear
	printf "${question[$orderNr]} \n\n"
        read -p 'Enter to show Answer'
        printf "\n${answer[$orderNr]} \n\n"
	read -p 'Next Question (or enter nr): ' manualNr
	if [[ ${manualNr} ]]
	then
		orderNr=${manualNr}
	else
		(( orderNr++ ))
	fi
done
}

####################################
##### Main
####################################
BRed='\033[1;31m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
printf "##################\n"
printf "# ${BRed}Exam Prepp${NC}     #\n"
printf "##################\n\n"

printf "1. Random questions or\n2. Questions in sequense?\n\n"
read -p 'Choose' order
readfile
printf "\n\nReading of file sucessful?\nThis test contains ${nr} questions.\n"
read -p 'All good? Enter to start.'
clear

while true
do
	
	read -p 'next question: (x to eXit) ' quit
	clear
	if [[ ${quit} == "x" ]]
	then
		exit
	fi 
	if [[ ${order} == "1" ]]
	then
		random=$(( ( RANDOM % ${nr} )  + 1 ))
		printf "${question[$random]} \n\n"
		read -p 'Enter to show Answer'
		printf "\n${answer[$random]} \n\n"
	else
		displayOrder
	fi
done
