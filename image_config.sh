#!/bin/bash
# Note: Must be run with privileges.
# Run this script on a Raspbian image [first argument]
# before writing to the SD card to do the following:
# 1. Change the hostname from raspberrypi to the
#    name you supply [second argument]
# 2. Set domain to "local"
# 3. Enable ssh by default, and create authorized_keys
#    from the file named ssh_key.pub
# 4. Write WiFi configuration into wpa_supplicant.conf
#    from the file named wifi.txt, which you must format:
#
# network={
#     ssid="your_wifi_network"
#     psk="your_wifi_password"
#     scan_ssid=1
# }

if [[ ! -f $1 ]]; then
	echo "Invalid image specified: $1"
	echo "Usage: $0 <raspbian.img> <short_hostname>"
	echo "e.g. $0 raspbian.img blueberry"
	echo
	echo "Failed."
elif [[ -z $2 ]]; then
	echo "You must supply a hostname."
	echo "Usage: $0 <raspbian.img> <short_hostname>"
	echo "e.g. $0 raspbian.img blueberry"
	echo
	echo "Failed."
elif [[ ! -f ssh.pub ]]; then
	echo "Please copy a public key into ssh.pub"
	echo
	echo "Failed."
else
	bootoff=$((8192*512))
	rootoff=$(($(fdisk -l $1 |awk '$7=="Linux"{print $2}')*512))

	mkdir tmpmnt
	mount -o loop,offset=${rootoff} $1 tmpmnt

	echo "$2.local" > tmpmnt/etc/hostname
	sed -i "s/raspberrypi/$2 $2.local/g" tmpmnt/etc/hosts
	echo "Updated hostname"

	if [[ -f wifi.txt ]]
	then
		sed -i "s/GB/US/" tmpmnt/etc/wpa_supplicant/wpa_supplicant.conf
		cat wifi.txt >> tmpmnt/etc/wpa_supplicant/wpa_supplicant.conf
		echo "Configured WiFi"
	fi

	mkdir tmpmnt/home/pi/.ssh
	cp ssh.pub tmpmnt/home/pi/.ssh/authorized_keys

	sync
	umount tmpmnt

	mount -o loop,offset=${bootoff} $1 tmpmnt
	touch tmpmnt/ssh
	echo "Configured SSH"

	sync
	umount tmpmnt

	rm -rf tmpmnt
	echo "Done. Once powered on, your RPi should"
	echo "be accessible over SSH at $2.local"
	echo "To inspect my work, please"
	echo "mount -o loop,offset=${rootoff} $1 /mnt"
fi
