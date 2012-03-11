#!/bin/bash
BACKUP_USERNAME=root
REMOTE_HOST=irc
if [ "$1" = "Terraria" ]; then
    TERRARIA_SRC=~/Terraria/
    TERRARIA_DST=/terraria-backup/
    echo "Terraria backup starting."
    rdiff-backup --print-statistics ${TERRARIA_SRC} ${REMOTE_HOST}::${TERRARIA_DST} >> ~/Terraria-backup.log
elif [ "$1" = "Minecraft" ]; then
    MINECRAFT_SRC=~/Minecraft/Main/
    MINECRAFT_DST=/mc-backup/
    echo "Minecraft backup starting."
    rdiff-backup --print-statistics ${MINECRAFT_SRC} ${REMOTE_HOST}::${TERRARIA_DST} >> ~/Minecraft-backup.log
else
    echo -e "Accepted arguments are:\nMinecraft\nTerraria\nRev: 1"
fi