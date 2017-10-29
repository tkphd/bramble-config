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
#     psk=your_wifi_password
# }

if [[ ! -f $1 ]]; then
	echo "Invalid image specified: $1"
	echo "Usage: $0 <raspbian.img> <short_hostname>"
	echo "e.g. $0 raspbian.img blueberrypi pi_pub.rsa"
	echo
	echo "Failed."
elif [[ -z $2 ]]; then
	echo "You must supply a hostname."
	echo "Usage: $0 <raspbian.img> <short_hostname>"
	echo "e.g. $0 raspbian.img blueberrypi pi_pub.rsa"
	echo
	echo "Failed."
elif [[ ! -f ssh.pub ]]; then
	echo "Please copy a public key into ssh.pub"
	echo
	echo "Failed."
else
	newname=$2
	offset=$(($(fdisk -l $1 |awk '$7=="Linux"{print $2}')*512))

	mkdir tmpmnt
	mount -o loop,offset=${offset} $1 tmpmnt

	# Step 1
	echo "${newname}.local" > tmpmnt/etc/hostname
	echo "Contents of ${1}/etc/hostname:"
	cat tmpmnt/etc/hostname
	echo

	# Step 2
	sed -i "s/raspberrypi/${newname} ${newname}.local/g" tmpmnt/etc/hosts
	echo "Contents of ${1}/etc/hosts:"
	cat tmpmnt/etc/hosts
	echo

	# Step 3
	mkdir tmpmnt/home/pi/.ssh
	cp ssh.pub tmpmnt/home/pi/.ssh/authorized_keys
	touch tmpmnt/boot/ssh
	echo "Configured SSH"

	# Step 4
	if [[ -f wifi.txt ]]
	then
		cat wifi.txt >> tmpmnt/etc/wpa_supplicant/wpa_supplicant.conf
		echo "Configured WiFi"
	fi

	sync
	umount tmpmnt
	rm -rf tmpmnt
	echo "Done. With avahi or Bonjour installed on this host,"
	echo "the RPi should be accessible by SSH at $2.local"
fi
