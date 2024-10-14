#!/usr/bin/env bash

# Keep the last 5 backups
# Keep 4 weekly backups
# Keep 6 monthly backups
# Keep 2 yearly backups
restic -r rclone:backup:restic_backup forget --keep-last 5 --keep-weekly 4 --keep-monthly 6 --keep-yearly 2
