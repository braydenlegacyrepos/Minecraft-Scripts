#!/bin/bash
# $1 is amount of days, 1D through to 7D.
# $2 is $USEREMAIL to mail the results of the backup, perhaps an output of the log?
# $4 is $USERNAME
# $5 is $SERVICEID
echo "Restoring backup of $3 from $1 day(s) ago to /home/$4/$5-backup/"
RDIFF_OUTPUT=`rdiff-backup -r ${1}D /backup/$4/$5/ /home/$4/$5-backup/`
echo "Backup should have complted by now, if it has not, then consult the following output: ${RDIFF_OUTPUT}" | mail -s 'JR Network GAMEON! Backup Restoration' -r info@jrnetwork.net $2