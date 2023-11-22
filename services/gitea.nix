{ config, pkgs, ... }:
let
	internalPort = 3000;
	exposedPort = 3001;
	domain = "vivaldi.fritz.box";

	giteaRunnerDir = "/var/lib/gitea-runner/vivaldi";
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
		gitea-actions-token = {
			file = ../secrets/gitea-actions-token.age;
			owner = "gitea-runner";
		};
  };
	
	# Create Gitea-Runner user
	users.users.gitea-runner = {
		isSystemUser = true;
		name = "gitea-runner";
		group = "gitea-runner";
	};
	users.groups.gitea-runner = {};

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
    settings = {
			server = {
      	DOMAIN = domain;
      	ROOT_URL = "https://${domain}:${toString exposedPort}/";
      	HTTP_PORT = internalPort;
    	};
			service = {
				DISABLE_REGISTRATION = true;
			};
			"service.explore" = {
				REQUIRE_SIGNIN_VIEW = true;
			};
			actions.ENABLED = true;
		};
  };

	# Create a token for the actions runner
	systemd.services.gitea-actions-runner-token = {
		description = "Create a token for the gitea actions runner";
		script = ''
		token=$(${pkgs.sudo}/bin/sudo -u gitea gitea actions grt --config /srv/gitea/custom/conf/app.ini)
		
		mkdir -p $(dirname ${config.services.gitea-actions-runner.instances.vivaldi.tokenFile})
		
		echo $token > ${config.services.gitea-actions-runner.instances.vivaldi.tokenFile}

		${pkgs.toybox}/bin/chown -R gitea-runner:  /var/lib/gitea-runner/vivaldi
		'';
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
			User = "root";
		};
		path = [ 
			pkgs.bash 
			pkgs.coreutils 
			pkgs.gitea 
			];
		after = [ "gitea.service" ];
		wantedBy = [ "multi-user.target" ];
	};


	##########
	# Gitea Actions Runner
	##########
	services.gitea-actions-runner.instances = {
		"vivaldi" = {
			enable = true;
			url = config.services.gitea.settings.server.ROOT_URL;
			name = "vivaldi";
			labels = [ "native:host" ];
			tokenFile = "/var/lib/gitea-runner/vivaldi/token";
		};
	};
	

  networking.firewall.allowedTCPPorts = [ 3001 ];
}

