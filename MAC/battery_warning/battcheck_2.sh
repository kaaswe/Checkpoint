#!/bin/bash

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

# Battery check and notificaiton script with option to supress pop-up messages. if supressed the script will be silent until Low level is hit \
# where the alerts will continue to pop up untill the power adapter is connected.
# once battery level has charged over the Level the supress token will reset.
#
# spam@janlarsson.net - 2021-07-26
# version 2.0.0
#
# make the script to run at Logon by adding a plist, create the plist as below and save it in:
# ~/Library/LaunchAgents/com.battcheck_2.plist 
# change the path in <string> to match your script location
#
# https://dev.to/kyleparisi/running-scripts-at-login-macos-po9
#<?xml version="1.0" encoding="UTF-8"?>
#<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
#<plist version="1.0">
#    <dict>
#        <key>Label</key>
#        <string>com.battcheck_2.app</string>
#        <key>Program</key>
#        <string>/Users/yourUserId/battcheck_2.sh</string>
#        <key>RunAtLoad</key>
#        <true/>
#    </dict>
#</plist>
#
# set your desirerd battery level to trigger a warning and the low level for final warning.
myBattLevel="80"
myBattLevelLow="79"

# initial supress status
mySuppress="False"

checkBattery() {

	batt=`ioreg -l | awk '$3~/Capacity/{c[$3]=$5}END{OFMT="%.0f";max=c["\"MaxCapacity\""];print(max>0?100*c["\"CurrentCapacity\""]/max:"?")}' | sed  's/%//'`
        # echo ${batt}

        if [ $batt -le $myBattLevel ]
        then
		if [ $mySuppress == "False" ]
		then
	                displaynotification
		fi
	else
		# reset supress flag as battery level is over limit set
		mySuppress="False"
        fi

	# very low warning where we don't care if supress is set.
	if [ $batt -le $myBattLevelLow ]
	then
		# check if powerAdapter is plugged in
		adapter=`ioreg -l | grep BatteryData | awk 'BEGIN { FS="," } /AdapterPower/ {print $10}' | sed 's/"AdapterPower"=//g'`
		
		# if no adapter
		if [ $adapter == "0" ]
		then
			say "Time to get the power adapter"
			displaynotification
		fi
	fi
}

displaynotification() {
        say "Warning. Low battery level '#{$batt}'"

	myResult=$(osascript <<-EndOfScript
	with timeout of 30 seconds -- wait x seconds
		display dialog "Warning. Low battery - " & $batt & " %" with title "Battery Low" with icon caution buttons {"Ok"} giving up after (30)
	end timeout
	EndOfScript)

	if [[ "$myResult" == *"true"* ]]
	then
        	mySuppress="False"
	else
        	mySuppress="True"
	fi
}


# main with endless loop.
while true
do
	checkBattery
	
	# echo ${mySuppress}
sleep 60;
done
