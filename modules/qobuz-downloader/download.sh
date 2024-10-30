#!/usr/bin/env bash

# if command line argument is given, use it as config file
if [ -n "$1" ]; then
		QOBUZ_CONFIG_FILE=$1
fi

trap 'rm -f $TMPFILE' EXIT

MUSIC_LIST="/home/matthias/.config/entertainment/music.list"

TMPFILE=$(mktemp)

# Remove Lines starting with "#", lead by whitespace and empty lines

grep -v '^[[:space:]]*#' $MUSIC_LIST | sed -E '/^[[:space:]]*$/d; s/^[[:space:]]+//' >> "$TMPFILE"

echo "Downloading Music from:"
echo "$URLS"

# Download Music
export QOBUZ_CONFIG_FILE
qdl dl -q 7 "$TMPFILE" --embed-art
