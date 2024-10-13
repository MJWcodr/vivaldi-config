{ config, pkgs, ... }:

let
  internalPort = 5001;
  externalPort = 5000;
  domain = "vivaldi.fritz.box";

  giteaPort = 3001;
in
{

  #############
  # Secrets
  #############

  age.secrets = {
    music-downloader-env = {
      file = ../../../secrets/music-downloader-env.age;
    };
  };

  #############
  # Build Container
  #############

  systemd.services."build-music-downloader" = {
    description = "Build music downloader";
    path = [ pkgs.git pkgs.podman ];
    script =
      "\n		TEMP=$(mktemp -d)\n		cd $TEMP	\n		trap \"rm -rf $TEMP\" EXIT\n		git clone https://${domain}:${
          toString giteaPort
        }/mjwcodr/browser-music-downloader.git music-downloader	\n		cd music-downloader\n		ls .\n		podman build -t localhost/music-downloader .\n		";

    serviceConfig = { Type = "oneshot"; };
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-music-downloader.service" ];
  };

  #############
  # Music Downloader
  #############
  virtualisation.oci-containers.containers = {
    "music-downloader" = {
      image = "localhost/music-downloader";
      ports = [ "${toString internalPort}:8080" ];
      volumes = [
        "${config.age.secrets.music-downloader-env.path}:/app/.env"
        "/srv/music/:/app/Music"
        "/etc/nixos/services/music/songs.json:/app/songs.json"
      ];
    };
  };

  #############
  # Nginx
  #############

  services.nginx.virtualHosts."music-downloader" = {
    locations."/" = {
      proxyPass = "http://localhost:${toString internalPort}";
      proxyWebsockets = true;
    };

    listen = [{
      addr = domain;
      port = externalPort;
      ssl = false;
    }];
  };

  networking.firewall.allowedTCPPorts = [ externalPort ];

}
