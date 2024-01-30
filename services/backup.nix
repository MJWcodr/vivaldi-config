{config, pkgs, ...}:

{

	# Initialize Secrets
	age.secrets."secrets/rclone_backup.age".file = ../secrets/rclone_backup.age;
	age.secrets."secrets/restic_backup.age".file = ../secrets/restic_backup.age;

	services.restic.backups = {
	 "srv" = {
			repository = "rclone:backup:restic_backup";
			paths = [ "/srv" ];
			passwordFile = config.age.secrets."secrets/restic_backup.age".path;
      rcloneConfigFile = config.age.secrets."secrets/rclone_backup.age".path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
        "--keep-yearly 2"
      ];
      rcloneOptions = {
        logFile = "/var/log/restic.log";
      };
      timerConfig = {
        # Run every day at 3am
				OnCalendar = "daily";
				Persistent = true;
				RandomizedDelaySec = "1h";
      };
			exclude = [
				"/srv/entertainment"
				"/srv/metube"
				"/srv/music"
			];
	 };
	 "var" = {
	 		repository = "rclone:backup:restic_backup";
			paths = [ "/srv" ];
			passwordFile = config.age.secrets."secrets/restic_backup.age".path;
      rcloneConfigFile = config.age.secrets."secrets/rclone_backup.age".path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
        "--keep-yearly 2"
      ];
      rcloneOptions = {
        logFile = "/var/log/restic.log";
      };
      timerConfig = {
        # Run every day at 3am
				OnCalendar = "daily";
				Persistent = true;
				RandomizedDelaySec = "1h";
      };
			exclude = [
				"/var/cache"
				"/var/empty"
				"/var/lib/docker"
			];
	 };
	};
}
