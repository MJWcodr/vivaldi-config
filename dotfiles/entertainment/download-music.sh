#!/usr/bin/env bash

MUSIC_LIST="/home/matthias/.config/entertainment/music.list"

TMPFILE=$(mktemp)

# Remove Lines starting with "#", lead by whitespace and empty lines

grep -v '^[[:space:]]*#' $MUSIC_LIST | sed -E '/^[[:space:]]*$/d; s/^[[:space:]]+//' >> $TMPFILE

echo "Downloading Music from:"
echo $URLS

# Download Music
qdl dl -q 7 $TMPFILE --embed-art
