#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl wirelesstools

# Put this script in "/etc/network/if-up.d/" and make it executable (chmod +x)

[ -z "$(iwconfig 2>/dev/null| grep 'WIFIonICE')" ] && exit
URL=http://www.wifionice.de/de/
CSRF_TOKEN=$(curl http://www.wifionice.de/de/|grep -oE 'value="[0-9a-f]{32}"' | cut -d = -f2|sed 's/"//g')
POST_DATA="
login=true&CSRFToken=${CSRF_TOKEN}&connect="
curl -v -d "$(echo $POST_DATA |sed 's/ /%20/g')" -v -A "Mozilla/9000.0 (X11; Linux x86_64; rv:65.0) Gecko/20000000 Firefox/1337" -H "Cookie: csrf=${CSRF_TOKEN}" -d "${POST_DATA}" $URL
