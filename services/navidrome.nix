{ ... }:

{
  services.navidrome.enable = true;
  services.navidrome.settings = {
    Address = "vivaldi.fritz.box";
    Port = 4533;
    MusicFolder = "/srv/music";
  };

	system.activationScripts.navidrome = ''
	#!/bin/sh

	# Create Navidrome Music Folder
	mkdir -p /srv/music

	# chown Navidrome Music Folder
	chown -R navidrome:navidrome /srv/music

	'';

  # Open Port 4533 for Navidrome
  networking.firewall.allowedTCPPorts = [ 4533 ];
}

