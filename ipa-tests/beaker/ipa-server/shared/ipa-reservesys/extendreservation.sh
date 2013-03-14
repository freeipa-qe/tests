#!/bin/bash
# extendreservation.sh
# This script extends the reservation time for the /CoreOS/ipa-server/IpaReserveSys test
extendfile=/tmp/ipa-reservation-extend-seconds.dat
echo $1 | grep '\-h' &> /dev/null
if [ $? -eq 0 ] || [ -z "$1" ]; then
	echo "extendreservation.sh script."
	echo " Call this script with extendreservation.sh <seconds to extend>"
	echo " example: extendreservation.sh 2000"
	echo " This example will extend the reservation on this machine for 2000 seconds."
	exit 0
fi 

if [ $1 -gt 0 ] && [ $1 -lt 1209600 ]; then
	if [ -f $extendfile ]; then
		echo "ERROR - It appears that a extendreservation call has already been made"
		echo "   Please wait 5 min for the extend call to complete, or delete $extendfile"
		exit 1
	else
		echo "$1" > $extendfile
		echo "Reservation extended $1 seconds. You will recieve a email with the updated reservation end time."
	fi
	exit 0
else
	echo "ERROR - the input was \"$1\", please enter a number between 1 and 1209600"
	exit 1
fi
