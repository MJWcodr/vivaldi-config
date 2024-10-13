{ config, pkgs, ... }: {
  system.activationScripts.youtube-downloader = ''
    mkdir -p /srv/entertainment/youtube
  '';

  systemd.services.youtube-downloader = {
    description = "Youtube Downloader";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    requires = [ "network.target" ];

    path = [ pkgs.nixVersions.nix_2_17 ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "/etc/nixos/services/youtube-downloader/downloader.sh";
      Restart = "always";
      RestartSec = 30;
      StandardOutput = "journal";
      StandardError = "journal";
      User = "root";
      Group = "root";
    };
  };

  # run the downloader every 30 minutes
  systemd.timers.youtube-downloader = {
    description = "Youtube Downloader";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    requires = [ "network.target" ];

    timerConfig = {
      # Run hourly
      OnCalendar = "*:0/30";
      Persistent = true;
      Unit = "youtube-downloader.service";
    };

  };

}
