#! /usr/bin/env nix-shell
#! nix-shell -i bash -p exiftool yt-dlp
# shellcheck shell=bash

# This script downloads youtube videos and manages them
# It is meant to be run as a cron job

###
# Variables
###

NUM_VIDEOS="5"
DOWNLOAD_DIR="/srv/entertainment/youtube"
YOUTUBE_CHANNEL_FILE="/etc/nixos/services/youtube-downloader/youtube.list"

TMPFILE="$(mktemp)"

# Remove Lines starting with "#", lead by whitespace and empty lines
clean_list() {
		# Remove lines starting with #
		# Remove empty lines
		# Remove leading whitespace
		# Remove trailing whitespace
		# $1: file to clean
		sed -E '/^[[:space:]]*#/d; /^[[:space:]]*$/d; s/^[[:space:]]+//; s/[[:space:]]+$//' "$1"

}

clean_list "$YOUTUBE_CHANNEL_FILE" >> "$TMPFILE"


echo "Downloading Youtube videos from:"
URLS=$(cat "$TMPFILE")

# Download youtube videos
for url in $URLS; do
		echo "Downloading $url"
		yt-dlp -i \
			--playlist-end $NUM_VIDEOS \
			--download-archive "$DOWNLOAD_DIR/.archive.txt" \
			--write-thumbnail \
			--embed-metadata \
			--embed-chapters \
			--embed-subs \
			--write-auto-subs \
			--match-filter "duration < 7000" \
			--match-filter "duration > 120" \
			--match-filter "uploader !~ /.*[Ss]tream.*/" \
			--match-filter "original_url!*=/shorts/ & url!*=/shorts/" \
			-o "$DOWNLOAD_DIR/%(uploader)s/%(title)s.%(ext)s" \
			"$url"
done

# Remove older videos
for url in $URLS; do
	yt-dlp --get-filename \
		--playlist-end "$( $NUM_VIDEOS + 5)" \
		-o "$DOWNLOAD_DIR/%(uploader)s/%(title)s.%(ext)s" \
		"$url" | tail -n 5 | xargs rm -f
done
