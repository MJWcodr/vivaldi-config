{ config, pkgs, lib, ... }:
let cfg = config.services.webdavShare;
in {
  options = {
    services.webdavShare = {
      enable = lib.mkEnableOption "WebDAV";
      port = lib.mkOption {
        type = lib.types.int;
        default = 8080;
      };
      addr = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
      };
      internalPrivatePort = lib.mkOption {
        type = lib.types.int;
        default = cfg.port + 1;
      };
      internalPublicPort = lib.mkOption {
        type = lib.types.int;
        default = cfg.port + 2;
      };
      htpasswdFile = lib.mkOption { type = lib.types.path; };
      serveDir = lib.mkOption { type = lib.types.path; };
      publicPath = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.serveDir}/public";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Private WebDAV
    systemd.services.privateWebdav = {
      description = "Private WebDAV";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      serviceConfig = {
        ExecStart =
          "${pkgs.rclone}/bin/rclone serve webdav --htpasswd ${cfg.htpasswdFile} --baseurl /private  --addr :${
            toString cfg.internalPrivatePort
          } ${cfg.serveDir}";
        Restart = "always";
        RestartSec = "10";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Public WebDAV
    services.static-web-server = {
      enable = true;
      listen = "0.0.0.0:${toString cfg.internalPublicPort}";
      root = "${cfg.publicPath}";
      configuration = { general = { directory-listing = true; }; };
    };

    # Nginx
    services.nginx = {
      enable = true;
      virtualHosts = {
        "dav" = {
          forceSSL = false;
          enableACME = false;
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString cfg.internalPublicPort}";
            };
            "/private" = {
              proxyPass =
                "http://localhost:${toString cfg.internalPrivatePort}/private";
            };
          };
          listen = [{
            port = cfg.port;
            ssl = false;
            addr = "${cfg.addr}";
          }];

        };
      };
    };
  };
}
