#!/bin/bash
DIR=`pwd`
MC_DIR=`zenity --file-selection --directory --filename="${DIR}"`
if [ ! -d /usr/lib/jvm/ ]; then
    JVM_ANSWER=`zenity --question --text="No instance of JVM has been detected.\nShall we attempt to install automatically?" --no-wrap;echo $?`
    if [ ${JVM_ANSWER} = 0 ]; then
        USER_PASS=`zenity --password --title="JVM Installation"`
        DISTRO=`lsb_release -i -s`
        if [ "${DISTRO}" = "Ubuntu" ]; then
            TEST=`echo ${USER_PASS} | sudo -S whoami`
            if [ "${TEST}" != "root" ]; then
                zenity --info --text="You did not enter the correct password or you are not in the sudoers file." --no-wrap
                exit 1
            fi
            # Mojang recommends the use of Oracle Java JRE, but OpenJDK is the only one in the repos now, so it'll have to do.
            echo ${USER_PASS} | sudo -S apt-get -y -f install default-jre
            if [ ! -d /usr/lib/jvm ]; then
                zenity --info --text="OpenJDK JVM seems to have failed installation." --no-wrap
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
    zenity --info --text="Installation appears to have been successful. Script will now continue." --no-wrap
else
    zenity --info --text="Installation appears to have not been successful. Script will now exit." --no-wrap
    exit 1
fi
}
TEST_LYNX=`lynx -version | grep Lynx | sed -n 1p | awk '{printf $1}'`
if [ "${TEST_LYNX}" != "Lynx" ]; then
    lynx_question=`zenity --question --text="lynx does not appear to be installed. Shall we attempt to install it for you?";echo $?`
    if [ ${lynx_question} = 0 ]; then
        if [ "${USER_PASS}" != "" ]; then
            echo "${USER_PASS}" | sudo -S apt-get install -y -f lynx
            lynx-test
        else
            USER_PASS=`zenity --password --title=="lynx Installation"`
            echo "${USER_PASS}" | sudo -S apt-get install -y -f lynx
            lynx-test
        fi
    fi
fi
# Test the wget output. Probably more error codes being detected then there ought to be.
function wget_download {
wget --progress=bar:force "${DOWNLOAD}" 2>&1 | zenity --title="Download Progress" --text="${DOWNLOAD}" --progress --auto-close
if [ `echo $?` != 0 ]; then
    zenity --warning --text "wget returned a non-valid exit code."
fi
}
# Asks if you want to rename the file.
function rename_dialog {
RENAME_ANSWER=`zenity --question --text "Successfully downloaded..\nDo you want to rename the downloaded file?" --no-wrap;echo $?`
if [ "${RENAME_ANSWER}" = "0" ]; then
    NEW_NAME=`zenity --entry --text "New Name:" --entry-text "${JAR}"`
    mv ${JAR} ${NEW_NAME}
    JAR=${NEW_NAME}
fi
}
# Function to create the command line.
function script_gen {
SCRIPT_ANSWER=`zenity --question --text "Do you want the script to attempt to generate a start script?" --no-wrap;echo $?`
if [ "${SCRIPT_ANSWER}" = "0" ]; then
    MEM_TOTAL=`cat /proc/meminfo | grep -w MemTotal: | awk '{printf $2}'`
    MEM=$((${MEM_TOTAL} / 1000))
    if [ ${MEM} -le 512 ]; then
        MEM_ANSWER=`zenity --question --text="You really should not be running Minecraft server on a desktop machine running less than or exactly 512MB of RAM.\nContinue?";echo $?`
        if [ ${MEM_ANSWER} = 0 ]; then
            REC_MEM=1
        else
            exit 0
        fi
    else
        REC_MEM=$((${MEM} - 512))
    fi
    AMOUNT=`zenity --scale --min-value=0 --max-value=${MEM} --text="Memory in MB\nRecommended: ${REC_MEM}MB" --value=${REC_MEM} --step=128`
    DIRECTORY=`zenity --file-selection --filename=${MC_DIR}/minecraft.sh --save --confirm-overwrite 2> /dev/null`
    echo "java -Xincgc -Xms64M -Xmx${AMOUNT}M -jar ${JAR}" > ${DIRECTORY}
    chmod +x ${DIRECTORY}
fi
}
# Check if the jar exists.
function jar_check {
if [ -e "${JAR}" ]; then
    answer=`zenity --question --text "Do you want to remove the existing jar file?" --no-wrap;echo $?`
    if [ "${answer}" = "0" ]; then
        rm -f ${JAR}
    elif [ "${answer}" = "1" ]; then
        REMOVE_ANSWER=`zenity --question --text "Warning:\nThis will result in a second, invalid, file being made.\nContinue?" --no-wrap;echo $?`
        if [ ${REMOVE_ANSWER} = 1 ]; then
            exit 0
        fi
    fi
fi
}

opt=`zenity --list --text "Please choose your choice of server." --radiolist --column "Pick" --column "Server" TRUE Bukkit FALSE Vanilla`
if [ "${opt}" = "Bukkit" ]; then
    lynx -dump -nonumbers http://ci.bukkit.org/job/dev-CraftBukkit/ > /tmp/bukkit
    LATEST_BUILD=`cat /tmp/bukkit | grep "Last successful build" | cut -f2 -d'(' | cut -f1 -d')'`
    LATEST_REC_BUILD=`cat /tmp/bukkit | grep "Latest promotion" | cut -f2 -d'(' | cut -f1 -d')'`
    bukkit_choice=`zenity --list --text "Please choose a version.\nLatest Recommended Build: ${LATEST_REC_BUILD}\nLatest Build: ${LATEST_BUILD}" --radiolist --column "Pick" --column "Version" TRUE Recommended FALSE Latest`
    if [ "${bukkit_choice}" = "Recommended" ]; then
        DOWNLOAD=`lynx -dump -nonumbers http://ci.bukkit.org/job/dev-CraftBukkit/Recommended/ | grep craftbukkit | grep jar | grep Recommended | sed -n 1p`
        JAR=`echo ${DOWNLOAD} | cut -f9 -d'/'`
        cd ${MC_DIR}
        jar_check
        wget_download
        rename_dialog
        script_gen
        rm -f /tmp/bukkit
        exit 0
    elif [ "${bukkit_choice}" = "Latest" ]; then
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
elif [ "${opt}" = "Vanilla" ]; then
    DOWNLOAD=`lynx -dump -nonumbers http://www.minecraft.net/download | grep MinecraftDownload | grep .jar | grep server`
    JAR=`echo ${DOWNLOAD} | cut -f6 -d'/' | cut -f1 -d'?'`
    cd ${MC_DIR}
    jar_check
    wget_download
    rename_dialog
    script_gen
    exit 0
fi