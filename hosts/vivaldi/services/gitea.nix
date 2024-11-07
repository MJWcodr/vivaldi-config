{ config, pkgs, ... }:
let
  internalPort = 3000;
  exposedPort = 3001;
  domain = "vivaldi.fritz.box";

  giteaRunnerDir = "/var/lib/gitea-runner/vivaldi";
in {
  ##########
  # Secrets
  ##########

  age.secrets = {
    gitea-postgres = {
      file = ../../../secrets/postgrespass.age;
      owner = config.services.gitea.user;
    };
    gitea-actions-token = {
      file = ../../../secrets/gitea-actions-token.age;
      owner = "gitea-runner";
    };
  };

  ##########
  # Nginx
  ##########

  services.nginx.virtualHosts."gitea" = {
    forceSSL = true;
    sslCertificate = config.age.secrets.sslcert.path;
    sslCertificateKey = config.age.secrets.sslkey.path;

    listen = [{
      ssl = true;
      port = exposedPort;
      addr = domain;
    }];

    locations."/" = {
      proxyPass = "http://localhost:${toString internalPort}/";
    };
  };

  ##########
  # Postgres
  ##########

  services.postgresql = {
    ensureDatabases = [ config.services.gitea.user ];
    ensureUsers = [{
      name = config.services.gitea.database.user;
      ensureDBOwnership = true;
    }];
  };

  ##########
  # Gitea
  ##########

  system.activationScripts.gitea = {
    text =
      "	#!/bin/sh\n	set -e\n	mkdir -p /srv/gitea\n	chown -R ${config.services.gitea.user}:${config.services.gitea.group} /srv/gitea\n";
  };

  services.forgejo = {
    enable = true;
    appName = "Mjwcodr Git"; # Give the site a name
    database = {
      type = "postgres";
      passwordFile = config.age.secrets.gitea-postgres.path;
    };
		lfs.enable = true;
    stateDir = "/srv/gitea";
    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://git.mjwcodr.de";
        HTTP_PORT = internalPort;
      };
      service = { DISABLE_REGISTRATION = true; };
      "service.explore" = { REQUIRE_SIGNIN_VIEW = false; };
      actions.ENABLED = true;
    };
  };

  ##########
  # Gitea Actions Runner
  ##########

  # Enable Podman API
  virtualisation.podman.dockerSocket.enable = true;

  ##########
  # Firewall
  ##########

  networking.firewall.allowedTCPPorts = [ 3001 ];
}
