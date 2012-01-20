#!/bin/bash
# 5:02PM, 20/1/2012, screw my life.
# $1 is $USERNAME, $2 is $SERVICEID, $3 is $PASSWORD, $4 is USEREMAIL $5 Remove, Install or LogBlock
PASSWORD=whateverthepasswordis
if [ "$5" = "Install" ]; then
    mysqladmin -hlocalhost -uroot -p${PASSWORD} create $1_$2
    mysql -hlocalhost -uroot -p${PASSWORD} --exec="CREATE USER '$1'@'localhost' IDENTIFIED BY '$3'"
    mysql -hlocalhost -uroot -p${PASSWORD} --exec="GRANT USAGE ON *.* TO '$1'@'localhost'; GRANT SELECT,INSERT,UPDATE,DELETE,INDEX,ALTER,CREATE,DROP ON $1_$2. * TO '$1'@'localhost'"
    echo -e "Created Database $1_$2 for the username $1.\nYou can login at http://gameon.jrnetwork.net/phpmyadmin/ with your CP username and password now." | mail -s 'JR Network GAMEON! MySQL Information' -r info@jrnetwork.net $4
elif [ "$5" = "Remove" ]; then
    mysql -hlocalhost -uroot -p${PASSWORD} --exec="DROP database $1_$2"
    mysql -hlocalhost -uroot -p${PASSWORD} --exec="REVOKE ALL PRIVILEGES ON *.* FROM '$1'@'localhost';"
    mysql -hlocalhost -uroot -p${PASSWORD} --exec="DROP USER '$1'@'localhost'"
elif [ "$5" = "LogBlock" ]; then
#    if [ -e /home/$1/service$2/plugins/LogBlock/config.yml ]; then
    #if [ ! -e plugins/LogBlock.jar ]; then
    #    echo "Did not detect a valid installation of LogBlock."
    #    exit 1
    #fi
cat > ./config.yml <<DELIM
tools:
  tool:
    defaultEnabled: true
    mode: LOOKUP
    aliases:
    - t
    params: area 0 all sum none limit 15 desc silent
    leftClickBehavior: NONE
    item: 270
    rightClickBehavior: TOOL
    permissionDefault: 'TRUE'
  toolblock:
    params: area 0 all sum none limit 15 desc silent
    permissionDefault: 'TRUE'
    rightClickBehavior: BLOCK
    item: 7
    mode: LOOKUP
    defaultEnabled: true
    aliases:
    - tb
    leftClickBehavior: TOOL
mysql:
  user: $1
  port: 3306
  password: $3
  host: localhost
  database: $1_$2
logging:
  hiddenBlocks:
  - 0
  logCreeperExplosionsAsPlayerWhoTriggeredThese: false
  logPlayerInfo: true
  hiddenPlayers: []
  logKillsLevel: PLAYERS
consumer:
  timePerRun: 200
  useBukkitScheduler: true
  forceToProcessAtLeast: 20
  delayBetweenRuns: 6
lookup:
  linesLimit: 1500
  defaultTime: 30 minutes
  defaultDist: 20
  linesPerPage: 15
questioner:
  askClearLogs: true
  banPermission: mcbans.ban.local
  askRollbacks: true
  askRedos: true
  askClearLogAfterRollback: true
  askRollbackAfterBan: false
updater:
  checkVersion: true
  installSpout: true
loggedWorlds:
- world
- world_nether
clearlog:
  enableAutoClearLog: false
  auto:
  - world "world" before 365 days all
  - world "world" player lavaflow waterflow leavesdecay before 7 days all
  - world world_nether before 365 days all
  - world world_nether player lavaflow before 7 days all
  dumpDeletedLog: false
rollback:
  replaceAnyway:
  - 8
  - 9
  - 10
  - 11
  - 51
  maxArea: 50
  dontRollback:
  - 10
  - 11
  - 46
  - 51
  maxTime: 2 days
version: '1.41'
DELIM
#    else
#        echo "File probably not found."
#    fi
fi