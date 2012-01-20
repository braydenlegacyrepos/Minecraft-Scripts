#!/bin/bash
DIR=`pwd`
TITLE="Minecraft Server Installation"
MC_DIR=`dialog --title "${TITLE}" --backtitle "${TITLE}" --inputbox "Where do you want to install the server to?" 8 60 "${DIR}" --stdout`
if [ ! -d /usr/lib/jvm/ ]; then
    JVM_ANSWER=`dialog --title "${TITLE}" --backtitle "${TITLE}" --yesno "Java Virtual Machine is not present in /usr/bin/jvm/\nContinue?" 6 60; echo $?`
    if [ ${JVM_ANSWER} = 0 ]; then
        DISTRO=`lsb_release -i -s`
        if [ "${DISTRO}" = "Ubuntu" ]; then
            sudo apt-get -y -f install default-jre
            if [ ! -d /usr/lib/jvm ]; then
                dialog --title "${TITLE}" --backtitle "${TITLE}" --msgbox "JVM appears to have failed installation." 5 60
                exit 1
            fi
        fi
    else
        exit 0
    fi
fi

function lynx-test {
RETEST_LYNX=`lynx -version | grep Lynx | sed -n 1p | awk '{printf $1}'`
if [ "${RETEST_LYNX}" == "Lynx" ]; then
    dialog --title "Lynx Installation" --backtitle "${TITLE}" --msgbox "Installation appears to have been successful. Script will now continue." 5 80
else
    dialog --title "Lynx Installation" --backtitle "${TITLE}" --msgbox "Installation appears to have not been successful." 5 60
    exit 1
fi
}
TEST_LYNX=`lynx -version | grep Lynx | sed -n 1p | awk '{printf $1}'`
if [ "${TEST_LYNX}" != "Lynx" ]; then
    lynx_question=`dialog --title "Lynx Installation" --backtitle "${TITLE}" --yesno "lynx does not appear to be installed. Shall we attempt to install it for you?" 5 85; echo $?`
    if [ ${lynx_question} = 0 ]; then
        sudo apt-get install -y -f lynx
        lynx-test
    fi
fi
# Test the wget output. Probably more error codes being detected then there ought to be.
function wget_download {
wget --progress=bar:force "${DOWNLOAD}"
if [ `echo $?` != 0 ]; then
    dialog --title "${TITLE}" --backtitle "${TITLE}" --msgbox "wget returned a non-valid exit code." 5 60
    exit 1
fi
}
# Asks if you want to rename the file.
function rename_dialog {
RENAME_ANSWER=`dialog --title "${TITLE}" --backtitle "${TITLE}" --yesno "Successfully downloaded..\nDo you want to rename the downloaded file?" 6 60; echo $?`
if [ "${RENAME_ANSWER}" = "0" ]; then
    NEW_NAME=`dialog --title "${TITLE}" --backtitle "${TITLE}" --inputbox "New Name:" 8 80 "${JAR}" --stdout`
    mv ${JAR} ${NEW_NAME}
    JAR=${NEW_NAME}
fi
}
# Function to create the command line.
function script_gen {
SCRIPT_ANSWER=`dialog --title "${TITLE}" --backtitle "${TITLE}" --yesno "Do you want the script to attempt to generate a start script?" 8 80; echo $?`
if [ "${SCRIPT_ANSWER}" = "0" ]; then
    MEM_TOTAL=`cat /proc/meminfo | grep -w MemTotal: | awk '{printf $2}'`
    MEM=$((${MEM_TOTAL} / 1000))
    if [ ${MEM} -le 512 ]; then
        MEM_ANSWER=`dialog --title "${TITLE}" --backtitle "${TITLE}" --yesno "You really should not be running Minecraft server on a computer with less than exactly 512MB of RAM.\nContinue?" 6 80; echo $?`
        if [ ${MEM_ANSWER} = 0 ]; then
            REC_MEM=1
        else
            exit 0
        fi
    else
        REC_MEM=$((${MEM} - 512))
    fi
    AMOUNT=`dialog --title "${TITLE}" --backtitle "${TITLE}" --inputbox "Memory in MB\nRecommended: ${REC_MEM}MB" 8 60 "${REC_MEM}" --stdout`
    if [ "${AMOUNT}" -gt "${MEM}" ]; then
        dialog --title "${TITLE}" --backtitle "${TITLE}" --msgbox "You cannot set more memory than your actual amount of memory."
        exit 1
    fi
    DIRECTORY=`dialog --title "${TITLE}" --backtitle "${TITLE}" --inputbox "Where do you want to save the file?" 8 80 "${MC_DIR}/minecraft.sh" --stdout`
    echo "java -Xincgc -Xms64M -Xmx${AMOUNT}M -jar ${JAR}" > ${DIRECTORY}
    chmod +x ${DIRECTORY}
fi
}
# Check if the jar exists.
function jar_check {
if [ -e "${JAR}" ]; then
    answer=`dialog --title "${TITLE}" --backtitle "${TITLE}" --yesno "Do you want to remove the existing jar file?" 5 50; echo $?`
    if [ "${answer}" = "0" ]; then
        rm -f ${JAR}
    elif [ "${answer}" = "1" ]; then
        REMOVE_ANSWER=`dialog --title "${TITLE}" --backtitle "${TITLE}" --yesno "Warning:\nThis will result in a second, invalid file being made.\nContinue?" 7 60; echo $?`
        if [ ${REMOVE_ANSWER} = 1 ]; then
            exit 0
        fi
    fi
fi
}

opt=`dialog --title "${TITLE}" --backtitle "${TITLE}" --radiolist "Please choose your choice of server." 9 40 2 \
1 Bukkit on \
2 Vanilla off \
--stdout`
if [ "${opt}" = "1" ]; then
    lynx -dump -nonumbers http://ci.bukkit.org/job/dev-CraftBukkit/ > /tmp/bukkit
    LATEST_BUILD=`cat /tmp/bukkit | grep "Last successful build" | cut -f2 -d'(' | cut -f1 -d')'`
    LATEST_REC_BUILD=`cat /tmp/bukkit | grep "Latest promotion" | cut -f2 -d'(' | cut -f1 -d')'`
    bukkit_choice=`dialog --title "${TITLE}" --backtitle "${TITLE}" --radiolist "Please choose a version.\nLatest Recommended Build: ${LATEST_REC_BUILD}\nLatest Build: ${LATEST_BUILD}" 11 40 2 \
    1 Recommended on \
    2 Latest off \
    --stdout`
    if [ "${bukkit_choice}" = "1" ]; then
        DOWNLOAD=`lynx -dump -nonumbers http://ci.bukkit.org/job/dev-CraftBukkit/Recommended/ | grep craftbukkit | grep jar | grep Recommended | sed -n 1p`
        JAR=`echo ${DOWNLOAD} | cut -f9 -d'/'`
        cd ${MC_DIR}
        jar_check
        wget_download
        rename_dialog
        script_gen
        rm -f /tmp/bukkit
        exit 0
    elif [ "${bukkit_choice}" = "2" ]; then
        DOWNLOAD=`cat /tmp/bukkit | grep "craftbukkit" | sed -n 2p`
        JAR=`echo ${DOWNLOAD} | cut -f9 -d'/'`
        cd ${MC_DIR}
        jar_check
        wget_download
        rename_dialog
        script_gen
        rm -f /tmp/bukkit
        exit 0
    fi
elif [ "${opt}" = "2" ]; then
    DOWNLOAD=`lynx -dump -nonumbers http://www.minecraft.net/download | grep MinecraftDownload | grep .jar | grep server`
    JAR=`echo ${DOWNLOAD} | cut -f6 -d'/' | cut -f1 -d'?'`
    cd ${MC_DIR}
    jar_check
    wget_download
    rename_dialog
    script_gen
    exit 0
fi