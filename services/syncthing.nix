{ config, lib, pkgs, ... }: {

  system.activationScripts.syncthing =
    "	#!/usr/bin/env bash\n	# syncthing activation script\n	\n	mkdir -p ${config.services.syncthing.configDir}\n	mkdir -p ${config.services.syncthing.dataDir}\n\n	# Chown the syncthing data directory to the syncthing user\n	chown -R ${config.services.syncthing.user}:${config.services.syncthing.group} ${config.services.syncthing.settings.folders.Music.path}\n\n	# Create import directories for photoprism\n	# Chown the photoprism import directories to the photoprism user\n	mkdir -p /srv/photoprism/import/pixel6a\n	mkdir -p /srv/photoprism/import/pixel6a/Pictures\n	mkdir -p /srv/photoprism/import/pixel6a/DCIM\n	chmod -R 775 /srv/photoprism/import/pixel6a\n	chown -R ${config.services.syncthing.user}:${config.services.syncthing.group} /srv/photoprism/import\n\n";

  # Add syncthing user to the photoprism group
  users.users.${config.services.syncthing.user}.extraGroups = [ "photoprism" ];

  services.syncthing = {
    enable = true;
    dataDir = "/home/matthias";
    openDefaultPorts = true;
    configDir = "/home/matthias/.config/syncthing";
    user = "matthias";
    group = "syncthing";
    overrideFolders = true;
    overrideDevices = true;
    guiAddress = "vivaldi.fritz.box:8384";
    settings = {
      folders = {
        "Music" = {
          id = "silgm-drnzi";
          path = "/srv/music";
          ignorePerms = true;
          devices = [ "mjw-laptop" "redmi-juri" "dmitry-hetzner" ];
        };
        # Pictures and Videos from Pixel 6a
        "Pictures-Pictures" = {
          id = "pwt40-pfnih";
          path = "/srv/photoprism/import/pixel6a/Pictures";
          ignorePerms = true;
          devices = [ "mjw-laptop" "pixel6a" ];
        };
        "Pictures-DCIM" = {
          id = "nqbb2-d2gt5";
          path = "/srv/photoprism/import/pixel6a/DCIM";
          ignorePerms = true;
          devices = [ "mjw-laptop" "pixel6a" ];
        };
      };
      devices = {
        "mjw-laptop" = {
          id =
            "4Y5LS2K-5ZEUZIE-DJT3BXB-CJCVZLM-FWSYJ3X-2GUOBE4-VCGJ6IV-567DCAN";
        };
        "pixel6a" = {
          id =
            "EA3NWML-6OQ2XLO-QN7NFMW-OENHZPH-7XCK7AJ-HLV7IRQ-ZVG4ASW-MPMO2AA";
          introducer = true;
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
  networking.firewall.allowedTCPPorts = [ 22000 21027 8384 ];
}
