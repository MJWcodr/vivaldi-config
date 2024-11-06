{ config, pkgs, ... }: {

  age.secrets = {
    nextcloud-secrets = {
      file = ../secrets/nextcloud-secrets.age;
      owner = config.users.nextcloud.user;
    };
    nextcloud-dbpass = {
      file = ../secrets/nextcloud-dbpass.age;
      owner = config.users.nextcloud.user;
    };
    nextcloud-adminpass = {
      file = ../secrets/nextcloud-adminpass.age;
      owner = config.users.nextcloud.user;
    };
  };

  environment.etc."nextcloud-admin-pass".text = "test123";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "localhost";
    secretFile = config.age.secrets."nextcloud-secrets".path;
    configureRedis = true;
    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "http";

      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = config.age.secrets."nextcloud-dbpass".path;

      adminpassFile = config.environment.etc."nextcloud-adminpass".path;
      adminuser = "admin";
    };
  };

  services.postgresql = {
    enable = true;

    # Ensure the database, user, and permissions always exist
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }];
  };

  services.nginx.virtualHosts."vivaldi.fritz.box".listen = [{
    addr = "127.0.0.1";
    port = 8081;
  }];

}
