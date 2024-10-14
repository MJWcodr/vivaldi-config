#!/usr/bin/env bash
restic -r rclone:backup:restic_backup backup \
	--one-file-system \
	--exclude-file ~/.config/restic/exclude.list \
	/home/

restic -r rclone:backup:restic_backup backup \
	--one-file-system \
	--exclude-file ~/.config/restic/exclude.list \
	/etc/
