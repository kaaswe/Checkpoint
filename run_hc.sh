#!/bin/bash
#
# 2020-03-12 spam@janlarsson.net version 1.1
# This script is intended to run as a cronjob on the SMS with the GW name as argument to start
# the healthcheck job remotely. It will then move the output files to the path you set as
# my_logpath.
# you need to prepare your environment by:
#
# 1. create a jobuser for crontab by sk77300
# 2. Place this script on your SMS in /usr/local/bin/ with healthcheck.sh sk121447
# 3. create and set my_logpath
# 4. create a crontab job and run this script with GW as an argument, example:
#    10 02 * * 3 /usr/local/bin/run_hc.sh my_gateway_name
#

#====================================================================================================
#  Check Point Sources & script path & custom error messages
#====================================================================================================
source /tmp/.CPprofile.sh
source /etc/profile.d/CP.sh 2> /dev/null
source /etc/profile.d/vsenv.sh 2> /dev/null
source $MDSDIR/scripts/MDSprofile.sh 2> /dev/null
source $MDS_SYSTEM/shared/sh_utilities.sh 2> /dev/null
source $MDS_SYSTEM/shared/mds_environment_utils.sh 2> /dev/null
candidate_list=/var/tmp/candidate_list

inputpath=/var/log

# set this path to where you like to store your output
my_logpath=/var/log/healthcheck

my_gw=$1
gateway_match=0
errmsg_01="Healthcheck custom script - No Gateway Name was supplied as input, exiting .."
errmsg_02="Healthcheck custom script - Gateway name supplied matched a valid GW on this Management Server."
errmsg_03="Healthcheck custom script - the supplied Gateway name is not found on this Mgmt server."
errmsg_04="Healthcheck custom script - Logpath $my_logpath does not exists - script terminated."


#====================================================================================================
#  Verification of mandatory settings
#====================================================================================================
verify_mandatory_paths()
{
# Verify that script input is supplied, should be the gateway name to run HC on.
if [ -z "$my_gw" ] ; then
        echo "$errmsg_01"
        logger "$errmsg_01"
        exit 1
fi

# verify the logpath exists for longtime storage of previous run
if [ -d "$my_logpath" ]; then
        echo "$my_logpath exists. - Continue"
else
        logger "$errmsg_04"
        echo "$errmsg_04"
        exit 1
fi

}


#====================================================================================================
#  Function to list all gateway items in a domain
#====================================================================================================
run_remote_checks()
{

    #Collect domain login session
    domain_id=/var/tmp/$domain.id

    #SMS Specific operations
        mgmt_cli login --root true > $domain_id
        gateways_and_servers_list=$(mgmt_cli show gateways-and-servers -s $domain_id limit 500)
        current_cma="SMS"


    #====================================================================================================
    #  Create list of remote targets and match input
    #====================================================================================================

    #Collect gateway list
    gateway_list=$(echo "$gateways_and_servers_list" | grep -B1 "simple-gateway" | grep name | awk -F\" '{print $2}')
    echo "$gateway_list" >> $candidate_list

    #Collect Gateway Cluster Member list
    gw_cluster_members_list=$(echo "$gateways_and_servers_list" | grep -B1 "CpmiClusterMember" | grep name | awk -F\" '{print $2}')
    echo "$gw_cluster_members_list" >> $candidate_list

    #Remove blank lines from candidate list
    sed -i "/^$/d" $candidate_list

    my_list=$(cat $candidate_list)
    # echo "$my_list"

    gateway_id=0
    counter=1

    while read line; do
        if [[ "$my_gw" == "$line" ]]; then
            gateway_id="$counter"
            gateway_match=1
            # echo "match found: $gateway_id $line"
        fi
        ((counter++))
    done <<< "$my_list"

    # Check if any match was made
    if [[ "$gateway_match" == "1" ]]; then
        echo "$errmsg_02"
        logger "$errmsg_02"
    else
        echo "$errmsg_03"
        logger "$errmsg_03"
	exit 1
    fi
}

#====================================================================================================
# Call the healthcheck.sh script
#====================================================================================================
run_remote_healthcheck()
{

    echo "Starting the HC script for the gw id provided"
    printf $gateway_id'\n' | /usr/local/bin/healthcheck.sh -r
}

#====================================================================================================
# move the HC output to other location
#====================================================================================================
run_move_output()
{
    sleep 5
    for files in $(ls $inputpath/"$my_gw"_health-check*);
        do
            echo $files
            mv $files $my_logpath/
    done
}

#====================================================================================================
#   Cleanup
#====================================================================================================
cleanup_temp()
{
    rm -f /var/tmp/candidate_list > /dev/null 2>&1
}

#====================================================================================================
#   Main
#====================================================================================================
cleanup_temp
verify_mandatory_paths
run_remote_checks
run_remote_healthcheck
run_move_output
cleanup_temp
# to be developed mail output
