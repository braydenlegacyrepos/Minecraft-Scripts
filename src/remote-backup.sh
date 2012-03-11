#!/bin/bash
BACKUP_USERNAME=root
REMOTE_HOST=irc
if [ "$1" = "Terraria" ]; then
    TERRARIA_SRC=~/Terraria/Worlds/
    TERRARIA_DST=/terraria-backup/
    echo "Terraria backup starting."
    rdiff-backup --print-statistics ${TERRARIA_SRC} ${BACKUP_USERNAME}@${REMOTE_HOST}::${TERRARIA_DST} >> ~/Terraria-backup.log
elif [ "$1" = "Minecraft" ]; then
    MINECRAFT_SRC=~/Minecraft/Main/world/
    MINECRAFT_DST=/mc-backup/
    echo "Minecraft backup starting."
    rdiff-backup --print-statistics ${MINECRAFT_SRC} ${BACKUP_USERNAME}@${REMOTE_HOST}::${MINECRAFT_DST} >> ~/Minecraft-backup.log
else
    echo -e "Accepted arguments are:\n$0 Minecraft\n$0 Terraria\nRev: 4 (final)"
fi