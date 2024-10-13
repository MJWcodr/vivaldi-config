#!/usr/bin/env bash

# Currently Nix is only installed for current user and without root
# #!/bin/env nix-shell
# #!nix-shell -i bash -p coreutils iproute2

# This script temporarily changes the MAC address of a network interface

INTERFACE=$1

if [ -z "$INTERFACE" ]; then
		echo "Usage: $0 <interface>"
		exit 1
fi

# Check if User has Sudo Priviledges
if [ "$USER" != "root" ]; then
	echo "This command must be run as root"
	exit 1
fi

# Generate a random MAC address
NEWMAC=$(printf '00:60:2f:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))

# Change the MAC address
echo "Current MAC address for $INTERFACE is $(cat /sys/class/net/"$INTERFACE"/address)"

ip link set dev "$INTERFACE" down
ip link set dev "$INTERFACE" address "$NEWMAC"
ip link set dev "$INTERFACE" up

echo "New MAC address for $INTERFACE is $NEWMAC"


# Also change the hostname to a random word
RANDOMWORD=$(shuf -n1 /usr/share/dict/words)

echo "Current hostname is $(hostname)"
sudo hostname $RANDOMWORD && echo "New hostname is $RANDOMWORD"
