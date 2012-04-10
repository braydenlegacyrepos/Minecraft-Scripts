#!/bin/bash
#This is going to be one hell of a ghetto solution until the author does something!
TITLE="Linux Tycoon Scenario rev 1"
function check_form {
if [ ! "${FORM[$1]}" ]; then
    if [ "$2" = "break" ]; then
        break
    else
        exit 0
    fi
fi
}
FORM[1]=`zenity --cancel-label="Exit" --entry --title="${TITLE}" --text="Enter the name of the scenario"`
check_form 1
FORM[2]=`zenity --confirm-overwrite --file-selection --title="${TITLE}" --save --filename="${FORM[1]}.ltx"`
check_form 2
touch ${FORM[2]}
echo "<root Name=\"${FORM[1]}\">" >> ${FORM[2]}
echo -e "\n<packages>" >> ${FORM[2]}
while true; do
    FORM[3]=`zenity --forms --cancel-label="Finished with packages" --title="${TITLE}" --text="Enter package details" \
    --add-entry="Name" \
    --add-entry="Description" \
    --add-entry="NerdCred" \
    --add-entry="Popularity" \
    --add-entry="Version" \
    --add-entry="Bugs" \
    --add-entry="Package Size(MB)"`
    check_form 3 break
    echo "${FORM[3]}"
    PKG_NAME=`echo ${FORM[3]} | cut -f1 -d "|" | tr -d ' '`
    echo "${PKG_NAME}"
    PKG_DESCRIPTION=`echo ${FORM[3]} | cut -f2 -d"|" | cut -f1 -d"|"`
    echo "${PKG_DESCRIPTION}"
    PKG_NERDCRED=`echo ${FORM[3]} | cut -f3 -d"|" | cut -f1 -d"|"`
    echo "${PKG_NERDCRED}"
    PKG_POPULARITY=`echo ${FORM[3]} | cut -f4 -d"|" | cut -f1 -d"|"`
    echo "${PKG_POPULARITY}"
    PKG_VERSION=`echo ${FORM[3]} | cut -f5 -d"|" | cut -f1 -d"|" | tr -d '.'`
    echo "${PKG_VERSION}"
    PKG_BUGS=`echo ${FORM[3]} | cut -f6 -d"|" | cut -f1 -d"|"`
    echo "${PKG_BUGS}"
    PKG_SIZE=`echo ${FORM[3]} | cut -f7 -d"|" | cut -f1 -d"|"`
    echo "${PKG_SIZE}"
    FORM[4]=`zenity --cancel-label="Do not press this" --title="${TITLE}" --list --text="Choose the software category" \
    --radiolist \
    --column="" \
    --column="" \
    --column="Category" \
    1 1 "Web Browser" 2 2 "Office Suite" 3 3 "Desktop Environment" 4 4 "Game" 5 5 "Graphics Edition" 6 6 "Programming" 7 7 "Communication" 8 8 "Utilities" 9 9 "Multimedia"`
    FORM[5]=`zenity --question --title="${TITLE}" --text="Open source?"; echo $?`
    if [ ${FORM[5]} = 0 ]; then
         FORM[5]=True
    elif [ ${FORM[5]} = 1 ]; then
         FORM[5]=False
    fi
    echo "<package Name=\"${PKG_NAME}\" Bugs=\"${PKG_BUGS}\" Description=\"${PKG_DESCRIPTION}\" isOpenSource=\"${FORM[5]}\" NerdCred=\"${PKG_NERDCRED}\" Popularity=\"${PKG_POPULARITY}\" SizeInMB=\"${PKG_SIZE}\" TypeOfSoftware=\"${FORM[4]}\" Version=\"${PKG_VERSION}\"/>" >> ${FORM[2]}
done
echo -e "</packages>\n\n<distros>" >> ${FORM[2]}
while true; do
    FORM[6]=`zenity --forms --cancel-label="Finished with distros" --title="${TITLE}" --text="Enter distro details" \
    --add-entry="Name" \
    --add-entry="Users" \
    --add-entry="Version"`
    check_form 6 break
    echo ${FORM[6]}
    DISTRO_NAME=`echo ${FORM[6]} | cut -f1 -d'|'`
    echo "${DISTRO_NAME}"
    DISTRO_VERSION=`echo ${FORM[6]} | cut -f3 -d'|' | cut -f2 -d'|'`
    echo "${DISTRO_VERSION}"
    DISTRO_USERS=`echo ${FORM[6]} | cut -f2 -d'|' | cut -f1 -d'|'`
    echo "${DISTRO_USERS}"
    grep "<package Name=" ${FORM[2]} | cut -f2 -d'"' > /tmp/scenario.tmp
    while read p; do
        echo ${p} >> /tmp/scenario-pkgs.tmp
        echo ${p} >> /tmp/scenario-pkgs.tmp
    done < /tmp/scenario.tmp
    perl -ne 'chomp; print "$_ ";' -i /tmp/scenario-pkgs.tmp
    PKG_LIST=`cat /tmp/scenario-pkgs.tmp`
    rm /tmp/scenario-pkgs.tmp
    rm /tmp/scenario.tmp
    FORM[7]=`zenity --list --cancel-label="Do not press this" --checklist --separator=";" --text="Select packages" --column="" --column="Package" \
    ${PKG_LIST}`
    echo "<distro Name=\"${DISTRO_NAME}\" Users=\"${DISTRO_USERS}\" Version=\"${PKG_VERSION}\" Packages=\"${FORM[7]}\"/>" >> ${FORM[2]}
done
echo -e "</distros>\n\n</root>" >> ${FORM[2]}