{ config, pkgs, ... }:
let
  droneserver = config.users.users.droneserver.name;
in
{
  ##########
  # Secrets
  ##########

  age.secrets = {
    gitea-postgres = {
      file = ../secrets/postgrespass.age;
      owner = config.services.gitea.user;
    };
    sslcert = {
      file = ../secrets/sslcert.crt.age;
      owner = config.services.nginx.user;
    };
    sslkey = {
      file = ../secrets/sslcert.key.age;
      owner = config.services.nginx.user;
    };
  };


  ##########
  # Nginx
  ##########

  services.nginx.virtualHosts."vivaldi.fritz.box" = {
    forceSSL = true;
    sslCertificate = config.age.secrets.sslcert.path;
    sslCertificateKey = config.age.secrets.sslkey.path;

    listen = [{
      ssl = true;
      port = 3001;
      addr = "vivaldi.fritz.box";
    }];

    locations."/" = {
      proxyPass = "http://localhost:8030/";
    };
  };

  ##########
  # Postgres
  ##########

  services.postgresql = {
    ensureDatabases = [ config.services.gitea.user ];
    ensureUsers = [
      {
        name = config.services.gitea.database.user;
        ensurePermissions."DATABASE ${config.services.gitea.database.name}" = "ALL PRIVILEGES";
      }
    ];
  };

  ##########
  # Gitea	
  ##########

  system.activationScripts.gitea = {
    text = ''
      			#!/bin/sh
      			set -e
      			mkdir -p /srv/gitea
      			chown -R ${config.services.gitea.user}:${config.services.gitea.group} /srv/gitea
      		'';
  };

  services.gitea = {
    enable = true;
    appName = "My awesome Gitea server"; # Give the site a name
    database = {
      type = "postgres";
      passwordFile = config.age.secrets.gitea-postgres.path;
    };
    stateDir = "/srv/gitea";
    settings.server = {
      DOMAIN = "vivaldi.fritz.box";
      ROOT_URL = "https://vivaldi.fritz.box:3001/";
      HTTP_PORT = 8030;
    };
  };

  networking.firewall.allowedTCPPorts = [ 3001 ];
}

