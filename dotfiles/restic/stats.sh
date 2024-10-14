#!/usr/bin/env nix-shell
#!nix-shell -i bash -p restic --pure

restic -r rclone:backup:restic_backup stats
