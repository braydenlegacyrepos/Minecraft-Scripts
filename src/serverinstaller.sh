#!/bin/bash
echo "Please enter the directory that you wish to install into."
printf ": "
read MC_DIR
if [ ! -d ${MC_DIR} ]; then
    echo "Incorrect."
    exit 1
fi
# Check if there's a JVM installed.
if [ ! -d /usr/lib/jvm/ ]; then
    echo "No JVM installations have been detected. Shall we attempt to install it for you?"
    printf "[Y/N] [Y]: "
    read answer
    if [ "${answer}" = "Y" ] || [ "${answer}" = "y" ] || [ "${answer}" = "" ]; then
        echo "Your password will be required for the installation to succeed."
        echo "Please make sure that you are present in the sudoers file and therefore can use the 'sudo' command."
        DISTRO=`lsb_release -i -s`
        if [ "${DISTRO}" = "Ubuntu" ]; then
            # I spent about half an hour making a script to check for the distro and such and make a line to in sources.list, then I found out that Ubuntu removed Sun JRE from the partner repo about 8 hours before D:
            # So now we just have to use OpenJDK.
            sudo apt-get -y -f install default-jre
            if [ ! -d /usr/lib/jvm ]; then
                echo "It seems that the Java virtual machine was still not successfully installed."
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
    echo "Installation appears to have been successful. Script will now continue."
else
    echo "Installation appears to have not been successful. Script will now exit."
    exit 1
fi
}

TEST_LYNX=`lynx -version | grep Lynx | sed -n 1p | awk '{printf $1}'`
if [ "${TEST_LYNX}" != "Lynx" ]; then
    echo "Lynx was not detected, shall we attempt to install it?"
    printf "[Y/N] [Y]: "
    read lynx_question
    if [ "${lynx_question}" = "Y" ] || [ "${lynx_question}" = "y" ] || [ "${lynx_question}" = "" ]; then
            sudo apt-get install -y -f lynx
            lynx-test
    fi
fi

# Test the wget output. Probably more error codes being detected then there ought to be.
function wget_download {
wget "${DOWNLOAD}"
if [ $? != 0 ]; then
    echo "wget returned a non-valid exit code."
fi
}
# Asks if you want to rename the file.
function rename_dialog {
echo "Successfully downloaded, do you want to rename the file?"
printf "[Y/N] [N]: "
read RENAME_ANSWER
if [ "${RENAME_ANSWER}" = "Y" ] || [ "${RENAME_ANSWER}" = "y" ]; then
    printf "${JAR}: "
    read NEW_NAME
    mv ${JAR} ${NEW_NAME}
    JAR=${NEW_NAME}
fi
}
# Function to create the command line.
function script_gen {
echo "Do you want to generate a start script?"
printf "[Y/N] [Y]: "
read SCRIPT_ANSWER
if [ "${SCRIPT_ANSWER}" = "Y" ] || [ "${SCRIPT_ANSWER}" = "y" ] || [ "${SCRIPT_ANSWER}" = "" ]; then
    MEM_TOTAL=`cat /proc/meminfo | grep -w MemTotal: | awk '{printf $2}'`
    MEM=$((${MEM_TOTAL} / 1000))
    REC_MEM=$((${MEM} - 512))
    echo "Please enter the amount of memory you wish to allocate. Numbers only."
    printf "${REC_MEM}MB: "
    read AMOUNT
    echo "Please enter the name you want for the script. It should end with .sh."
    read filename
    if [ "${AMOUNT}" -gt "${MEM}" ]; then
        echo "You entered an amount of memory higher than your actual system's capacity."
        exit 1
    fi
    echo "java -Xincgc -Xms64M -Xmx${AMOUNT}M -jar ${JAR}" > ${filename}
    chmod +x ${filename}
fi
}
# Check if the jar exists.
function jar_check {
if [ -e "${JAR}" ]; then
    echo "Do you want to remove the existing jar file?"
    printf "[Y/N] [Y]: "
    read answer
    if [ "${answer}" = "Y" ] || [ "${answer}" = "y" ] || [ "${answer}" = "" ]; then
        rm -f ${JAR}
    elif [ "${answer}" = "N" ] || [ "${answer}" = "n" ]; then
        echo "Warning: This will result in a second, invalid, file being made. Continue?"
        printf "[Y/N] [N]: "
        read CONTINUE_ANSWER
        if [ "${CONTINUE_ANSWER}" = "N" ] || [ "${CONTINUE_ANSWER}" = "n" ] || [ "${CONTINUE_ANSWER}" = "" ]; then
            exit 0
        fi
    fi
fi
}
BUKKIT_OPT="Bukkit Vanilla"
select opt in ${BUKKIT_OPT}; do
if [ "${opt}" = "Bukkit" ]; then
    lynx -dump -nonumbers http://ci.bukkit.org/job/dev-CraftBukkit/ > /tmp/bukkit
    LATEST_BUILD=`cat /tmp/bukkit | grep "Last successful build" | cut -f2 -d'(' | cut -f1 -d')'`
    LATEST_REC_BUILD=`cat /tmp/bukkit | grep "Latest" | cut -f2 -d'(' | cut -f1 -d')'`
    echo "Latest Bukkit Recommended Build: ${LATEST_REC_BUILD}"
    echo "Latest Bukkit Build: ${LATEST_BUILD}"
    BUKKIT_SERVERS="Recommended Latest"
    select bukkit_choice in ${BUKKIT_SERVERS}; do
    if [ "${bukkit_choice}" = "Recommended" ]; then
        DOWNLOAD=`lynx -dump -nonumbers http://ci.bukkit.org/job/dev-CraftBukkit/Recommended/ | grep craftbukkit | grep jar | grep Recommended | sed -n 1p`
        JAR=`echo ${DOWNLOAD} | cut -f9 -d'/'`
        cd ${MC_DIR}
        jar_check
        wget_download
        rename_dialog
        script_gen
        rm -f /tmp/bukkit
        echo "Completed."
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
        echo "Completed."
        exit 0
    fi
    done
elif [ "${opt}" = "Vanilla" ]; then
    DOWNLOAD=`lynx -dump -nonumbers http://www.minecraft.net/download | grep MinecraftDownload | grep .jar | grep server`
    JAR=`echo ${DOWNLOAD} | cut -f6 -d'/' | cut -f1 -d'?'`
    cd ${MC_DIR}
    jar_check
    wget_download
    rename_dialog
    script_gen
    echo "Completed."
    exit 0
fi
done