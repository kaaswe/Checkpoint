#!/bin/bash

echo "Start"
dtt=`date '+%Y-%m-%d %H:%M:%S'`
myPath=$PWD
myFile=$(hostname)

echo "$myPath"
echo "$myFile"

# Clean the file and start fresh
echo "" > $myFile.txt
echo $dtt >> $myFile.txt

# Interfaces
echo "################## Get Interfaces list" >> $myFile.txt
echo "#" >> $myFile.txt
echo "#" >> $myFile.txt
ifconfig | awk -F"\t" '{print $1}' | awk -F":" '{print $1}' | sort | uniq >> $myFile.txt

# Interfaces ipv4
echo "################## Interfaces ipv4" >> $myFile.txt
echo "#" >> $myFile.txt
echo "#" >> $myFile.txt
ifconfig | grep "inet " -B 4 | grep -e "flags" -e "inet" >> $myFile.txt
