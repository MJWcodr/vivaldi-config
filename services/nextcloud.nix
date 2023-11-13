{ config, lib, pkgs, ... }:

{
  environment.etc."nextcloud-pass".text = "password";
  services.nextcloud = {
    home = "/srv/nextcloud";
    enable = true;
    hostName = "vivaldi.fritz.box";
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/etc/nextcloud-pass";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

