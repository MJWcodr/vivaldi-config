{ config, lib, ... }:
let cfg = config.services.qobuz-downloader;
in {

  options = {
    ${cfg} = {
      enable = lib.mkEnableOption "Enable qobuz downloader";
      user = lib.mkOption {
        description = "User to run qobuz downloader as";
        default = "root";
      };
      configFilePath = lib.mkOption { description = "Path to config file"; };
    };
  };

  config = lib.mkIf cfg.enable {
    # create cron job to download music
    services.cron = {
      enable = true;
      systemCronJobs = [
        # run dmusic
        "0 * * * * ${cfg.user} ${
          ./qobuz-downloader/download.sh
        } ${cfg.configFilePath} >> /tmp/cron.log 2>&1"
      ];
    };
  };

}
