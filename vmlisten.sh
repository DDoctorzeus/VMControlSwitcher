#!/bin/bash

#NOTE: REQUIRES NETCAT!

if [ $# -lt 4 ]; then
	echo "USAGE: ./command.sh hostname listenport vmtodetachname pathtoxmldirectory";
	exit 1;
fi

#Get Basic Info
declare LISTENIP="$1";
declare LISTENPORT="$2";
declare VMNAME="$3";
declare DIRECTORYPATH="$4";
declare -a DEVICEXMLS;
declare EXIT=0;

#Check directory exists
if [ ! -d "$DIRECTORYPATH" ]; then
	echo "ERROR: Specified directory does not exist!";
	exit 1;
fi

#Now get device xmls
for f in $(ls $DIRECTORYPATH/*.xml) ; do
	echo "Adding Device Specified At $f";
	DEVICEXMLS+=("$f");
done

echo "Listening For Commands On $LISTENIP:$LISTENPORT";
while [ $EXIT -eq 0 ]; do
	RECEIVED="$(netcat -l -p $LISTENPORT)";
	
	#If Told To Mount Device
	if [[ $RECEIVED = "ATTACH" ]]; then
		for device in "${DEVICEXMLS[@]}"; do
			echo "Attatching Device At: $device";
			virsh attach-device $VMNAME $device;
		done
	elif [[ $RECEIVED = "DETACH" ]]; then
		for device in "${DEVICEXMLS[@]}"; do
			echo "Detaching Device At: $device";
			virsh detach-device $VMNAME $device;
		done
	elif [[ $RECEIVED = "EXIT" ]]; then
		echo "Exit Signal Recieved";
		EXIT = 1;
	else
		echo "Got \"$RECEIVED\" - Ignoring"
	fi
done

return 0;