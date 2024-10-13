{
  # system.activationScripts.syncthing = {
  #	text = ''
  #		# create relevant directories

  #		mkdir -p /home/matthias/.config/syncthing
  #		mkdir -p /home/matthias/Music
  #		mkdir -p /home/matthias/Documents/Diary
  #		mkdir -p /home/matthias/Pictures/Pixel6a/{Pictures,DCIM}
  #
  #		chown -R matthias:users /home/matthias/.config/syncthing
  #		chown -R matthias:users /home/matthias/Music
  #		chown -R matthias:users /home/matthias/Documents/Diary
  #		chown -R matthias:users /home/matthias/Pictures/Pixel6a
  #	'';
  # };

  services.syncthing = {
    enable = true;
    dataDir = "/home/matthias/";
    configDir = "/home/matthias/.config/syncthing/";
    user = "matthias";
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      folders = {
        "Music" = {
          id = "silgm-drnzi";
          path = "/home/matthias/Music";
          devices = [ "vivaldi" "redmi-juri" "dmitry-hetzner" ];
        };
        "Diary" = {
          id = "oyniv-xxcpq";
          path = "/home/matthias/Documents/Diary";
          devices = [ "pixel6a" "vivaldi" ];
        };
        "Pictures-Pictures" = {
          id = "pwt40-pfnih";
          path = "/home/matthias/Pictures/Pixel6a/Pictures";
          devices = [ "pixel6a" ];
        };
        "Pictures-DCIM" = {
          id = "nqbb2-d2gt5";
          path = "/home/matthias/Pictures/Pixel6a/DCIM";
          devices = [ "pixel6a" ];
        };
      };
      devices = {
        "vivaldi" = {
          id =
            "NEHNOYU-SUHRROO-2BAW5HY-7JFLAGR-5UUJP7H-23XFZRX-72V444L-KILHHQH";
        };
        "pixel6a" = {
          id =
            "EA3NWML-6OQ2XLO-QN7NFMW-OENHZPH-7XCK7AJ-HLV7IRQ-ZVG4ASW-MPMO2AA";
        };
        "redmi-juri" = {
          id =
            "DWJDLPL-SHFFWDC-RPB6KCJ-PJKRVTS-EZER3ZH-S2AP3L5-6NC3A3T-IFGTUQY";
        };
        "dmitry-hetzner" = {
          id =
            "4JQIO44-Z2Y4MEZ-FUJFMOL-WY7QVXW-TFLSRNX-AC3OPFH-TBWQXA2-XEER7AY";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 22000 21027 ];
}
