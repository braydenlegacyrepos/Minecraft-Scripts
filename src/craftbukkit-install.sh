#!/bin/bash
DOWNLOAD=`lynx -dump -nonumbers http://ci.bukkit.org/job/dev-CraftBukkit/Recommended/ | grep craftbukkit | grep jar | grep Recommended | sed -n 1p`
JAR=`echo ${DOWNLOAD} | cut -f9 -d'/'`
mv ${JAR} craftbukkit.jar
