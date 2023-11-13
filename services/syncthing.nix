{ lib, pkgs, ... }: {
  services.syncthing = {
    enable = true;
    dataDir = "/home/matthias";
    openDefaultPorts = true;
    configDir = "/home/matthias/.config/syncthing";
    user = "matthias";
    group = "users";
    guiAddress = "vivaldi.fritz.box:8384";
    settings = {
      folders = {
        "Music" = {
          id = "silgm-drnzi";
          path = "/srv/music";
          ignorePerms = true;
          devices = [ "mjw-laptop" "pixel6a" ];
        };
      };
			devices = {
      "mjw-laptop" = {
        id = "7DWYRCE-GZ4C5JX-CMMYE73-2ARC4QI-5Z5HRRH-CBXW6VO-D6RUSQK-X7YPLQV";
      };
      "pixel6a" = {
        id = "EA3NWML-6OQ2XLO-QN7NFMW-OENHZPH-7XCK7AJ-HLV7IRQ-ZVG4ASW-MPMO2AA";
        introducer = true;
      };
    };

    };
      };
  networking.firewall.allowedTCPPorts = [ 22000 21027 8384 ];
}
