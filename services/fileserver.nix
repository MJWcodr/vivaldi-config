{ config, pkgs, lib, ... }:

{
  # Initalize secrets
  age.secrets."secrets/rclone_backup.age".file = ../secrets/rclone_backup.age;
  age.secrets."secrets/restic_backup.age".file = ../secrets/restic_backup.age;

  # Install filebrowser
  virtualisation.oci-containers.containers.filebrowser = {
    image = "filebrowser/filebrowser";
    volumes = [
      "/srv/data:/srv"
      # "/srv/data/.filebrowser.db:/database.db"
      # "/etc/nixos/services/filebrowser/filebrowser.json:/filebrowser.json"
    ];
    ports = [ "8080:80" ];
    autoStart = true;
  };

  # Backup service
  services.restic = {
    backups.srvdata = {
      repository = "rclone:backup:restic_backup";
      paths = [ "/srv/data" ];
      passwordFile = config.age.secrets."secrets/restic_backup.age".path;
      rcloneConfigFile = config.age.secrets."secrets/rclone_backup.age".path;
			pruneOpts = [ 
				"--keep-daily 7"
				"--keep-weekly 4"
				"--keep-monthly 6"
				"--keep-yearly 2"
			];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
