#!/bin/bash
#
# Version 0.3 - Honeypot checks
# Includes a separate file for settings.sh
# 2023-01-22

# Some simple checks to detect abnormal behavior and alert on them.
# 1 - checking for processes originating from /tmp folder.
# 2 - counting number of root accounts
# 3 - counting number of users on system.
# 4 - md5sum check on certain files.
# 5 - checking file last accessed time.

### Background
# This honeypot script run on a linux host with multiple disks to act as a NAS. The disks sync nightly with rsync.
# The purpose is to react on intrusion early and disconnect the Backup disk to prevent that encrypted files will be synced.

### How it works.
# -this script should be run on an interval from crontab, like */1 every minute.
# -if any of the 5 procedure calls in the script alerts and sets the status=1 an external notify will be done. In this case update a dashboard in Domoticz.
# -all variables are set and loaded on each run from the settings.sh

### Tweak
# a false positive process can be whitelisted in the file exceptions.txt
# The file is autocreated at first run, NOTE: Do NOT remove the first line saying grep.

### If you have backup and separate disks.
# 1 Have the extra disk unmounted
# 2 run backup once a day if status=0, mount disk first.
# 3 after completed backup umount disk.

# alert translation. Beside the scritp sets 'status' we also set the alertType as a binary number to be able to show if one or more procedures has been affected.
alertType="100000000"
# 00000001 - Process running from tmp
# 00000010 - New Root User
# 00000100 - Count of user accounts
# 00001000 - Md5check honeypot files
# 00010000 - Honeypot files read date altered.



##############################################
### This needs to be prepared:
##############################################
## 1.
# Build a file that contains one to whatever you like number of files to verify their integrity by a MD5sum.
# add new files to the md5check simply by running this:
# 'md5sum filename.ext >> md5check.txt'

## 2.
# Set the current number of users in your system. remember to update this count if you add any new users, or you'll get alerted.
# check the current count of users, run cat /etc/passwd | wc -l
normal_user_count=48

## 3.
# The settings.sh file has to be updated with all the variables you wish.


###########################################################
###########################################################

###### Don't touch below
# Reads and loads all the settings
myPath=$PWD
source $myPath/settings.sh
status=0
alertFile="$scriptPath/alertFile.txt"
honeypotPath="$scriptPath/honeypot.log"
exceptions="$scriptPath/exceptions.txt"

##############################################
# Verify script dependencies
##############################################
check_dependencies()
{

if [[ -f "$myPath/settings.sh" ]] ; then
        echo "Settings.sh file exists and we are good to run."
else
        echo "You need to edit the settings.sh file as instructed in step 3."
        exit 0
fi

if [[ "$ImDone" -eq "1" ]] ; then
	echo "Ready to rock."
else
	echo "You have not completed the settings-file."
	exit 0
fi

if [[ -f "$scriptPath/md5check.txt" ]] ; then
        echo "MD5 files exists for checking."
else
        echo "You need to create the md5check.txt file as instructed in step 1."
        exit 0
fi

if [[ -f "$exceptions" ]] ; then
	echo "Exception file for processes exists."
else
	echo "Dependencies - Exception file for processes doest not exist, creating it - Done."
	echo "grep" > $exceptions
fi
}

##############################################
# read exceptions from file
##############################################
read_exceptions()
{
while read -r line
do
        exception+=" -e \"$line\""
done < "$exceptions"
echo "this is the exceptions: $exception"
}

##############################################
# Verify the results for for honeypots
##############################################
verify_honeypot_results()
{
# Check if alert alread has been raised.
if [[ -f "$blpath/prevent_backup.txt" ]] ; then
	echo "Error has been detected"
	return 
else
	echo "No error"
fi


# Verify the honeypot status and update Domoticz of the error and then exit backup program
if [[ "$status" == "1" ]] ; then
        echo "$my_date - true - honeypot file alterd" >> $blpath/prevent_backup.txt
        nas_alert=`curl -s "http://$nas_alert_ip/json.htm?type=command&param=udevice&idx=112&nvalue=4&svalue=Alert:$alertType"`
	echo $alertType > $alertFile
fi

}

#################################################
### Check for process running from tmp
# normal output = 0
#################################################
check_tmp()
{
    count=0
    my_ps="ps aux | grep -i "\/tmp" | grep -v $exception"
    echo -e "the ps outcome should be based on: $my_ps"
    my_tmp=$(eval $my_ps) 
    count=$(eval $my_ps | wc -l)

    echo "The count of process is: $count"

    if [[ $count == 0 ]]; then
        echo "OK - process"
    else
	echo "Process - ERROR"
        # Error normal output should be = 0
        status=1
	alertType=`echo "$alertType" | bc | rev  | sed 's/./1/1' | rev`
        echo "$my_date - ERROR - Process running from /tmp detected." >> $honeypotPath
	echo "$my_tmp" >> $honeypotPath
    fi
}

#################################################
### Check for new root users
#################################################
check_root()
{
    my_root=`grep -P '[^\d]:0:' /etc/passwd | wc -l`
    # echo $my_root

    if [[ $my_root == 1 ]]; then
        echo "OK - root"
    else
        # Error normal output should be = 1
        status=1
	alertType=`echo "$alertType" | bc | rev  | sed 's/./1/2' | rev`
        echo "$my_date - ERROR - More than 1 root account detected." >> $honeypotPath
    fi
}

#################################################
### Count and compare users and what it used to be
#################################################
check_users()
{
    my_users=`cat /etc/passwd | wc -l`
    # echo $my_users

    if [[ $my_users == "$normal_user_count" ]]; then
        echo "OK - passwd"
    else
        # failed
        status=1
	alertType=`echo "$alertType" | bc | rev  | sed 's/./1/3' | rev`
        echo "$my_date - ERROR - Number of users has changed"  >> $honeypotPath

    fi
}

##############################################
# Honypot Function MD5 check
##############################################
check_md5_files()
{
    res=`md5sum -c md5check.txt`
    # echo $res

    if [[ $res == *"FAILED"* ]]; then
        # echo "Failed"
        status=1
	alertType=`echo "$alertType" | bc | rev  | sed 's/./1/4' | rev`
        echo "$my_date - ERROR - md5sum missmatch." >> $honeypotPath
        echo "$res" | grep "FAILED" >> $honeypotPath
    fi
}

##############################################
# Function to loop files and verify against access dates on certain files.
##############################################
# $1 the date
# $2 the path to check

check_honeypot_files()
{
res=""
res=`find $2 -type f -printf '%AY%Am%Ad\n' `

while read line; do
        if [[ "$1" != "$line" ]]; then
                # Date mismatch, status=1 is error
                status=1
		alertType=`echo "$alertType" | bc | rev  | sed 's/./1/5' | rev`	
                echo "$my_date - ERROR - Honeypot files has been accessed: $res - $1 $status"  >> $honeypotPath
        else
            # OK
            echo "OK - honeypot files read date untouched." 
        fi
    done <<< "$res"
}


##############################################
# main
##############################################
# Loop is disabled and the script runs by crontab every minute

# while true;
# do
    my_date=$(date '+%Y-%m-%d %H:%M:%S')
    # echo "$my_date - INFO - Check has been run." >> $honeypotPath
    check_dependencies
    read_exceptions
    check_users
    check_root
    check_tmp
    check_md5_files
    check_honeypot_files "$honeypot_file_01_date" "$honeypot_file_01"
    check_honeypot_files "$honeypot_file_02_date" "$honeypot_file_02"

    verify_honeypot_results

#    echo "Completed - $my_date"
#    sleep 60
# done

