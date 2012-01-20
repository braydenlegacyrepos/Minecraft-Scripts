#!/bin/bash
VERSION="Alpha 0.01"
echo "-------------------------------------"
echo "-------- OpenVZ CLI Frontend --------"
echo "-------------------------------------"
echo "Version: $VERSION"
echo "1) Configuration - modify configuration variables."
echo "2) Stats - view statistics."
echo "3) Maintenance - perform maintenance on the VPS."
printf ": "
read MENU_ANSWER
if [ "${MENU_ANSWER}" = "Configuration" ] || [ "${MENU_ANSWER}" = "configuration" ] || [ "${MENU_ANSWER}" = "1" ]; then
	echo "-- VPS Configuration --"
	echo "-- Current VPS CTIDs --"
	vzlist -a
	echo "1) Hostname: Change a VPS's hostname."
	echo "2) IP_ADD: Add another IP address to a VPS."
	echo "3) IP_DEL: Remove an IP from a VPS."
	echo "4) Password: Change the password of a VPS."
	echo "5) Nameserver: Add a nameserver to the VPS."
	printf ": "
	read CONFIG_ANSWER
	if [ "${CONFIG_ANSWER}" = "Hostname" ] || [ "${CONFIG_ANSWER}" = "hostname" ] || [ "${CONFIG_ANSWER}" = "1" ]; then
	    echo "-- Please enter the CTID for the VPS which you want to perform this modification on. --"
	    printf "CTID: "
	    read CTID
	    echo "-- Please enter the new hostname for the VPS --"
	    CURRENT_HOST=`vzlist -a -o ctid,hostname | grep $CTID | awk '{printf $2}'`
	    echo "Current hostname: ${CURRENT_HOST}"
	    printf "Hostname: "
	    read NEW_HOST
	    vzctl set $CTID -hostname $NEW_HOST -save
	    echo "Attempted to set ${CTID}'s hostname to ${NEW_HOST}."
	    exit 0
	elif [ "${CONFIG_ANSWER}" = "IP_ADD" ] || [ "${CONFIG_ANSWER}" = "ip_add" ] || [ "${CONFIG_ANSWER}" = "ipadd" ] || [ "${CONFIG_ANSWER}" = "2" ]; then
	    echo "-- Please enter the CTID for the VPS which you want to perform this modification on. --"
	    printf "CTID: "
	    read CTID
	    echo "-- IPs currently in use. --"
	    vzlist -a -o ip
	    echo "-- Please enter the IP to add to the VPS --"
	    read NEW_IP
	    vzctl set $CTID -ipadd $NEW_IP -save
	    echo "-- Attempted to add $NEW_IP to ${CTID}. --"
	    exit 0
	elif [ "${CONFIG_ANSWER}" = "IP_DEL" ] || [ "${CONFIG_ANSWER}" = "ip_del" ] || [ "${CONFIG_ANSWER}" = "ipdel" ] || [ "${CONFIG_ANSWER}" = "3" ]; then
	    echo "-- Please enter the CTID for the VPS you want to perform this modification on. --"
	    printf "CTID: "
	    read CTID
	    echo "-- IPs in use by CTID --"
	    vzlist -a -o ctid,ip
	    echo "-- Please enter the IP to remove from the VPS. --"
	    read DEL_IP
	    vzctl set $CTID -ipdel $DEL_IP -save
	    echo "-- Attempted to remove $DEL_IP from ${CTID}. --"
	    exit 0
	elif [ "${CONFIG_ANSWER}" = "Password" ] || [ "${CONFIG_ANSWER}" = "password" ] || [ "${CONFIG_ANSWER}" = "4" ]; then
	    echo "-- Please enter the CTID for the VPS you want to perform this modification on. --"
	    printf "CTID: "
	    read CTID
	    echo "-- Please enter the username to change the password for (default: root). --"
	    read USERNAME
	    echo "-- Please enter the new password. --"
	    read PASSWORD
	    if [ "${USERNAME}" == "" ]; then
	        USERNAME=root
	    fi
	    vzctl set $CTID -userpasswd ${USERNAME}:${PASSWORD} -save
	    echo "-- Attempted to change ${USERNAME}'s password to ${PASSWORD}. --"
	    exit 0
	elif [ "${CONFIG_ANSWER}" = "Nameserver" ] || [ "${CONFIG_ANSWER}" = "nameserver" ] || [ "${CONFIG_ANSWER}" = "5" ]; then
	    echo "-- Please enter the CTID for the VPS you want to perform this modification on. --"
	    printf "CTID: "
	    read CTID
	    echo "-- Please enter the nameserver IP address to add to this VPS. --"
	    printf "IP: "
	    read NS_IP
	    vzctl set $CTID -nameserver $NS_IP -save
	    exit 0
	else
	    echo "-- You did not enter a valid option. You must type the word in properly as-is or its corresponding number. --"
	    exit 1
	fi
elif [ "${MENU_ANSWER}" = "Stats" ] || [ "${MENU_ANSWER}" = "stats" ] || [ "${MENU_ANSWER}" = "2" ]; then
    echo "-- Current stats of all VPSes on this node. --"
    vzlist -a -o ctid,hostname,name,description,ostemplate,ip,status
    exit 0
elif [ "${MENU_ANSWER}" = "Maintenance" ] || [ "${MENU_ANSWER}" = "maintenance" ] || [ "${MENU_ANSWER}" = "3" ]; then
    echo "-- Maintenance --"
    echo "1) Start: Start a VPS if it is not running."
    echo "2) Stop: Stop a VPS if it is running."
    echo "3) Status: View the status of a VPS."
    echo "4) FastStop: Stop a VPS in a quick and forceful manner."
    echo "5) Enter: Enter the shell of a VPS."
    printf ": "
    read MAINT_ANSWER
    if [ "${MAINT_ANSWER}" = "1" ] || [ "${MAINT_ANSWER}" = "Start" ] || [ "${MAINT_ANSWER}" = "start" ]; then
        echo "-- Current containers not running. --"
        vzlist -S
        echo "-- Please enter the CTID of the container you wish to start. --"
        printf "CTID: "
        read CTID
        vzctl start $CTID
        echo "-- Attempted to start ${CTID}. --"
        exit 0
    elif [ "${MAINT_ANSWER}" = "2" ] || [ "${MAINT_ANSWER}" = "Stop" ] || [ "${MAINT_ANSWER}" = "stop" ]; then
        echo "-- Running containers. --"
        vzlist
        echo "-- Please enter the CTID of the container you wish to stop. --"
        printf "CTID: "
        read CTID
        vzctl stop $CTID
        echo "-- Attempted to stop container, ${CTID}. --"
        exit 0
    elif [ "${MAINT_ANSWER}" = "3" ] || [ "${MAINT_ANSWER}" = "Status" ] || [ "${MAINT_ANSWER}" = "status" ]; then
        echo "-- All containers on the node. --"
        vzlist -a
        echo "-- Please enter the CTID of the container you wish to check. --"
        printf "CTID: "
        read CTID
        vzctl status $CTID
        exit 0
    elif [ "${MAINT_ANSWER}" = "4" ] || [ "${MAINT_ANSWER}" = "FastStop" ] || [ "${MAINT_ANSWER}" = "faststop" ]; then
        echo "-- All running containers --"
        vzlist
        echo "-- Please enter the CTID of the container you wish to forcefully shutdown. --"
        printf "CTID: "
        read CTID
        vzctl stop $CTID -fast
        exit 0
    elif [ "${MAINT_ANSWER}" = "5" ] || [ "${MAINT_ANSWER}" = "Enter" ] || [ "${MAINT_ANSWER}" = "enter" ]; then
        echo "-- All running containers --"
        vzlist
        echo "-- Please enter the CTID of the container you wish to enter. Once inside, type 'exit' to leave it. --"
        printf "CTID: "
        vzctl enter $CTID
        exit 0
    else
        echo "Did not understand your request. Please enter the name of the option or the corresponding number."
        exit 1
    fi
else
    echo "Please select an option next time."
    exit 1
fi