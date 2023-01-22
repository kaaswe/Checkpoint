#!/bin/bash

# This settings file customize your settings for the honeypot script.


##############################################
### This needs to be prepared:
##############################################

## 3.
# Set the path for the script
export scriptPath="/home/user/Documents/scripts"

## 4.
# path where to store the outcome of the "prevent backup status".
# In my setup this file is checked if exists by external backup program
export blpath=/mnt/device/backups

## 5.
# NAS_alert_IP - This is the external address to Domoticz that will set the dummy device status.
# if you don't have any external dashboard just remove the curl line in the procedure and replace it with anything you like.
export nas_alert_ip="10.10.10.10:80"

# 6.
## Honeypot files path and access date.
# This check can be extended to add another set of folders starting with a late character like zoom, incase the malware works in reversed order.
# in the folders below, make sure to create 2 files, one with a low naming and one high. These are dummyfiles and you should never touch them as we are reading the accessed date on the files.
export honeypot_file_01="/mnt/device/homes/user_1/aaa_dir"
export honeypot_file_01_date="20220208"

export honeypot_file_02="/mnt/device/homes/user_2/aaanoter_dir"
export honeypot_file_02_date="20220208"

# 7.
## When done with all settings, change to 1.
export ImDone="0"
