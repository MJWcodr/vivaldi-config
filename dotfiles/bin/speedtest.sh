#!/usr/bin/env nix-shell
#!nix-shell -i bash -p speedtest-cli

# Check internet speed and write it as a CSV line to a file

TIME=$(date +%s)
speedtest-cli --simple | awk -v time="$TIME" '{print time "," $0}' >> speedtest.CSV
