#!/usr/bin/env bash

# This script is used to restore a backup in the background

# Dependencies
# - rsync
# - notify-send (optional)

# create the mount location if it doesn't exist
MOUNT_LOCATION=$(mktemp -d)

# mount the backup location and store the PID to kill it later
~/.config/restic/mount.sh $MOUNT_LOCATION &
MOUNT_PID=$!
trap "kill $MOUNT_PID" EXIT

# sleep until the mount is not empty
while [ ! "$(ls -A $MOUNT_LOCATION)" ]; do
	sleep 1
done

# construct the base file path
FILE_PATH="$MOUNT_LOCATION"/hosts/$(hostname)/latest
FILE_LIST=$(cat ~/.config/restic/restore.list)

# rsync the backup to the system
for file in $FILE_LIST; do
	echo "Restoring $file"
	rsync -a "$FILE_PATH""$file"/ $file # exchange -n with -a to actually restore the files
done

notify-send "Restore complete"
