#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash yt-dlp exiftool --pure

# This script downloads the n latest videos from a youtube channel given in youtube.list

NUM_VIDEOS=5

TMPFILE=$(mktemp)

YOUTUBE_CHANNEL_LIST="youtube.list"
NEBULA_CHANNEL_LIST="nebula.list"
OUTDIR="videos"

# Remove Lines starting with "#", lead by whitespace and empty lines

clean_list() {
		# Remove lines starting with #
		# Remove empty lines
		# Remove leading whitespace
		# Remove trailing whitespace
		# $1: file to clean
		sed -E '/^[[:space:]]*#/d; /^[[:space:]]*$/d; s/^[[:space:]]+//; s/[[:space:]]+$//' $1
}

clean_list $YOUTUBE_CHANNEL_LIST >> $TMPFILE
# clean_list $NEBULA_CHANNEL_LIST >> $TMPFILE

echo "Downloading Youtube videos from:"
URLS=$(cat $TMPFILE)

# Download youtube videos
for url in $URLS; do
		echo "Downloading $url"
		yt-dlp -i --playlist-end 5 --add-metadata --compat-options embed-metadata -o "$OUTDIR/%(uploader)s/%(title)s.%(ext)s" "$url"
done
