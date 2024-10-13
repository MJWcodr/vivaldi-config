#!/usr/bin/env bash

gpgconf --kill all
gpg --import ~/.gnupg/backup_2020-08-18.sec

# Create a Temp Directory if none is provided
if [ "$1" ]; then
	TMPDIR="$1"
else
	TMPDIR="$(mktemp -d)"

	# Delete Temp Directory on Exit
	trap 'rm -rf "$TMPDIR"' EXIT
fi


restic mount -r rclone:backup:restic_backup "$TMPDIR"
