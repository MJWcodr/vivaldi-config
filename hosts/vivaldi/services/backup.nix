{ config, pkgs, ... }:

{
  # Initialize Secrets
  age.secrets."secrets/rclone_backup.age".file =
    ../../../secrets/rclone_backup.age;
  age.secrets."secrets/restic_backup.age".file =
    ../../../secrets/restic_backup.age;

  services.restic.backups = {
    "full-backup" = {
      user = "root";
      repository = "rclone:backup:restic_backup";
      paths = [ "/" ];
      passwordFile = config.age.secrets."secrets/restic_backup.age".path;
      rcloneConfigFile = config.age.secrets."secrets/rclone_backup.age".path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
        "--keep-yearly 2"
      ];
      rcloneOptions = { logFile = "/var/log/restic.log"; };
      timerConfig = {
        # Run every day at 3am
        OnCalendar = "hourly";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      exclude = [
        # srv
        # "/srv/entertainment" # i'd like to backup this. if it gets too big, i'll exclude it again
        "/srv/metube"
        # "/srv/music" # music is essential

        # don't backup binaries
        "/bin"
        "/lib"
        "/lib64"
        "/dev"
        "/sbin"
        "/usr"

        # don't backup caches
        "/var/cache"
        "/var/tmp"
        "/tmp"
        "/home/*/.cache"

        # don't backup containers
        "/var/lib/docker"
        "/var/lib/containers"

        # don't backup devices
        "/dev"
        "/afs"
        "/sys"
        "/proc"
        "/run"
        "/lost+found"
        "/mnt"
        "/media"

        # don't backup trash
        "/home/*/.local/share/Trash"
        "/home/*/.local/share/Steam"

        # don't backup nix store
        "/nix"
        "/home/*/.nix-profile"
      ];
    };
  };
}
