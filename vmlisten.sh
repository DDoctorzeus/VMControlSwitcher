#!/bin/bash

#NOTE: REQUIRES NETCAT!

#Set These
LISTENIP="10.0.0.1";
LISTENPORT=25693;
VMNAME="win10";
DEVICEXMLS=('keyboard.xml' 'mouse.xml');

#Dont Touch These
EXIT=0;
DEVICESATTATCHED=0;

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
