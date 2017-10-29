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
	offset=$(($(fdisk -l $1 |awk '$7=="Linux"{print $2}')*512))

	mkdir tmpmnt
	mount -o loop,offset=${offset} $1 tmpmnt

	echo "$2.local" > tmpmnt/etc/hostname
	sed -i "s/raspberrypi/$2 $2.local/g" tmpmnt/etc/hosts
	echo "Updated hostname"

	mkdir tmpmnt/home/pi/.ssh
	cp ssh.pub tmpmnt/home/pi/.ssh/authorized_keys
	touch tmpmnt/boot/ssh
	echo "Configured SSH"

	if [[ -f wifi.txt ]]
	then
		sed -i "s/GB/US/" tmpmnt/etc/wpa_supplicant/wpa_supplicant.conf
		cat wifi.txt >> tmpmnt/etc/wpa_supplicant/wpa_supplicant.conf
		echo "Configured WiFi"
		# For outdated Raspbian images only:
		# echo -e "auto wlan0\nallow-hotplug wlan0\niface wlan0 inet manual\nwpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" >> tmpmnt/etc/network/interfaces
	fi

	sync
	umount tmpmnt
	rm -rf tmpmnt
	echo "Done. To inspect my work, please"
	echo "mount -o loop,offset=${offset} $1 /mnt"
	echo
	echo "With avahi or Bonjour installed on this host, your"
	echo "booted RPi should be accessible by SSH at $2.local"
fi
