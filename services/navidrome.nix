{ ... }:

{
  services.navidrome.enable = true;
  services.navidrome.settings = {
    Address = "vivaldi.fritz.box";
    Port = 4533;
    MusicFolder = "/srv/music";
  };

  # Open Port 4533 for Navidrome
  networking.firewall.allowedTCPPorts = [ 4533 ];
}

