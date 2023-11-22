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
    gitea-ctions-token = {
      file = ../secrets/gitea-actions-token.age;
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
      ensurePermissions."DATABASE ${config.services.gitea.database.name}" =
        "ALL PRIVILEGES";
    }];
  };

  ##########
  # Gitea	
  ##########

  system.activationScripts.gitea = {
    text =
      "	#!/bin/sh\n	set -e\n	mkdir -p /srv/gitea\n	chown -R ${config.services.gitea.user}:${config.services.gitea.group} /srv/gitea\n";
  };

  services.gitea = {
    enable = true;
    appName = "My awesome Gitea server"; # Give the site a name
    database = {
      type = "postgres";
      passwordFile = config.age.secrets.gitea-postgres.path;
    };
    stateDir = "/srv/gitea";
    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}:${toString exposedPort}/";
        HTTP_PORT = internalPort;
      };
      service = { DISABLE_REGISTRATION = true; };
      "service.explore" = { REQUIRE_SIGNIN_VIEW = true; };
      actions.ENABLED = true;
    };
  };

  ##########
  # Gitea Actions Runner
  ##########

	# Create Gitea-Runner user
  users.users.gitea-runner = {
    isSystemUser = true;
    name = "gitea-runner";
    group = "gitea-runner";
		extraGroups = [ "podman" ];
  };
  users.groups.gitea-runner = { };

  # Enable Podman API
  virtualisation.podman.dockerSocket.enable = true;

  systemd.services.gitea-actions-runner-vivaldi-pre = {
    description = "Gitea Actions Runner Setup for Vivaldi";
    after = [ "gitea.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
    path = [ pkgs.bash pkgs.coreutils pkgs.gitea pkgs.gitea-actions-runner pkgs.sudo ];
    script = ''
			token=$(sudo -u gitea gitea actions generate-runner-token --config ${config.services.gitea.stateDir}/custom/conf/app.ini)
			mkdir -p ${giteaRunnerDir}	
			
			cd ${giteaRunnerDir}	
			act_runner register	\
				--instance "https://${domain}:${toString exposedPort}" \
				--name vivaldi \
				--token $token \
				--labels "ubuntu-20.04:docker://node:16-bullseye, nixos:docker:nixos/nix:latest linux:host" \
				--no-interactive 

			chown -R gitea-runner:  ${giteaRunnerDir}'';
  };
		systemd.services.gitea-actions-runner-vivaldi = {
    description = "Gitea Actions Runner for Vivaldi";
    after = [ "gitea-actions-runner-vivaldi-pre.service" ];
    path = [ pkgs.gitea-actions-runner ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "gitea-runner";
      WorkingDirectory = giteaRunnerDir;
    };
    script = ''
			set -e
			DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
			act_runner daemon
		'';
  };

  ##########
  # Firewall
  ##########

  networking.firewall.allowedTCPPorts = [ 3001 ];
}

