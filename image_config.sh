#!/bin/bash
#       .                               .      .;
#     .'                              .'      .;'
#    ;-.    .;.::..-.    . ,';.,';.  ;-.     .;  .-.
#   ;   ;   .;   ;   :   ;;  ;;  ;; ;   ;   :: .;.-'
# .'`::'`-.;'    `:::'-'';  ;;  ';.'`::'`-_;;_.-`:::'
#                      _;        `-'

# https://github.com/tkphd/bramble-config

# Run this script with privileges on a Raspbian
# image [first argument] before writing to the
# SD card to do the following:
# 1. Change the hostname from raspberrypi to the
#    name you supply [second argument]
# 2. Set domain to "local"
# 3. Enable ssh by default, and create authorized_keys
#    from the file named ssh_key.pub
# 4. Set static IP for eth0 based on hostname
# 5. Write WiFi configuration into wpa_supplicant.conf
#    from the file named wifi.txt, which you must format:
#network={
#    ssid="your_wifi_network"
#    psk="your_wifi_password"
#    scan_ssid=1
#}

if [[ ! -f $1 ]]; then
	echo "Invalid image specified: $1"
	echo "Usage: $0 <raspbian.img> <short_hostname>"
	echo "e.g. $0 raspbian.img blueberry"
	echo "Cluster: $0 <raspbian.img> <rack> <node>"
	echo "e.g. $0 raspbian.img 1 0 "
	echo
	echo "Failed."
elif [[ -z $2 ]]; then
	echo "You must supply a hostname."
	echo "Usage: $0 <raspbian.img> <short_hostname>"
	echo "e.g. $0 raspbian.img blueberry"
	echo "Cluster: $0 <raspbian.img> <rack> <node>"
	echo "e.g. $0 raspbian.img 1 0 "
	echo
	echo "Failed."
elif [[ ! -a ssh.pub ]]; then
	echo "Please copy a public key into ssh.pub"
	echo
	echo "Failed."
else
    echo "Customizing raspbian image:"
	rack=0
	host=1
	name="${2}"
	if [[ "${2}" == "data" ]]; then
		rack=0
		host=2
		name="data"
	elif [[ $# -gt 2 ]]; then
	name="r${2}n${3}"
	rack="${2}"
        host="${3}"
    fi
	dest=raspbian_${name}.img
	cp $1 $dest

	bootoff=$((8192*512))
	rootoff=$(($(fdisk -l $dest | awk '$7=="Linux"{print $2}')*512))

	mkdir tmpmnt
	mount -o loop,offset=${rootoff} $dest tmpmnt

	echo "${name}.local" > tmpmnt/etc/hostname
	sed -i "s/raspberrypi/${name} ${name}.local/g" tmpmnt/etc/hosts
	echo "configured hostname..."

	echo -e "interface eth0\nstatic ip_address=192.168.3.1${rack}${host}\n" >> tmpmnt/etc/dhcpcd.conf
    echo -e "auto eth0\niface eth0 inet manual\n" >> tmpmnt/etc/network/interfaces
    echo "configured static ethernet..."

	if [[ -f wifi.txt ]]
	then
		sed -i "s/GB/US/" tmpmnt/etc/wpa_supplicant/wpa_supplicant.conf
		cat wifi.txt >> tmpmnt/etc/wpa_supplicant/wpa_supplicant.conf
		echo "configured wifi..."
	fi

	mkdir -p tmpmnt/home/pi/.ssh
	cp ssh.pub tmpmnt/home/pi/.ssh/authorized_keys

	sync
	umount tmpmnt

	mount -o loop,offset=${bootoff} $dest tmpmnt
	touch tmpmnt/ssh
	echo "configured ssh..."

	sync
	umount tmpmnt
	rm -rf tmpmnt

	echo "done. Once powered on, your RPi3 should be accessible over"
    echo "SSH at ${name}.local with mDNS running on one local host."
	echo "To write an SD card, please run  dmesg | tail or fdisk -l, then"
    echo "# dd bs=4M conv=fsync status=progress if=raspbian_${name}.img of=/dev/sdX"
fi
