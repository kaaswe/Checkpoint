#!/bin/bash

#For logs
fw logswitch
fw logswitch -audit
rm -f $FWDIR/log/20*
rm -f $FWDIR/log/saved.*

rm -f /var/log/messages* && touch /var/log/messages && chmod 744 /var/log/messages
rm -f /var/log/secure* && touch /var/log/secure && chmod 600 /var/log/secure
rm -f /var/log/auth && touch /var/log/auth && chmod 600 /var/log/auth
rm -f /var/log/httpd*

touch /var/log/httpd2_access_log && chmod 644 /var/log/httpd2_access_log
touch /var/log/httpd2_error_log && chmod 644 /var/log/httpd2_error_log
touch /var/log/httpd_access_log && chmod 644 /var/log/httpd_access_log

find $FWDIR/log/packets_captures -type f -exec rm '{}' ';'
find $FWDIR/log/captures_repository -type f -exec rm '{}' ';'
for i in $FWDIR/log/*.elg* ; do cat /dev/null > $i; done

#Smartlog indexes
rm -rf $SMARTLOGDIR/data/*

# DLP events
$DLPDIR/scripts/dlpcleanup

# Smart event database - stop here if you want to just clean up the logs not smartevent
cpstop
$CPDIR/database/postgresql/util/PostgreSQLCmd start
$CPDIR/database/postgresql/bin/psql -p 18272 -U cp_postgres postgres -c "drop database events_db"
$CPDIR/database/postgresql/util/PostgreSQLCmd stop
cpstart
